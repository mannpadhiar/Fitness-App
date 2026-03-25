import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/diary/controllers/diary_controller.dart';

class DiaryView extends StatelessWidget {
  const DiaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DiaryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final d = c.selectedDate.value;
        final isToday = _isSameDay(d, DateTime.now());
        final dayLabel = isToday
            ? 'Today'
            : '${d.day}/${d.month}/${d.year}';

        return Column(
          children: [
            // Date selector bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: AppColors.textPrimary),
                    onPressed: c.previousDay,
                  ),
                  Text(
                    dayLabel,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.textPrimary),
                    onPressed: c.nextDay,
                  ),
                ],
              ),
            ),

            // Calorie summary card
            Container(
              margin: const EdgeInsets.all(16),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        label: 'Calories',
                        value: '${c.totalCalories.value.round()}',
                        unit: 'kcal',
                        color: AppColors.primary,
                      ),
                      _SummaryItem(
                        label: 'Protein',
                        value: '${c.totalProtein.value.round()}',
                        unit: 'g',
                        color: Colors.purple,
                      ),
                      _SummaryItem(
                        label: 'Carbs',
                        value: '${c.totalCarbs.value.round()}',
                        unit: 'g',
                        color: Colors.amber,
                      ),
                      _SummaryItem(
                        label: 'Fats',
                        value: '${c.totalFats.value.round()}',
                        unit: 'g',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Meals list
            Expanded(
              child: c.isLoading.value
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : c.meals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant_menu,
                                  size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text('No meals logged yet',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              const Text('Tap + to add food or calories',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: c.meals.length,
                          itemBuilder: (context, index) {
                            final meal = c.meals[index];
                            final mealType =
                                (meal['mealType'] ?? 'snack') as String;
                            final items =
                                (meal['items'] as List<dynamic>?) ?? [];
                            return _MealCard(
                                mealType: mealType, items: items);
                          },
                        ),
            ),

            // Add buttons at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddFoodDialog(context, c),
                      icon: const Icon(Icons.restaurant, size: 18),
                      label: const Text('Add Food'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showQuickCaloriesDialog(context, c),
                      icon: const Icon(Icons.bolt, size: 18),
                      label: const Text('Quick Cal'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showQuickCaloriesDialog(BuildContext context, DiaryController c) {
    final calorieCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quick Add Calories',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'These calories will be logged as "Grazing".',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: calorieCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Calories',
                suffixText: 'kcal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final cal = int.tryParse(calorieCtrl.text);
              if (cal != null && cal > 0) {
                Navigator.pop(ctx);
                c.addQuickCalories(cal);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, DiaryController c) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    String mealType = 'snack';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Food',
              style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Food name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Calories',
                    suffixText: 'kcal',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: mealType,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Meal type',
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                    DropdownMenuItem(value: 'snack', child: Text('Snack')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => mealType = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final cal = int.tryParse(calCtrl.text);
                if (name.isNotEmpty && cal != null && cal > 0) {
                  Navigator.pop(ctx);
                  c.addFood(
                    name: name,
                    calories: cal,
                    mealType: mealType,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 40),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Summary Item ---
class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(unit,
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

// --- Meal Card ---
class _MealCard extends StatelessWidget {
  final String mealType;
  final List<dynamic> items;

  const _MealCard({required this.mealType, required this.items});

  IconData get _icon {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType[0].toUpperCase() + mealType.substring(1),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  '${items.length} item${items.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
