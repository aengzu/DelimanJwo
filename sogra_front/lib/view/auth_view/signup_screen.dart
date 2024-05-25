import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sizing/sizing.dart';
import 'package:sogra_front/constants/theme.dart';

import '../../controller/signup_controller.dart';
import '../components/custom_btn.dart';

class SignUpScreen extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('회원가입', style: textTheme().titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          return ListView(
            children: [
              _buildTextField(
                controller: signUpController.memberIdController,
                labelText: '사용자 ID',
                hintText: '사용자 ID를 입력하세요.',
              ),
              SizedBox(height: 0.03.sh),
              _buildTextField(
                controller: signUpController.passwordController,
                labelText: '비밀번호',
                hintText: '비밀번호를 입력하세요.',
                isObscure: true,
              ),
              SizedBox(height: 0.2.sh),
              CustomButton(
                label: signUpController.isLoading.value
                    ? '회원가입 중...'
                    : '회원가입하기',
                onPressed: signUpController.isLoading.value
                    ? null
                    : () {
                  _signUp();
                },
              ),
            ],
          );
        }),
          ),
            );
  }

  Future<void> _signUp() async {
    await signUpController.signUp(
      signUpController.memberIdController.text,
      signUpController.passwordController.text,
    );
    if (signUpController.errorMessage.value.isNotEmpty) {
      Get.snackbar('Error', signUpController.errorMessage.value,
          snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar('Success', '회원가입이 성공적으로 완료되었습니다.',
          snackPosition: SnackPosition.TOP);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 라벨과 텍스트 필드를 왼쪽 정렬
      children: [
        Text(
          labelText,
          style: textTheme().titleSmall,
        ),
        SizedBox(height: 8), // 라벨과 텍스트 필드 사이의 간격 조정
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme().bodyMedium,
            contentPadding:
            EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
