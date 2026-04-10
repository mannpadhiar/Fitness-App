import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/app/theme/app_theme.dart';
import 'package:fitness_app/app/modules/splash/controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final SplashController _controller;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SplashController>();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );

    ever(_controller.isLoadingComplete, (complete) {
      if (complete) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _slideController.forward().then((_) {
            _controller.navigateToApp();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SlideTransition(
        position: _slideAnimation,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              // ====== DARK SECTION (80%) ======
              Expanded(
                flex: 80,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/playstore.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // App name

                        Image.asset(
                            'assets/splish_screen.png',
                            width: 250,
                            // height: 200,
                            fit: BoxFit.cover,
                          ),

                        const SizedBox(height: 2),
                        Text(
                          'Push harder than yesterday',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Loading indicator
                        Obx(
                          () => _controller.isLoadingComplete.value
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 44,
                                )
                              : const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                    backgroundColor: Color(0x20FFFFFF),
                                  ),
                                ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),

              // ====== BLUE SECTION (20%) ======
              Expanded(
                flex: 20,
                child: Container(
                  width: double.infinity,
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Track calories · Count steps · Stay fit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI-powered nutrition & fitness tracking',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
