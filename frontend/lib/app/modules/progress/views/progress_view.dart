import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/services/auth_service.dart';
import 'package:fitness_app/app/services/api_service.dart';

class ProgressController extends GetxController {
  final weightHistory = <Map<String, dynamic>>[].obs;
  final calorieSummary = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      // Fetch weight history
      final whRes = await ApiService.get('/users/$userId/weight-history');
      if (whRes.statusCode == 200) {
        final data = jsonDecode(whRes.body);
        if (data is List) {
          weightHistory.value = List<Map<String, dynamic>>.from(data);
        }
      }

      // Fetch last 7 days of calorie data
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 6));
      final fromStr =
          '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
      final toStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final csRes = await ApiService.get(
        '/users/$userId/daily-summary/range?from=$fromStr&to=$toStr',
      );
      if (csRes.statusCode == 200) {
        final data = jsonDecode(csRes.body);
        if (data is List) {
          calorieSummary.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Progress load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addWeight(double weightKg) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final res = await ApiService.post(
        '/users/$userId/weight-history',
        body: {'weightKg': weightKg},
      );
      if (res.statusCode == 201) {
        await loadData();
        Get.snackbar('Logged', '${weightKg.toStringAsFixed(1)} kg recorded',
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
}

// ============================================================
// VIEW
// ============================================================

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProgressController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: c.loadData,
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        return RefreshIndicator(
          onRefresh: c.loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Weight Chart ---
                _SectionHeader(
                  title: 'Weight History',
                  icon: Icons.monitor_weight_outlined,
                ),
                const SizedBox(height: 12),
                _WeightChart(data: c.weightHistory),
                const SizedBox(height: 8),
                // Weight stats row
                if (c.weightHistory.isNotEmpty) _WeightStats(data: c.weightHistory),
                const SizedBox(height: 16),
                // Add weight button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddWeightDialog(context, c),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Log Weight'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // --- Calorie Chart ---
                _SectionHeader(
                  title: 'Calories (Last 7 Days)',
                  icon: Icons.local_fire_department_outlined,
                ),
                const SizedBox(height: 12),
                _CalorieChart(data: c.calorieSummary),
                const SizedBox(height: 24),

                // --- Weight Log List ---
                _SectionHeader(
                  title: 'Recent Entries',
                  icon: Icons.history,
                ),
                const SizedBox(height: 12),
                ...c.weightHistory.take(10).map((entry) {
                  final date = DateTime.tryParse(entry['recordedAt'] ?? '');
                  final weight = (entry['weightKg'] ?? 0).toDouble();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          date != null
                              ? '${date.day}/${date.month}/${date.year}'
                              : '--',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          '${weight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAddWeightDialog(BuildContext context, ProgressController c) {
    final weightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Weight',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Weight',
            suffixText: 'kg',
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
              final w = double.tryParse(weightCtrl.text);
              if (w != null && w > 0) {
                Navigator.pop(ctx);
                c.addWeight(w);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WeightStats extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _WeightStats({required this.data});

  @override
  Widget build(BuildContext context) {
    final latest = (data.first['weightKg'] ?? 0).toDouble();
    final oldest = (data.last['weightKg'] ?? 0).toDouble();
    final diff = latest - oldest;
    final diffSign = diff >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              label: 'Current', value: '${latest.toStringAsFixed(1)} kg'),
          _StatItem(
              label: 'Starting', value: '${oldest.toStringAsFixed(1)} kg'),
          _StatItem(
            label: 'Change',
            value: '$diffSign${diff.toStringAsFixed(1)} kg',
            valueColor: diff < 0 ? AppColors.success : (diff > 0 ? Colors.orange : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

// --- Weight Line Chart ---
class _WeightChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _WeightChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No weight data yet',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    // Reverse so oldest is first (left side of chart)
    final sorted = data.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), (sorted[i]['weightKg'] ?? 0).toDouble()));
    }

    final weights = spots.map((s) => s.y).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxW = weights.reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: minW,
          maxY: maxW,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxW - minW) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (sorted.length / 5).ceilToDouble().clamp(1, 100),
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sorted.length) return const SizedBox();
                  final date =
                      DateTime.tryParse(sorted[idx]['recordedAt'] ?? '');
                  if (date == null) return const SizedBox();
                  return Text('${date.day}/${date.month}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (maxW - minW) / 4,
                getTitlesWidget: (value, _) {
                  return Text(value.toStringAsFixed(0),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceLight,
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  '${s.y.toStringAsFixed(1)} kg',
                  const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Calorie Bar Chart ---
class _CalorieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _CalorieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No calorie data yet',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    final maxCal = data.fold<double>(0, (prev, e) {
      final consumed = (e['totalCaloriesConsumed'] ?? 0).toDouble();
      final burned = (e['totalCaloriesBurned'] ?? 0).toDouble();
      final m = consumed > burned ? consumed : burned;
      return m > prev ? m : prev;
    });

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxCal + 200,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceLight,
              getTooltipItem: (group, gIdx, rod, rIdx) {
                final label = rIdx == 0 ? 'Consumed' : 'Burned';
                return BarTooltipItem(
                  '$label: ${rod.toY.round()} kcal',
                  const TextStyle(
                      color: AppColors.textPrimary, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (maxCal + 200) / 4,
                getTitlesWidget: (value, _) {
                  return Text('${value.round()}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  final date = DateTime.tryParse(data[idx]['date'] ?? '');
                  if (date == null) return const SizedBox();
                  return Text('${date.day}/${date.month}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10));
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxCal + 200) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            final consumed =
                (data[i]['totalCaloriesConsumed'] ?? 0).toDouble();
            final burned =
                (data[i]['totalCaloriesBurned'] ?? 0).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: consumed,
                  color: Colors.amber,
                  width: 10,
                  borderRadius: BorderRadius.circular(3),
                ),
                BarChartRodData(
                  toY: burned,
                  color: AppColors.primary,
                  width: 10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
