import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/widgets/onboarding_scaffold.dart';
import 'package:fitness_app/app/widgets/option_tile.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';

class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Obx(() => OnboardingScaffold(
          title: 'Goals',
          currentStep: 1,
          onNext: controller.goToGoalsInfo,
          onBack: controller.goBack,
          isNextEnabled: controller.isGoalsValid,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, ${controller.name.value}. 👋 Let\'s start with your goals.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select up to three that are most important to you.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.availableGoals.length,
                  itemBuilder: (context, index) {
                    final goal = controller.availableGoals[index];
                    return OptionTile(
                      title: goal,
                      isSelected: controller.selectedGoals.contains(goal),
                      onTap: () => controller.toggleGoal(goal),
                      useCheckbox: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
