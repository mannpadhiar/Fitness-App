import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/widgets/onboarding_scaffold.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';

class NameView extends StatelessWidget {
  const NameView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final textController = TextEditingController(text: controller.name.value);

    return Obx(() => OnboardingScaffold(
          title: 'Welcome',
          currentStep: 0,
          onNext: controller.goToGoals,
          isNextEnabled: controller.isNameValid,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'First, what can we call you?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "We'd like to get to know you. 🙂",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Text(
                'Preferred first name',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                style: const TextStyle(color: AppColors.textPrimary),
                autofocus: true,
                onChanged: (value) => controller.name.value = value,
                decoration: const InputDecoration(
                  hintText: '',
                ),
              ),
            ],
          ),
        ));
  }
}
