import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/home/views/home_view.dart';
import 'package:fitness_app/app/modules/diary/views/diary_view.dart';
import 'package:fitness_app/app/modules/progress/views/progress_view.dart';
import 'package:fitness_app/app/modules/exercise/views/exercise_view.dart';
import 'package:fitness_app/app/modules/diary/controllers/diary_controller.dart';
import 'package:fitness_app/app/services/food_recognition_service.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
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
      SizedBox(),
      ProgressView(),
      ExerciseView(),
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
                    icon: Icons.fitness_center_outlined,
                    activeIcon: Icons.fitness_center,
                    label: 'Exercise',
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
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

                // --- Scan Food ---
                _QuickAddOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Scan Food',
                  subtitle: 'Take a photo or pick from gallery',
                  iconColor: AppColors.success,
                  onTap: () {
                    // Close the quick add sheet first
                    Navigator.pop(context);
                    // Use a small delay to ensure the sheet is fully dismissed
                    // before opening the next one (avoids stale context)
                    Future.delayed(const Duration(milliseconds: 200), () {
                      _showImageSourceSheet();
                    });
                  },
                ),
                const SizedBox(height: 12),

                _QuickAddOption(
                  icon: Icons.restaurant,
                  label: 'Log Food',
                  subtitle: 'Add a meal or snack',
                  onTap: () {
                    Navigator.pop(context);
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
        ),
      ),
    );
  }

  // --- Image Source Picker (uses Get.bottomSheet — no context dependency) ---
  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
            Text('Choose Photo Source',
                style: Get.textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Get.back(); // close sheet
                      _pickImageAndRecognize(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Get.back(); // close sheet
                      _pickImageAndRecognize(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Pick Image + Call API + Show Result ---
  Future<void> _pickImageAndRecognize(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    // Show loading dialog using Get.dialog (context-independent)
    Get.dialog(
      const _RecognizingDialog(),
      barrierDismissible: false,
    );

    try {
      final result = await FoodRecognitionService.recognizeFood(imageFile);

      // Dismiss loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Small delay to let dialog dismiss animation complete
      await Future.delayed(const Duration(milliseconds: 150));

      // Show editable result sheet
      _showFoodResultSheet(result, imageFile);
    } catch (e) {
      // Dismiss loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Recognition Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // --- Editable Food Result Bottom Sheet ---
  void _showFoodResultSheet(Map<String, dynamic> result, File imageFile) {
    final nameCtrl = TextEditingController(text: result['name'] as String);
    final calCtrl = TextEditingController(text: '${result['calories']}');
    final proteinCtrl = TextEditingController(text: '${result['protein']}');
    final carbsCtrl = TextEditingController(text: '${result['carbs']}');
    final fatsCtrl = TextEditingController(text: '${result['fats']}');
    final quantityCtrl = TextEditingController(text: '100');

    // Auto-select meal type based on current time
    final hour = DateTime.now().hour;
    String mealType;
    if (hour < 11) {
      mealType = 'breakfast';
    } else if (hour < 15) {
      mealType = 'lunch';
    } else if (hour < 20) {
      mealType = 'dinner';
    } else {
      mealType = 'snack';
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) => Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 24),
                      const SizedBox(width: 10),
                      Text('Food Detected',
                          style: Get.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Review and edit the details below',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Food image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Food name
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      prefixIcon: Icon(Icons.restaurant,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meal type selector
                  DropdownButtonFormField<String>(
                    value: mealType,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Meal Type',
                      prefixIcon: Icon(Icons.schedule,
                          color: AppColors.textMuted, size: 20),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'breakfast', child: Text('🌅  Breakfast')),
                      DropdownMenuItem(
                          value: 'lunch', child: Text('☀️  Lunch')),
                      DropdownMenuItem(
                          value: 'dinner', child: Text('🌙  Dinner')),
                      DropdownMenuItem(
                          value: 'snack', child: Text('🍿  Snack')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => mealType = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Quantity
                  TextField(
                    controller: quantityCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      suffixText: 'grams',
                      prefixIcon: Icon(Icons.scale,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nutrition grid
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nutrition (per 100g)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _NutritionField(
                                controller: calCtrl,
                                label: 'Calories',
                                suffix: 'kcal',
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _NutritionField(
                                controller: proteinCtrl,
                                label: 'Protein',
                                suffix: 'g',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _NutritionField(
                                controller: carbsCtrl,
                                label: 'Carbs',
                                suffix: 'g',
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _NutritionField(
                                controller: fatsCtrl,
                                label: 'Fats',
                                suffix: 'g',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            final calories = int.tryParse(calCtrl.text) ?? 0;
                            final protein =
                                double.tryParse(proteinCtrl.text) ?? 0;
                            final carbs =
                                double.tryParse(carbsCtrl.text) ?? 0;
                            final fats =
                                double.tryParse(fatsCtrl.text) ?? 0;

                            if (name.isEmpty || calories <= 0) {
                              Get.snackbar(
                                'Missing Info',
                                'Please enter food name and calories',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    AppColors.error.withValues(alpha: 0.8),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            // Close the result sheet
                            Get.back();

                            // Add to diary
                            final diaryCtrl = Get.find<DiaryController>();
                            diaryCtrl.addFood(
                              name: name,
                              calories: calories,
                              mealType: mealType,
                              protein: protein,
                              carbs: carbs,
                              fats: fats,
                            );

                            // Switch to diary tab
                            final navCtrl = Get.find<MainNavController>();
                            navCtrl.changeTab(1);
                          },
                          icon:
                              const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Add to Diary'),
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// --- Nav Item ---
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

// --- Quick Add Option ---
class _QuickAddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _QuickAddOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
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
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
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

// --- Recognizing Dialog ---
class _RecognizingDialog extends StatelessWidget {
  const _RecognizingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Analyzing Food...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our AI is identifying your food',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Image Source Button ---
class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Nutrition input field ---
class _NutritionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final Color color;

  const _NutritionField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: TextStyle(color: color, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}
