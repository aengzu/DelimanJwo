import 'package:get/get.dart';
import '../service/auth_service.dart';
import 'user_profile_controller.dart';  // Import UserProfileController

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  RxString token = ''.obs;
  var isLoading = false.obs;

  Future<void> login(String id, String password) async {
    isLoading.value = true;
    try {
      print('Attempting to login with ID: $id and Password: $password');
      token.value = await _authService.login(id, password);
      print('Login successful, token: ${token.value}');

      // UserProfileController 인스턴스 생성 및 사용자 정보 불러오기
      Get.lazyPut(() => UserProfileController());
      Get.find<UserProfileController>().fetchUserInfo(token.value);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
      print('Login failed with error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
