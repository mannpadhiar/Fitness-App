import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/home/controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Obx(() => Text('Hey, ${c.userName.value} 👋')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _AccountDrawer(controller: c),
      body: SafeArea(
        child: Obx(() {
          final remaining = c.remainingCalories;
          final target = c.targetCalories.value;
          final progress = target > 0
              ? ((target - remaining) / target).clamp(0.0, 1.0)
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & date
                Text(c.greeting,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Today • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),

                // --- Calorie Ring Card ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calories',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        'Remaining = Goal − Food + Exercise',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Circular ring
                          CircularPercentIndicator(
                            radius: 70,
                            lineWidth: 10,
                            percent: progress,
                            animation: true,
                            animationDuration: 800,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceLight,
                            center: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$remaining',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Remaining',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Side stats
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CalorieStat(
                                  icon: Icons.flag_outlined,
                                  iconColor: AppColors.textSecondary,
                                  label: 'Base Goal',
                                  value: '${c.targetCalories.value}',
                                ),
                                const SizedBox(height: 14),
                                _CalorieStat(
                                  icon: Icons.restaurant,
                                  iconColor: AppColors.primary,
                                  label: 'Food',
                                  value: '${c.foodCalories.value}',
                                ),
                                const SizedBox(height: 14),
                                _CalorieStat(
                                  icon: Icons.local_fire_department,
                                  iconColor: AppColors.error,
                                  label: 'Exercise',
                                  value: '${c.exerciseCalories.value}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Steps & Exercise Cards ---
                Row(
                  children: [
                    // Steps card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Steps',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Icon(Icons.directions_walk,
                                    color: AppColors.success, size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${c.steps.value}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '/ ${c.stepsGoal} goal',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (c.steps.value / c.stepsGoal)
                                    .clamp(0.0, 1.0),
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.success),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Exercise card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Exercise',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Icon(Icons.local_fire_department,
                                    color: AppColors.error, size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${c.exerciseCalories.value}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('cal burned',
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 10),
                            Text(
                              c.steps.value > 0
                                  ? '🚶 Active today'
                                  : '📡 Tracking...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Nutrition Summary ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nutrition Summary',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _MacroTile(
                              label: 'Protein', amount: '0g', color: Colors.purple),
                          const SizedBox(width: 8),
                          _MacroTile(
                              label: 'Carbs', amount: '0g', color: Colors.amber),
                          const SizedBox(width: 8),
                          _MacroTile(
                              label: 'Fats', amount: '0g', color: Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Quick Actions ---
                Text('Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ActionCard(
                          icon: Icons.fastfood,
                          title: 'Log Meal',
                          subtitle: 'Add food'),
                      _ActionCard(
                          icon: Icons.timer,
                          title: 'Workout',
                          subtitle: 'Start'),
                      _ActionCard(
                          icon: Icons.water_drop,
                          title: 'Water',
                          subtitle: 'Log intake'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// --- Calorie stat row ---
class _CalorieStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _CalorieStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

// --- Macro tile ---
class _MacroTile extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _MacroTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(amount,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// --- Quick action card ---
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// --- Account Drawer ---
class _AccountDrawer extends StatelessWidget {
  final HomeController controller;

  const _AccountDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          controller.userName.value.isNotEmpty
                              ? controller.userName.value[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(controller.userName.value,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Goal: ${controller.goal.value.capitalizeFirst}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border),

                // Account details
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: 'Gender',
                  value: controller.gender.value.capitalizeFirst ?? '',
                ),
                _DrawerItem(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: '${controller.age.value} years',
                ),
                _DrawerItem(
                  icon: Icons.height,
                  label: 'Height',
                  value: '${controller.heightCm.value.toStringAsFixed(0)} cm',
                ),
                _DrawerItem(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: '${controller.weightKg.value.toStringAsFixed(0)} kg',
                ),
                _DrawerItem(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Daily Target',
                  value: '${controller.targetCalories.value} kcal',
                ),
                _DrawerItem(
                  icon: Icons.location_on_outlined,
                  label: 'Country',
                  value: controller.country.value.isNotEmpty
                      ? controller.country.value
                      : 'Not set',
                ),

                const Spacer(),

                // Logout button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Logout',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
