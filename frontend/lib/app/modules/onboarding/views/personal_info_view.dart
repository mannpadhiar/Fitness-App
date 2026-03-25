import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/widgets/onboarding_scaffold.dart';
import 'package:fitness_app/app/modules/onboarding/controllers/onboarding_controller.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final ageTextController = TextEditingController(text: controller.age.value);

    final countries = [
      'India', 'United States', 'United Kingdom', 'Canada',
      'Australia', 'Germany', 'France', 'Japan', 'Brazil', 'Other',
    ];

    return Obx(() => OnboardingScaffold(
          title: 'You',
          currentStep: 3,
          totalSteps: OnboardingController.totalSteps,
          onNext: controller.nextPage,
          onBack: controller.previousPage,
          isNextEnabled: controller.isPersonalInfoValid,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us a little bit about yourself',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please select which sex we should use to calculate your calorie needs:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Male',
                        isSelected: controller.gender.value == 'Male',
                        onTap: () => controller.gender.value = 'Male',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        label: 'Female',
                        isSelected: controller.gender.value == 'Female',
                        onTap: () => controller.gender.value = 'Female',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('How old are you?',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: ageTextController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (value) => controller.age.value = value,
                  decoration: const InputDecoration(hintText: 'Enter your age'),
                ),
                const SizedBox(height: 4),
                Text(
                  'We use sex at birth and age to calculate an accurate goal for you.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                Text('Where do you live?',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.country.value.isEmpty
                          ? null
                          : controller.country.value,
                      hint: const Text('Select country',
                          style: TextStyle(color: AppColors.textMuted)),
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 16),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.textMuted),
                      items: countries.map((c) {
                        return DropdownMenuItem<String>(
                            value: c, child: Text(c));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          controller.country.value = v;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ));
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                          radius: 4, backgroundColor: Colors.white))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
