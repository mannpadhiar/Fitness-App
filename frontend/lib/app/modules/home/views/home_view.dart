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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/playstore.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Obx(() => Text('Let\'s crush it, ${c.userName.value}!')),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() => GestureDetector(
                onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: Text(
                      c.userName.value.isNotEmpty
                          ? c.userName.value[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
      endDrawer: _AccountDrawer(controller: c),
      body: SafeArea(
        child: Obx(() {
          final remaining = c.remainingCalories;
          final target = c.targetCalories.value;
          final isOver = remaining < 0;
          final overAmount = remaining.abs();
          final progress = target > 0
              ? (isOver ? 1.0 : ((target - remaining) / target).clamp(0.0, 1.0))
              : 0.0;
          final ringColor = isOver ? AppColors.error : AppColors.primary;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & date
                Text(c.greeting,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(
                  'Today • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),            

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
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOver
                                  ? AppColors.error
                                  : const Color.fromARGB(255, 3, 192, 16),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOver
                                ? 'You\'ve exceeded your calorie goal!'
                                : 'Remaining = Goal − Food + Exercise',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOver ? AppColors.error : null,
                            ),
                          ),
                        ],
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
                            progressColor: ringColor,
                            backgroundColor: AppColors.surfaceLight,
                            center: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isOver ? '+$overAmount' : '$remaining',
                                  style: TextStyle(
                                    color: isOver
                                        ? AppColors.error
                                        : AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isOver ? 'Over' : 'Remaining',
                                  style: TextStyle(
                                    color: isOver
                                        ? AppColors.error
                                        : AppColors.textSecondary,
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
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                '/ ${c.stepsGoal.value} goal',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: c.stepsGoal.value > 0
                                      ? (c.steps.value / c.stepsGoal.value)
                                          .clamp(0.0, 1.0)
                                      : 0.0,
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
                              Text('kcal burned',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: c.stepsGoal.value > 0
                                      ? (c.steps.value / c.stepsGoal.value)
                                          .clamp(0.0, 1.0)
                                      : 0.0,
                                  backgroundColor: AppColors.surfaceLight,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.error),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              label: 'Protein',
                              amount: '${c.totalProtein.value.toStringAsFixed(1)}g',
                              color: Colors.purple),
                          const SizedBox(width: 8),
                          _MacroTile(
                              label: 'Carbs',
                              amount: '${c.totalCarbs.value.toStringAsFixed(1)}g',
                              color: Colors.amber),
                          const SizedBox(width: 8),
                          _MacroTile(
                              label: 'Fats',
                              amount: '${c.totalFats.value.toStringAsFixed(1)}g',
                              color: Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Food Recommendations ---
                Obx(() {
                  if (c.isLoadingRecommendations.value) {
                    return _RecommendationShimmer();
                  }
                  if (c.recommendationError.value.isNotEmpty &&
                      c.recommendations.isEmpty) {
                    return _RecommendationErrorCard(
                      error: c.recommendationError.value,
                      onRetry: c.fetchRecommendations,
                    );
                  }
                  if (c.recommendations.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _FoodRecommendationSection(
                    recommendations: c.recommendations,
                    onRefresh: c.fetchRecommendations,
                  );
                }),
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

// ─── Food Recommendation Section ─────────────────────────────────────────────

class _FoodRecommendationSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final VoidCallback onRefresh;

  const _FoodRecommendationSection({
    required this.recommendations,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended For You',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Based on your remaining nutrition goals',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Food cards — horizontal scroll
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _FoodRecommendationCard(
                  food: recommendations[index],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual Food Card ────────────────────────────────────────────────────

class _FoodRecommendationCard extends StatelessWidget {
  final Map<String, dynamic> food;
  final int index;

  const _FoodRecommendationCard({
    required this.food,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {

    if(food["message"] != null){
      return Container(
      width: 175,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        "No Food Available",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    }

    final name = food['food_name'] ?? 'Unknown';
    final calories = (food['calories'] ?? 0).toDouble();
    final protein = (food['protein'] ?? 0).toDouble();
    final carbs = (food['carbs'] ?? 0).toDouble();
    final fat = (food['fat'] ?? 0).toDouble();

    // Cycle through accent colors for visual variety
    final accentColors = [
      const Color(0xFF3FB950), // green
      const Color(0xFF58A6FF), // blue
      const Color(0xFFF0883E), // orange
      const Color(0xFFBC8CFF), // purple
      const Color(0xFFF85149), // red
      AppColors.accent,         // yellow
    ];
    final accent = accentColors[index % accentColors.length];

    return Container(
      width: 175,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food name
          Row(
            children: [
              Icon(Icons.lunch_dining_rounded, color: accent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Calories badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.2),
                  accent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded,
                    color: accent, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Macro row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniMacro(
                  label: 'P',
                  value: '${protein.toStringAsFixed(0)}g',
                  color: Colors.purple.shade300),
              _MiniMacro(
                  label: 'C',
                  value: '${carbs.toStringAsFixed(0)}g',
                  color: Colors.amber),
              _MiniMacro(
                  label: 'F',
                  value: '${fat.toStringAsFixed(0)}g',
                  color: Colors.green.shade400),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tiny macro chip ─────────────────────────────────────────────────────────

class _MiniMacro extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 3),
        Text(
          '$label: $value',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Shimmer loading placeholder ─────────────────────────────────────────────

class _RecommendationShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fake header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 160,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fake cards
          SizedBox(
            height: 160,
            child: Row(
              children: List.generate(
                2,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 0 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error + Retry card ──────────────────────────────────────────────────────

class _RecommendationErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _RecommendationErrorCard({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded,
              color: AppColors.error.withValues(alpha: 0.6), size: 36),
          const SizedBox(height: 10),
          Text(
            error,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
