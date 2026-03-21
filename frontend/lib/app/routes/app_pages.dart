import 'package:get/get.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/modules/auth/views/sign_in_view.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:fitness_app/app/modules/onboarding/views/name_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/goals_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/goals_info_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/activity_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/personal_info_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
    ),
    GetPage(
      name: AppRoutes.onboardingName,
      page: () => const NameView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<OnboardingController>()) {
          Get.put(OnboardingController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.onboardingGoals,
      page: () => const GoalsView(),
    ),
    GetPage(
      name: AppRoutes.onboardingGoalsInfo,
      page: () => const GoalsInfoView(),
    ),
    GetPage(
      name: AppRoutes.onboardingActivity,
      page: () => const ActivityView(),
    ),
    GetPage(
      name: AppRoutes.onboardingPersonalInfo,
      page: () => const PersonalInfoView(),
    ),
  ];
}
