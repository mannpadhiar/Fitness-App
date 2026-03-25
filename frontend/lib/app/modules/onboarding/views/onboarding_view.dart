import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:fitness_app/app/modules/onboarding/views/name_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/goals_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/activity_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/personal_info_view.dart';
import 'package:fitness_app/app/modules/onboarding/views/body_info_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          NamePage(),
          GoalsPage(),
          ActivityPage(),
          PersonalInfoPage(),
          BodyInfoPage(),
        ],
      ),
    );
  }
}
