import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/widgets/onboarding_scaffold.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';

class GoalsInfoView extends StatelessWidget {
  const GoalsInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return OnboardingScaffold(
      title: 'Goals',
      currentStep: 1,
      onNext: controller.goToActivity,
      onBack: controller.goBack,
      useGradientBackground: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(flex: 3),
          const Text(
            "Great! You've just taken a big step on your journey.",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Did you know that tracking your food is a scientifically proven method to being successful? It\'s called "self-monitoring" and the more consistent you are, the more likely you are to hit your goals.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Text(
                'Now, let\'s talk about your goal to ${controller.primaryGoal == 'lose' ? 'lose' : controller.primaryGoal == 'gain' ? 'gain' : 'maintain'} weight.',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.5,
                ),
              )),
          const Spacer(),
        ],
      ),
    );
  }
}
