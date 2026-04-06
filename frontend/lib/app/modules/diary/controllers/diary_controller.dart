import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/api_service.dart';

class DiaryController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final meals = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // Totals
  final totalCalories = 0.0.obs;
  final totalProtein = 0.0.obs;
  final totalCarbs = 0.0.obs;
  final totalFats = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMeals();
    ever(selectedDate, (_) => loadMeals());
  }

  String get dateString {
    final d = selectedDate.value;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadMeals() async {
    isLoading.value = true;
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final response = await ApiService.get(
        '/users/$userId/meals?date=$dateString',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          meals.value = List<Map<String, dynamic>>.from(data);
        } else {
          meals.clear();
        }
      }

      // Load daily summary for totals
      final summaryRes = await ApiService.get(
        '/users/$userId/daily-summary?date=$dateString',
      );
      if (summaryRes.statusCode == 200) {
        final summary = jsonDecode(summaryRes.body) as Map<String, dynamic>;
        totalCalories.value =
            (summary['totalCaloriesConsumed'] ?? 0).toDouble();
        totalProtein.value = (summary['totalProtein'] ?? 0).toDouble();
        totalCarbs.value = (summary['totalCarbs'] ?? 0).toDouble();
        totalFats.value = (summary['totalFats'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Load meals error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add just calories (food name defaults to "Grazing")
  Future<void> addQuickCalories(int calories) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      // First, find or create the "Grazing" food entry
      final searchRes = await ApiService.get('/foods?search=Grazing');
      String foodId;

      if (searchRes.statusCode == 200) {
        final foods = jsonDecode(searchRes.body);
        if (foods is List && foods.isNotEmpty) {
          foodId = foods.first['id'];
        } else {
          // Create the Grazing food entry (1 cal per 1g for easy math)
          final createRes = await ApiService.post('/foods', body: {
            'name': 'Grazing',
            'caloriesPer100g': 100,
            'proteinPer100g': 0,
            'carbsPer100g': 0,
            'fatsPer100g': 0,
            'source': 'user',
          });
          final created = jsonDecode(createRes.body);
          foodId = created['id'];
        }
      } else {
        // Create anyway
        final createRes = await ApiService.post('/foods', body: {
          'name': 'Grazing',
          'caloriesPer100g': 100,
          'proteinPer100g': 0,
          'carbsPer100g': 0,
          'fatsPer100g': 0,
          'source': 'user',
        });
        final created = jsonDecode(createRes.body);
        foodId = created['id'];
      }

      // Create a meal with the grazing item
      await ApiService.post('/users/$userId/meals', body: {
        'mealType': 'snack',
        'mealDate': dateString,
        'items': [
          {
            'foodId': foodId,
            'quantityGrams': calories.toDouble(),
            // 100cal per 100g → calories grams = actual calories
          },
        ],
      });

      await loadMeals();
      Get.snackbar('Added', '$calories calories logged',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  /// Add a named food with calories
  Future<void> addFood({
    required String name,
    required int calories,
    required String mealType,
    double protein = 0,
    double carbs = 0,
    double fats = 0,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      // Create food entry
      final foodRes = await ApiService.post('/foods', body: {
        'name': name,
        'caloriesPer100g': calories.toDouble(),
        'proteinPer100g': protein,
        'carbsPer100g': carbs,
        'fatsPer100g': fats,
        'source': 'user',
      });
      final food = jsonDecode(foodRes.body);

      // Create meal
      await ApiService.post('/users/$userId/meals', body: {
        'mealType': mealType,
        'mealDate': dateString,
        'items': [
          {'foodId': food['id'], 'quantityGrams': 100.0},
        ],
      });

      await loadMeals();
      Get.snackbar('Added', '$name logged ($calories cal)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  /// Delete a meal by its ID
  Future<void> deleteMeal(String mealId) async {
    try {
      final response = await ApiService.delete('/meals/$mealId');
      if (response.statusCode == 204) {
        await loadMeals();
        Get.snackbar('Deleted', 'Meal entry removed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  void previousDay() {
    selectedDate.value =
        selectedDate.value.subtract(const Duration(days: 1));
  }

  void nextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (selectedDate.value.isBefore(tomorrow)) {
      selectedDate.value =
          selectedDate.value.add(const Duration(days: 1));
    }
  }
}
