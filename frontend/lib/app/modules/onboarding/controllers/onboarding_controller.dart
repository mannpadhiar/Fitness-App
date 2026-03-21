import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  // Step tracking
  final currentStep = 0.obs;
  static const totalSteps = 4;

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

  // Screen 4: Activity level
  final activityLevel = ''.obs;
  final activityOptions = [
    {
      'title': 'Not Very Active',
      'subtitle':
          'Spend most of the day sitting (e.g., bankteller, desk job).',
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

  // Screen 5: Personal info
  final gender = ''.obs;
  final age = ''.obs;
  final country = ''.obs;

  // Validation
  bool get isNameValid => name.value.trim().isNotEmpty;
  bool get isGoalsValid => selectedGoals.isNotEmpty;
  bool get isActivityValid => activityLevel.value.isNotEmpty;
  bool get isPersonalInfoValid =>
      gender.value.isNotEmpty && age.value.isNotEmpty;

  // Goal selection (up to 3)
  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else if (selectedGoals.length < 3) {
      selectedGoals.add(goal);
    }
  }

  // Map goals to backend enum
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

  // Map activity to backend enum
  String get activityLevelEnum {
    switch (activityLevel.value) {
      case 'Not Very Active':
        return 'low';
      case 'Lightly Active':
      case 'Active':
        return 'moderate';
      case 'Very Active':
        return 'high';
      default:
        return 'low';
    }
  }

  // Navigation
  void goToGoals() {
    currentStep.value = 1;
    Get.toNamed(AppRoutes.onboardingGoals);
  }

  void goToGoalsInfo() {
    currentStep.value = 1;
    Get.toNamed(AppRoutes.onboardingGoalsInfo);
  }

  void goToActivity() {
    currentStep.value = 2;
    Get.toNamed(AppRoutes.onboardingActivity);
  }

  void goToPersonalInfo() {
    currentStep.value = 3;
    Get.toNamed(AppRoutes.onboardingPersonalInfo);
  }

  void goBack() {
    Get.back();
  }

  // Submit onboarding data (stub — will connect to backend later)
  Future<void> submitOnboarding() async {
    final data = {
      'name': name.value.trim(),
      'goal': primaryGoal,
      'activityLevel': activityLevelEnum,
      'gender': gender.value.toLowerCase(),
      'age': int.tryParse(age.value) ?? 25,
      'country': country.value,
    };

    // TODO: POST to backend /api/users
    debugPrint('Onboarding data: $data');

    // Navigate to home
    Get.offAllNamed(AppRoutes.home);
  }
}
