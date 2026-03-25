import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/routes/app_pages.dart';
import 'package:fitness_app/app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Check if user is already logged in
  final isLoggedIn = await AuthService.isLoggedIn();
  String initialRoute;

  if (isLoggedIn) {
    final box = GetStorage();
    final onboardingDone = box.read('onboardingComplete') ?? false;
    initialRoute = onboardingDone ? AppRoutes.home : AppRoutes.onboarding;
  } else {
    initialRoute = AppRoutes.signIn;
  }

  runApp(FitnessApp(initialRoute: initialRoute));
}

class FitnessApp extends StatelessWidget {
  final String initialRoute;
  const FitnessApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
