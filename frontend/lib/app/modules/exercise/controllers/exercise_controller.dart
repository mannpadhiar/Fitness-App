import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/api_service.dart';

class ExerciseController extends GetxController {
  // Exercise log from backend
  final exercises = <Map<String, dynamic>>[].obs;
  final totalCaloriesBurned = 0.0.obs;
  final isLoading = false.obs;

  // Date navigation (day-wise like diary)
  final selectedDate = DateTime.now().obs;

  String get dateString {
    final d = selectedDate.value;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // Stopwatch
  final isRunning = false.obs;
  final elapsedSeconds = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
    // Reload when date changes
    ever(selectedDate, (_) => loadExercises());
  }

  // --- Date Navigation ---
  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  }

  void nextDay() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
  }

  // --- Backend API ---
  Future<void> loadExercises() async {
    isLoading.value = true;
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final response = await ApiService.get(
        '/users/$userId/exercises?date=$dateString',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          exercises.value = List<Map<String, dynamic>>.from(data);
          // Sum calories
          double total = 0;
          for (final ex in exercises) {
            total += (ex['caloriesBurned'] ?? 0).toDouble();
          }
          totalCaloriesBurned.value = total;
        } else {
          exercises.clear();
          totalCaloriesBurned.value = 0;
        }
      }
    } catch (e) {
      debugPrint('Load exercises error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExercise({
    required String name,
    required int caloriesBurned,
    required int durationMinutes,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        debugPrint('Add exercise error: userId is null');
        return;
      }

      final response = await ApiService.post(
        '/users/$userId/exercises',
        body: {
          'name': name,
          'caloriesBurned': caloriesBurned,
          'durationMinutes': durationMinutes,
          'exerciseDate': dateString,
        },
      );

      debugPrint('Add exercise response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201) {
        // Reload from backend
        await loadExercises();

        Get.snackbar(
          'Exercise Logged',
          '$name — $caloriesBurned kcal burned',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3FB950).withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        debugPrint('Add exercise failed: ${response.statusCode} ${response.body}');
        Get.snackbar(
          'Error',
          'Failed to log exercise',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF85149).withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Add exercise error: $e');
      Get.snackbar(
        'Error',
        'Network error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF85149).withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      final response = await ApiService.delete('/exercises/$id');
      if (response.statusCode == 204) {
        await loadExercises();
      }
    } catch (e) {
      debugPrint('Delete exercise error: $e');
    }
  }

  // --- Stopwatch ---
  String get formattedTime {
    final hours = (elapsedSeconds.value ~/ 3600).toString().padLeft(2, '0');
    final minutes =
        ((elapsedSeconds.value % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds.value % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void startStopwatch() {
    if (isRunning.value) return;
    isRunning.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  void pauseStopwatch() {
    isRunning.value = false;
    _timer?.cancel();
  }

  void resetStopwatch() {
    isRunning.value = false;
    _timer?.cancel();
    elapsedSeconds.value = 0;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
