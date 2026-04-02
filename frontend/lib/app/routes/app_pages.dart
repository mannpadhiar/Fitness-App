import 'package:get/get.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/modules/splash/views/splash_view.dart';
import 'package:fitness_app/app/modules/splash/controllers/splash_controller.dart';
import 'package:fitness_app/app/modules/auth/views/sign_in_view.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:fitness_app/app/modules/onboarding/views/onboarding_view.dart';
import 'package:fitness_app/app/modules/home/controllers/home_controller.dart';
import 'package:fitness_app/app/modules/nav/views/main_nav_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainNavView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
  ];
}
