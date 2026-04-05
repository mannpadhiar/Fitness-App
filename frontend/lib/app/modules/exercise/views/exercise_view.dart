import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/exercise/controllers/exercise_controller.dart';

class ExerciseView extends StatelessWidget {
  const ExerciseView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ExerciseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== STOPWATCH SECTION =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Time display — large digits like reference
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Hours
                          Text(
                            (c.elapsedSeconds.value ~/ 3600)
                                .toString()
                                .padLeft(2, '0'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              ' : ',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 36,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          // Minutes
                          Text(
                            ((c.elapsedSeconds.value % 3600) ~/ 60)
                                .toString()
                                .padLeft(2, '0'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              ' . ',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          // Seconds
                          Text(
                            (c.elapsedSeconds.value % 60)
                                .toString()
                                .padLeft(2, '0'),
                            style: TextStyle(
                              color: AppColors.textPrimary
                                  .withValues(alpha: 0.7),
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Control buttons — Reset (grey pill) + Start/Stop (colored pill)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset button — grey pill
                          GestureDetector(
                            onTap: c.resetStopwatch,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded,
                                      color: AppColors.textSecondary,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Reset',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Start/Stop button — colored pill
                          GestureDetector(
                            onTap: c.isRunning.value
                                ? c.pauseStopwatch
                                : c.startStopwatch,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 12),
                              decoration: BoxDecoration(
                                color: c.isRunning.value
                                    ? AppColors.error
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    c.isRunning.value
                                        ? Icons.stop_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    c.isRunning.value ? 'Stop' : 'Start',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Log button — only show when timer has value
                      if (c.elapsedSeconds.value > 0 && !c.isRunning.value) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showLogFromTimerDialog(
                              context, c, c.elapsedSeconds.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                const Text(
                                  'Log Workout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ===== DATE NAVIGATION =====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: AppColors.textPrimary),
                        onPressed: c.previousDay,
                      ),
                      Text(
                        '${c.selectedDate.value.day}/${c.selectedDate.value.month}/${c.selectedDate.value.year}',
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
                const SizedBox(height: 16),

                // ===== CALORIES BURNED =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Burned',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${c.totalCaloriesBurned.value.round()}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'kcal',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddExerciseDialog(context, c),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ===== EXERCISE LOG =====
                if (c.isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (c.exercises.isNotEmpty) ...[
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...c.exercises.map((ex) => Dismissible(
                        key: Key(ex['id'] ?? ''),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        onDismissed: (_) =>
                            c.deleteExercise(ex['id'] as String),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.directions_run_rounded,
                                  color: AppColors.success,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex['name'] as String? ?? '',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${ex['durationMinutes'] ?? 0} min',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${((ex['caloriesBurned'] ?? 0) as num).round()}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Text(
                                    'kcal',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ] else ...[
                  // Empty state
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(Icons.directions_run_rounded,
                              size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No exercises logged',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Use the timer or tap + to log a workout',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          )),
    );
  }

  void _showAddExerciseDialog(BuildContext context, ExerciseController c) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final durCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Exercise',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Exercise name',
                  prefixIcon: Icon(Icons.fitness_center,
                      color: AppColors.textMuted, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Duration',
                  suffixText: 'min',
                  prefixIcon:
                      Icon(Icons.timer, color: AppColors.textMuted, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Calories burned',
                  suffixText: 'kcal',
                  prefixIcon: Icon(Icons.local_fire_department,
                      color: AppColors.textMuted, size: 20),
                ),
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
            onPressed: () async{
              final name = nameCtrl.text.trim();
              final cal = int.tryParse(calCtrl.text);
              final dur = int.tryParse(durCtrl.text) ?? 0;
              if (name.isNotEmpty && cal != null && cal > 0) {
                Navigator.pop(ctx);
                await c.addExercise(
                  name: name,
                  caloriesBurned: cal,
                  durationMinutes: dur,
                );
              }
            },
            style:
                ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  void _showLogFromTimerDialog(
      BuildContext context, ExerciseController c, int totalSeconds) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final minutes = totalSeconds ~/ 60;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Workout',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Duration display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Duration: ${minutes > 0 ? "$minutes min " : ""}${totalSeconds % 60}s',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Exercise name (e.g. Running)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Calories burned',
                  suffixText: 'kcal',
                ),
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
            onPressed: () async{
              final name = nameCtrl.text.trim();
              final cal = int.tryParse(calCtrl.text);
              if (name.isNotEmpty && cal != null && cal > 0) {
                Navigator.pop(ctx);
                await c.addExercise(
                  name: name,
                  caloriesBurned: cal,
                  durationMinutes: minutes,
                );
                c.resetStopwatch();
              }
            },
            style:
                ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }
}
