import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/widgets/onboarding_scaffold.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';

class BodyInfoPage extends StatelessWidget {
  const BodyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final heightCtrl =
        TextEditingController(text: controller.heightCm.value);
    final weightCtrl =
        TextEditingController(text: controller.weightKg.value);

    return Obx(() => OnboardingScaffold(
          title: 'Body',
          currentStep: 4,
          totalSteps: OnboardingController.totalSteps,
          onNext: controller.submitOnboarding,
          onBack: controller.previousPage,
          isNextEnabled: controller.isBodyInfoValid,
          nextLabel: 'Finish',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost there! 💪',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'We need your height and weight to calculate your calorie goals accurately.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Text('Height (cm)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: heightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (v) => controller.heightCm.value = v,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 175',
                    suffixText: 'cm',
                    suffixStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Weight (kg)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (v) => controller.weightKg.value = v,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 70',
                    suffixText: 'kg',
                    suffixStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This information helps us calculate your daily calorie target using the Mifflin-St Jeor equation.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ));
  }
}
