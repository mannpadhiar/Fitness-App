import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/user_service.dart';
import 'package:fitness_app/app/services/daily_service.dart';

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
  final stepsGoal = 10000;
  StreamSubscription<int>? _stepSubscription;
  final pedometer = Pedometer();

  // Loading
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromBackend();
    _initPedometer();
  }

  // Fetch user profile + active goal + daily summary from backend
  Future<void> _loadFromBackend() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        _loadFromLocalStorage();
        return;
      }

      // Fetch user profile (includes active goal)
      final userData = await UserService.getUser(userId);
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

      // Fetch today's daily summary
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      try {
        final summary = await DailyService.getDailySummary(userId, dateStr);
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
      } catch (e) {
        debugPrint('Daily summary not available: $e');
      }

      // Also save to local storage for offline fallback
      _saveToLocalStorage();
    } catch (e) {
      debugPrint('Backend fetch failed, using local storage: $e');
      _loadFromLocalStorage();
    } finally {
      isLoading.value = false;
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
    isLoading.value = false;
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

  // --- Pedometer ---
  void _initPedometer() {
    _stepSubscription = pedometer.stepCountStream().listen(
      (stepCount) {
        steps.value = stepCount;
        exerciseCalories.value = (stepCount * 0.04).round();

        // Sync steps to backend periodically
        _syncStepsToBackend(stepCount);
      },
      onError: (error) {
        steps.value = 0;
      },
    );
  }

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
