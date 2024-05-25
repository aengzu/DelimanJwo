import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sogra_front/controller/user_controller.dart';
import '../constants/base_url.dart';
import '../model/user.dart';
import '../view/main_screens.dart';

class LoginController extends GetxController {
  final String _apiUrl;

  LoginController() : _apiUrl = "${AppUrl.baseUrl}auth/token";

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  TextEditingController memberIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login(String id, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded', // 변경: OAuth2PasswordRequestForm은 x-www-form-urlencoded 형식을 사용
        },
        body: {
          'username': id, // OAuth2PasswordRequestForm은 username 필드를 사용
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // 로그인 성공
        var userJson = jsonDecode(response.body);
        User user = User.fromJson(userJson);
        Get.find<UserController>().setUser(user);
        Get.to(() => MainScreens());
      } else {
        errorMessage.value = 'Failed to login: ${response.statusCode}';
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.TOP);
        print(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to login: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

}
