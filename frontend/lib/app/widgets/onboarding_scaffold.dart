import 'package:flutter/material.dart';
import 'package:fitness_app/app/theme/app_theme.dart';

class OnboardingScaffold extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final Widget child;
  final bool isNextEnabled;
  final bool useGradientBackground;
  final String nextLabel;

  const OnboardingScaffold({
    super.key,
    required this.title,
    required this.currentStep,
    this.totalSteps = 4,
    required this.onNext,
    this.onBack,
    required this.child,
    this.isNextEnabled = true,
    this.useGradientBackground = false,
    this.nextLabel = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _ProgressBar(
              currentStep: currentStep,
              totalSteps: totalSteps,
              useGradient: useGradientBackground,
            ),
          ),
          const SizedBox(height: 24),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          ),
          // Navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                if (onBack != null)
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: useGradientBackground
                            ? Colors.black26
                            : AppColors.border,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: useGradientBackground
                            ? Colors.black87
                            : AppColors.textPrimary,
                      ),
                      onPressed: onBack,
                    ),
                  ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isNextEnabled ? onNext : null,
                    style: useGradientBackground
                        ? ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: Colors.white38,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          )
                        : null,
                    child: Text(nextLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (useGradientBackground) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientEnd,
                AppColors.gradientStart,
              ],
            ),
          ),
          child: content,
        ),
      );
    }

    return Scaffold(body: content);
  }
}

class _ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool useGradient;

  const _ProgressBar({
    required this.currentStep,
    required this.totalSteps,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? (useGradient ? Colors.black87 : AppColors.primary)
                  : (useGradient
                      ? Colors.black26
                      : AppColors.surfaceLight),
            ),
          ),
        );
      }),
    );
  }
}
