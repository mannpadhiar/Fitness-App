import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/routes/app_pages.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await GetStorage.init();

  final initialRoute = await _resolveInitialRoute();
  runApp(FitnessApp(initialRoute: initialRoute));
}

/// Determines where to send the user on startup:
///  1. Not logged in → Sign In
///  2. Logged in + local onboardingComplete flag → Home
///  3. Logged in + no local flag → check backend profile
///     a. Profile has weight/height → set flag, go Home
///     b. No profile data → Onboarding
Future<String> _resolveInitialRoute() async {
  final isLoggedIn = await AuthService.isLoggedIn();
  if (!isLoggedIn) return AppRoutes.signIn;

  final box = GetStorage();
  final onboardingDone = box.read('onboardingComplete') ?? false;
  if (onboardingDone) return AppRoutes.home;

  // Fallback: check backend user profile
  try {
    final userId = await AuthService.getUserId();
    if (userId == null) return AppRoutes.signIn;

    final res = await ApiService.get('/users/$userId');
    if (res.statusCode == 200) {
      final user = jsonDecode(res.body) as Map<String, dynamic>;
      if (user['heightCm'] != null && user['weightKg'] != null) {
        // Profile is complete — cache and go home
        await box.write('onboardingComplete', true);
        await box.write('userName', user['name'] ?? '');
        await box.write('gender', user['gender'] ?? 'male');
        await box.write('age', user['age'] ?? 25);
        await box.write('heightCm', user['heightCm'] ?? 170);
        await box.write('weightKg', user['weightKg'] ?? 70);
        await box.write('goal', user['goal'] ?? 'maintain');
        await box.write('activityLevel', user['activityLevel'] ?? 'low');
        return AppRoutes.home;
      }
    }
  } catch (_) {
    // Network error — if we have cached data, go home anyway
    if (box.read('heightCm') != null) return AppRoutes.home;
  }

  return AppRoutes.onboarding;
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
