import 'package:get/get.dart';
import 'package:fitness_app/app/services/data_preload_service.dart';

class SplashController extends GetxController {
  final isLoadingComplete = false.obs;
  String _resolvedRoute = '/sign-in';

  String get resolvedRoute => _resolvedRoute;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final preloadService = Get.find<DataPreloadService>();
    _resolvedRoute = await preloadService.preloadAndResolveRoute();

    // Signal loading is done — view will play the slide-up animation
    isLoadingComplete.value = true;
  }

  /// Called by the view after the slide-up animation finishes
  void navigateToApp() {
    Get.offAllNamed(_resolvedRoute);
  }
}
