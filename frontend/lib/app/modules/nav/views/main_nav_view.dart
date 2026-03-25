import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/home/views/home_view.dart';
import 'package:fitness_app/app/modules/diary/views/diary_view.dart';
import 'package:fitness_app/app/modules/progress/views/progress_view.dart';
import 'package:fitness_app/app/modules/profile/views/profile_view.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    // Index 2 is the center FAB — open bottom sheet instead of switching
    if (index == 2) return;
    currentIndex.value = index;
  }
}

class MainNavView extends StatelessWidget {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavController());

    final pages = const [
      HomeView(),
      DiaryView(),
      SizedBox(), // Placeholder — center FAB handles this
      ProgressView(),
      ProfileView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    activeIcon: Icons.space_dashboard_rounded,
                    label: 'Dashboard',
                    isActive: controller.currentIndex.value == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                  _NavItem(
                    icon: Icons.book_outlined,
                    activeIcon: Icons.book_rounded,
                    label: 'Diary',
                    isActive: controller.currentIndex.value == 1,
                    onTap: () => controller.changeTab(1),
                  ),
                  // Center FAB button
                  GestureDetector(
                    onTap: () => _showQuickAddSheet(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF1A6FEF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.show_chart_rounded,
                    activeIcon: Icons.show_chart_rounded,
                    label: 'Progress',
                    isActive: controller.currentIndex.value == 3,
                    onTap: () => controller.changeTab(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outlined,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    isActive: controller.currentIndex.value == 4,
                    onTap: () => controller.changeTab(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Quick Add', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            _QuickAddOption(
              icon: Icons.restaurant,
              label: 'Log Food',
              subtitle: 'Add a meal or snack',
              onTap: () {
                Navigator.pop(context);
                // Navigate to diary tab
                final navCtrl = Get.find<MainNavController>();
                navCtrl.changeTab(1);
              },
            ),
            const SizedBox(height: 12),
            _QuickAddOption(
              icon: Icons.local_fire_department,
              label: 'Quick Calories',
              subtitle: 'Just add calorie count',
              onTap: () {
                Navigator.pop(context);
                final navCtrl = Get.find<MainNavController>();
                navCtrl.changeTab(1);
              },
            ),
            const SizedBox(height: 12),
            _QuickAddOption(
              icon: Icons.directions_walk,
              label: 'Log Exercise',
              subtitle: 'Track a workout',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _QuickAddOption(
              icon: Icons.water_drop,
              label: 'Log Water',
              subtitle: 'Track water intake',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAddOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
