import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/services/auth_service.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isRegister = false.obs;
  RxString errorMessage = "".obs;

  Future<void> _submit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      if (isRegister.value) {
        await AuthService.register(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        final result = await AuthService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        final user = result['user'] as Map<String, dynamic>;
        if (user['heightCm'] != null && user['weightKg'] != null) {
          // User has completed onboarding — cache data for offline
          final box = GetStorage();
          await box.write('onboardingComplete', true);
          await box.write('userName', user['name'] ?? '');
          await box.write('gender', user['gender'] ?? 'male');
          await box.write('age', user['age'] ?? 25);
          await box.write('heightCm', user['heightCm'] ?? 170);
          await box.write('weightKg', user['weightKg'] ?? 70);
          await box.write('goal', user['goal'] ?? 'maintain');
          await box.write('activityLevel', user['activityLevel'] ?? 'low');
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.onboarding);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 2),
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(31, 111, 148, 249),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'FitTrack',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal nutrition companion',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 40),
                    Obx(
                      () => Column(
                        children: [
                          if (errorMessage.value.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                errorMessage.value,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() =>
                      ElevatedButton(
                        onPressed: isLoading.value ? null : _submit,
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Obx(()=> Text(isRegister.value ? 'Create Account' : 'Sign In')),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() =>
                        Text(
                          isRegister.value
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                        GestureDetector(
                          onTap: () {
                            isRegister.value = !isRegister.value;
                            errorMessage.value = "";
                          },
                          child: Obx(() => Text(
                            isRegister.value ? 'Sign In' : 'Register',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
