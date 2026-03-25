import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/user_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentStep = 0.obs;
  static const totalSteps = 5;

  // Screen 1: Name
  final name = ''.obs;

  // Screen 2: Goals
  final selectedGoals = <String>[].obs;
  final availableGoals = [
    'Lose weight',
    'Maintain weight',
    'Gain weight',
    'Gain muscle',
    'Modify my diet',
    'Plan meals',
    'Manage stress',
  ];

  // Screen 3: Activity level
  final activityLevel = ''.obs;
  final activityOptions = [
    {
      'title': 'Not Very Active',
      'subtitle': 'Spend most of the day sitting (e.g., bankteller, desk job).',
    },
    {
      'title': 'Lightly Active',
      'subtitle':
          'Spend a good part of the day on your feet (e.g., teacher, salesperson).',
    },
    {
      'title': 'Active',
      'subtitle':
          'Spend a good part of the day doing some physical activity (e.g., food server, postal carrier).',
    },
    {
      'title': 'Very Active',
      'subtitle':
          'Spend a good part of the day doing heavy physical activity (e.g., bike messenger, carpenter).',
    },
  ];

  // Screen 4: Personal info
  final gender = ''.obs;
  final age = ''.obs;
  final country = ''.obs;

  // Screen 5: Body info
  final heightCm = ''.obs;
  final weightKg = ''.obs;

  // Loading state
  final isSubmitting = false.obs;

  // Validation
  bool get isNameValid => name.value.trim().isNotEmpty;
  bool get isGoalsValid => selectedGoals.isNotEmpty;
  bool get isActivityValid => activityLevel.value.isNotEmpty;
  bool get isPersonalInfoValid =>
      gender.value.isNotEmpty && age.value.isNotEmpty;
  bool get isBodyInfoValid =>
      heightCm.value.isNotEmpty && weightKg.value.isNotEmpty;

  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else if (selectedGoals.length < 3) {
      selectedGoals.add(goal);
    }
  }

  // Map frontend goals to backend enum
  String get primaryGoal {
    if (selectedGoals.contains('Lose weight')) {
      return 'lose';
    }
    if (selectedGoals.contains('Gain weight') ||
        selectedGoals.contains('Gain muscle')) {
      return 'gain';
    }
    return 'maintain';
  }

  // Map frontend activity to backend enum
  String get activityLevelEnum {
    switch (activityLevel.value) {
      case 'Not Very Active':
        return 'low';
      case 'Lightly Active':
        return 'low';
      case 'Active':
        return 'moderate';
      case 'Very Active':
        return 'high';
      default:
        return 'low';
    }
  }

  // PageView navigation
  void nextPage() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // Submit onboarding → send to backend
  Future<void> submitOnboarding() async {
    isSubmitting.value = true;
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update user profile on backend
      await UserService.updateUser(userId, {
        'name': name.value.trim(),
        'age': int.tryParse(age.value) ?? 25,
        'gender': gender.value.toLowerCase(),
        'heightCm': double.tryParse(heightCm.value) ?? 170,
        'weightKg': double.tryParse(weightKg.value) ?? 70,
        'goal': primaryGoal,
        'activityLevel': activityLevelEnum,
      });

      // Also save locally for offline use
      final box = GetStorage();
      await box.write('userName', name.value.trim());
      await box.write('goal', primaryGoal);
      await box.write('activityLevel', activityLevelEnum);
      await box.write('gender', gender.value.toLowerCase());
      await box.write('age', int.tryParse(age.value) ?? 25);
      await box.write('heightCm', double.tryParse(heightCm.value) ?? 170);
      await box.write('weightKg', double.tryParse(weightKg.value) ?? 70);
      await box.write('country', country.value);
      await box.write('onboardingComplete', true);

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red.shade700,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
