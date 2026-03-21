import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/widgets/onboarding_scaffold.dart';
import 'package:fitness_app/app/widgets/option_tile.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Obx(() => OnboardingScaffold(
          title: 'Goals',
          currentStep: 2,
          onNext: controller.goToPersonalInfo,
          onBack: controller.goBack,
          isNextEnabled: controller.isActivityValid,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is your baseline activity level?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Not including workouts - we count that separately.',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose what describes you best:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.activityOptions.length,
                  itemBuilder: (context, index) {
                    final option = controller.activityOptions[index];
                    return OptionTile(
                      title: option['title']!,
                      subtitle: option['subtitle'],
                      isSelected:
                          controller.activityLevel.value == option['title'],
                      onTap: () =>
                          controller.activityLevel.value = option['title']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
