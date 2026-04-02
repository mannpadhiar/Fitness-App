import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/user_service.dart';
import 'package:fitness_app/app/services/daily_service.dart';
import 'package:fitness_app/app/services/data_preload_service.dart';

class HomeController extends GetxController {
  final box = GetStorage();

  // User profile
  final userName = ''.obs;
  final userEmail = ''.obs;
  final gender = ''.obs;
  final age = 25.obs;
  final heightCm = 170.0.obs;
  final weightKg = 70.0.obs;
  final goal = 'maintain'.obs;
  final activityLevel = 'low'.obs;
  final country = ''.obs;

  // Calorie tracking
  final targetCalories = 0.obs;
  final targetProtein = 0.obs;
  final targetCarbs = 0.obs;
  final targetFats = 0.obs;
  final foodCalories = 0.obs;
  final exerciseCalories = 0.obs;
  int get remainingCalories =>
      targetCalories.value - foodCalories.value + exerciseCalories.value;

  // Nutrition from daily summary
  final totalProtein = 0.0.obs;
  final totalCarbs = 0.0.obs;
  final totalFats = 0.0.obs;

  // Steps
  final steps = 0.obs;
  final stepsGoal = 8000.obs;
  StreamSubscription<int>? _stepSubscription;
  final pedometer = Pedometer();
  int _initialStreamSteps = -1; // first value from stepCountStream (since boot)
  int _baselineDailySteps = 0;  // steps from getStepCount (today so far)

  // Loading
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _requestPermissionAndStartPedometer();
  }

  // --- Load data: prefer preloaded, fallback to backend/local ---
  Future<void> _loadData() async {
    try {
      final preload = Get.find<DataPreloadService>();

      if (preload.isPreloaded && preload.userData != null) {
        // Use preloaded data — instant, no network call
        _applyUserData(preload.userData!);
        _applyDailySummary(preload.dailySummary);
        _saveToLocalStorage();
      } else {
        // Fallback: fetch from backend directly
        await _loadFromBackend();
      }
    } catch (e) {
      debugPrint('Preloaded data not available, fetching: $e');
      await _loadFromBackend();
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply user profile data from a Map (works with both preloaded and fresh data)
  void _applyUserData(Map<String, dynamic> userData) {
    userName.value = userData['name'] ?? 'User';
    userEmail.value = userData['email'] ?? '';
    gender.value = userData['gender'] ?? 'male';
    age.value = userData['age'] ?? 25;
    heightCm.value = (userData['heightCm'] ?? 170).toDouble();
    weightKg.value = (userData['weightKg'] ?? 70).toDouble();
    goal.value = userData['goal'] ?? 'maintain';
    activityLevel.value = userData['activityLevel'] ?? 'low';

    // Read active goal (backend auto-creates this on user creation/update)
    final goals = userData['userGoals'] as List<dynamic>? ?? [];
    if (goals.isNotEmpty) {
      final activeGoal = goals.first as Map<String, dynamic>;
      targetCalories.value = activeGoal['targetCalories'] ?? 2000;
      targetProtein.value = (activeGoal['targetProtein'] ?? 0).round();
      targetCarbs.value = (activeGoal['targetCarbs'] ?? 0).round();
      targetFats.value = (activeGoal['targetFats'] ?? 0).round();
    } else {
      _calculateTargetCaloriesLocally();
    }

    // Calculate dynamic steps goal based on user profile
    _calculateStepsGoal();
  }

  /// Apply daily summary data from a Map
  void _applyDailySummary(Map<String, dynamic>? summary) {
    if (summary == null) return;
    foodCalories.value =
        (summary['totalCaloriesConsumed'] ?? 0).round();
    totalProtein.value =
        (summary['totalProtein'] ?? 0).toDouble();
    totalCarbs.value =
        (summary['totalCarbs'] ?? 0).toDouble();
    totalFats.value =
        (summary['totalFats'] ?? 0).toDouble();
    exerciseCalories.value =
        (summary['totalCaloriesBurned'] ?? 0).round();
  }

  // --- Permission + Pedometer ---
  Future<void> _requestPermissionAndStartPedometer() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        status = await Permission.activityRecognition.request();
      } else {
        status = await Permission.sensors.request();
      }

      if (status.isGranted) {
        await _initPedometer();
      } else {
        debugPrint('Activity permission denied: $status');
        // Still try — some devices work without explicit grant
        await _initPedometer();
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
      await _initPedometer();
    }
  }

  Future<void> _initPedometer() async {
    // 1. Get today's steps so far using getStepCount (accurate daily total)
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      _baselineDailySteps = await pedometer.getStepCount(
        from: todayStart,
        to: now,
      );
      steps.value = _baselineDailySteps;
      _updateExerciseCalories();
      debugPrint('Baseline daily steps: $_baselineDailySteps');
    } catch (e) {
      debugPrint('getStepCount failed: $e');
      _baselineDailySteps = 0;
    }

    // 2. Listen to live stream for real-time updates
    //    The stream returns steps since last boot, so we track the delta
    _initialStreamSteps = -1;
    _stepSubscription = pedometer.stepCountStream().listen(
      (stepCount) {
        if (_initialStreamSteps == -1) {
          // First stream event — this is the "since boot" baseline
          _initialStreamSteps = stepCount;
          // Don't update steps.value yet — baseline already has the right count
          debugPrint('Stream baseline (since boot): $_initialStreamSteps');
        } else {
          // Delta = how many steps since we started listening
          final delta = stepCount - _initialStreamSteps;
          steps.value = _baselineDailySteps + delta;
          _updateExerciseCalories();

          // Sync to backend periodically
          _syncStepsToBackend(steps.value);
        }
      },
      onError: (error) {
        debugPrint('Pedometer stream error: $error');
      },
    );
  }

  void _updateExerciseCalories() {
    // Weight-aware formula: calories per step ≈ 0.0005 × weight(kg)
    final calPerStep = 0.0005 * weightKg.value;
    exerciseCalories.value = (steps.value * calPerStep).round();
  }

  // --- Dynamic Steps Goal Calculation ---
  void _calculateStepsGoal() {
    final weight = weightKg.value;
    final height = heightCm.value;
    final userAge = age.value;
    final userGender = gender.value;
    final userGoal = goal.value;
    final activity = activityLevel.value;

    // 1. BMR (Mifflin-St Jeor)
    final base = 10 * weight + 6.25 * height - 5 * userAge;
    final bmr = userGender == 'male' ? base + 5 : base - 161;

    // 2. Activity multiplier
    double activityMultiplier;
    switch (activity) {
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'high':
        activityMultiplier = 1.725;
        break;
      default: // 'low'
        activityMultiplier = 1.2;
    }

    // 3. TDEE
    final tdee = bmr * activityMultiplier;

    // 4. Goal-based calorie adjustment
    double calorieAdjustment;
    switch (userGoal) {
      case 'lose':
        calorieAdjustment = -400; // deficit to burn via walking
        break;
      case 'gain':
        calorieAdjustment = 200; // small surplus, less walking needed
        break;
      default: // 'maintain'
        calorieAdjustment = 0;
    }

    // 5. Calculate target extra calories to burn through steps
    //    For 'lose': user needs to burn extra 400 kcal through activity
    //    For 'maintain': moderate activity target
    //    For 'gain': lighter step target
    double targetStepCalories;
    switch (userGoal) {
      case 'lose':
        // Burn the deficit through walking
        targetStepCalories = calorieAdjustment.abs();
        break;
      case 'gain':
        // Light walking — just enough for health
        targetStepCalories = 150;
        break;
      default: // 'maintain'
        // Moderate walking
        targetStepCalories = 250;
    }

    // 6. Calories per step = 0.0005 × weight(kg)
    final calPerStep = 0.0005 * weight;

    // 7. Steps = target calories / cal per step
    int calculatedSteps = (targetStepCalories / calPerStep).round();

    // 8. Clamp to reasonable range
    calculatedSteps = calculatedSteps.clamp(4000, 15000);

    stepsGoal.value = calculatedSteps;
    debugPrint('Dynamic steps goal: $calculatedSteps '
        '(BMR=$bmr, TDEE=$tdee, goal=$userGoal, calPerStep=$calPerStep)');
  }

  // --- Backend Data Loading (fallback when preloaded data not available) ---
  Future<void> _loadFromBackend() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        _loadFromLocalStorage();
        return;
      }

      // Fetch user profile (includes active goal)
      final userData = await UserService.getUser(userId);
      _applyUserData(userData);

      // Fetch today's daily summary
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      try {
        final summary = await DailyService.getDailySummary(userId, dateStr);
        _applyDailySummary(summary);
      } catch (e) {
        debugPrint('Daily summary not available: $e');
      }

      // Also save to local storage for offline fallback
      _saveToLocalStorage();
    } catch (e) {
      debugPrint('Backend fetch failed, using local storage: $e');
      _loadFromLocalStorage();
    }
  }

  void _loadFromLocalStorage() {
    userName.value = box.read('userName') ?? 'User';
    gender.value = box.read('gender') ?? 'male';
    age.value = box.read('age') ?? 25;
    heightCm.value = (box.read('heightCm') ?? 170).toDouble();
    weightKg.value = (box.read('weightKg') ?? 70).toDouble();
    goal.value = box.read('goal') ?? 'maintain';
    activityLevel.value = box.read('activityLevel') ?? 'low';
    country.value = box.read('country') ?? '';
    _calculateTargetCaloriesLocally();
    _calculateStepsGoal();
  }

  void _saveToLocalStorage() {
    box.write('userName', userName.value);
    box.write('gender', gender.value);
    box.write('age', age.value);
    box.write('heightCm', heightCm.value);
    box.write('weightKg', weightKg.value);
    box.write('goal', goal.value);
    box.write('activityLevel', activityLevel.value);
  }

  // Fallback local BMR/TDEE calculation
  void _calculateTargetCaloriesLocally() {
    final base =
        10 * weightKg.value + 6.25 * heightCm.value - 5 * age.value;
    final bmr = gender.value == 'male' ? base + 5 : base - 161;

    double multiplier;
    switch (activityLevel.value) {
      case 'low':
        multiplier = 1.2;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'high':
        multiplier = 1.725;
        break;
      default:
        multiplier = 1.2;
    }

    double tdee = bmr * multiplier;
    switch (goal.value) {
      case 'lose':
        tdee -= 500;
        break;
      case 'gain':
        tdee += 500;
        break;
    }
    targetCalories.value = tdee.round();
  }

  // --- Step Sync ---
  Timer? _syncTimer;
  void _syncStepsToBackend(int stepCount) {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 30), () async {
      try {
        final userId = await AuthService.getUserId();
        if (userId != null) {
          await DailyService.upsertSteps(userId, stepCount);
        }
      } catch (e) {
        debugPrint('Step sync failed: $e');
      }
    });
  }

  // --- Greeting ---
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  // --- Logout ---
  void logout() {
    // Clear preloaded data
    try {
      Get.find<DataPreloadService>().clear();
    } catch (_) {}

    AuthService.logout();
    box.erase();
    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  void onClose() {
    _stepSubscription?.cancel();
    _syncTimer?.cancel();
    super.onClose();
  }
}
