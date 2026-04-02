import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/user_service.dart';
import 'package:fitness_app/app/services/daily_service.dart';

/// Global service that preloads all essential data during the splash screen.
/// Controllers can read from this instead of making individual API calls.
class DataPreloadService extends GetxService {
  final box = GetStorage();

  // Whether data has been preloaded successfully
  bool _isPreloaded = false;
  bool get isPreloaded => _isPreloaded;

  // User profile data
  Map<String, dynamic>? userData;
  String? userId;

  // Today's daily summary
  Map<String, dynamic>? dailySummary;

  /// Call this during the splash screen to preload all data.
  /// Returns the route to navigate to after loading.
  Future<String> preloadAndResolveRoute() async {
    try {
      // 1. Check auth
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) return '/sign-in';

      userId = await AuthService.getUserId();
      if (userId == null) return '/sign-in';

      // 2. Check onboarding status
      final onboardingDone = box.read('onboardingComplete') ?? false;

      // 3. Fetch user profile (includes active goal)
      try {
        userData = await UserService.getUser(userId!);

        // Check if onboarding is complete (has height/weight)
        if (!onboardingDone) {
          if (userData!['heightCm'] != null && userData!['weightKg'] != null) {
            await box.write('onboardingComplete', true);
            // Cache user data locally
            _cacheUserData(userData!);
          } else {
            return '/onboarding';
          }
        }
      } catch (e) {
        debugPrint('User profile fetch failed: $e');
        // If we have cached data, continue; otherwise show onboarding/sign-in
        if (!onboardingDone && box.read('heightCm') == null) {
          return '/onboarding';
        }
      }

      // 4. Fetch today's daily summary
      try {
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        dailySummary = await DailyService.getDailySummary(userId!, dateStr);
      } catch (e) {
        debugPrint('Daily summary preload failed: $e');
        // Not critical — controller will show zeros
      }

      _isPreloaded = true;
      return '/home';
    } catch (e) {
      debugPrint('Preload failed: $e');
      // Fallback: check if we have enough cached data to go home
      final onboardingDone = box.read('onboardingComplete') ?? false;
      if (onboardingDone) {
        return '/home';
      }
      return '/sign-in';
    }
  }

  void _cacheUserData(Map<String, dynamic> user) {
    box.write('userName', user['name'] ?? '');
    box.write('gender', user['gender'] ?? 'male');
    box.write('age', user['age'] ?? 25);
    box.write('heightCm', user['heightCm'] ?? 170);
    box.write('weightKg', user['weightKg'] ?? 70);
    box.write('goal', user['goal'] ?? 'maintain');
    box.write('activityLevel', user['activityLevel'] ?? 'low');
  }

  /// Clear preloaded data (e.g., on logout)
  void clear() {
    userData = null;
    dailySummary = null;
    userId = null;
    _isPreloaded = false;
  }
}
