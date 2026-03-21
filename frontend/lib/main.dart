import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/routes/app_routes.dart';
import 'package:fitness_app/app/routes/app_pages.dart';
import 'package:fitness_app/app/modules/home/views/home_view.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.signIn,
      getPages: [
        ...AppPages.pages,
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeView(),
        ),
      ],
    );
  }
}
