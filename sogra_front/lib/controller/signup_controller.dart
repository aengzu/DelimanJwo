import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../constants/base_url.dart';
import '../model/user.dart';
import '../view/main_screens.dart';


class SignUpController extends GetxController {
  final String baseUrl = AppUrl.baseUrl;
  final String _apiUrl;

  // TODO : 회원가입 API 로 수정
  SignUpController() : _apiUrl = "${AppUrl.baseUrl}auth/";

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  TextEditingController memberIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String deviceKey = '';

  @override
  void onInit() {
    super.onInit();
  }


  Future<void> signUp(String id, String password) async {
    User user = User(
        id: id,
        password: password
    );

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Signup successful
        Get.to(MainScreens());

      } else {
        errorMessage.value = 'Failed to sign up: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to sign up: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
