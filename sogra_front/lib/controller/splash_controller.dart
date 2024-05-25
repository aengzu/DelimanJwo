import 'package:get/get.dart';
import 'package:sogra_front/view/auth_view/login_screen.dart';
import 'package:sogra_front/view/main_screens.dart';

// NOTE : 스플래시 화면 컨트롤러입니다. 만약 로그인이 되어있다면 메인스크린으로 이동하고
// 로그인이 되어 있지 않으면 로그인 스크린으로 이동합니다.
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 3), _loadNextScreen);
  }

  void _loadNextScreen() {
      Get.offAll(() => MainScreens());
  }
}
