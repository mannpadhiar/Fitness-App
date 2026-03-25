import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/home/controllers/home_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the HomeController which already has user data
    final c = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    c.userName.value.isNotEmpty
                        ? c.userName.value[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(c.userName.value,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(c.userEmail.value,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                _InfoRow(label: 'Gender', value: c.gender.value.capitalizeFirst ?? ''),
                _InfoRow(label: 'Age', value: '${c.age.value} years'),
                _InfoRow(
                    label: 'Height',
                    value: '${c.heightCm.value.toStringAsFixed(0)} cm'),
                _InfoRow(
                    label: 'Weight',
                    value: '${c.weightKg.value.toStringAsFixed(0)} kg'),
                _InfoRow(label: 'Goal', value: c.goal.value.capitalizeFirst ?? ''),
                _InfoRow(
                    label: 'Daily Target',
                    value: '${c.targetCalories.value} kcal'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: c.logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
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
