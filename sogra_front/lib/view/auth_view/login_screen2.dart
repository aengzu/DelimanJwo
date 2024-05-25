import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizing/sizing.dart';
import 'package:sogra_front/view/auth_view/signup_screen.dart';
import '../../constants/color.dart';
import '../../constants/theme.dart';
import '../../controller/login_controller.dart';
import '../components/custom_btn.dart';
import '../main_screens.dart';

class LoginScreen2 extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    TextEditingController idController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('로그인하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField(
              controller: idController,
              labelText: '사용자 ID',
              hintText: '사용자 ID를 입력하세요.',
            ),
            SizedBox(height: 0.03.sh),
            _buildTextField(
              controller: passwordController,
              labelText: '비밀번호',
              hintText: '비밀번호를 입력하세요.',
              isObscure: true,
            ),
            SizedBox(height: 0.2.sh),
            Obx(() {
              return CustomButton(
                label: '로그인하기',
                onPressed: () async {
                  await loginController.login(idController.text, passwordController.text);
                  if (loginController.token.isNotEmpty) {
                    Get.to(() => MainScreens());
                  }
                },
                isLoading: loginController.isLoading.value,  // 상태 변화를 감지하여 버튼 로딩 상태 업데이트
              );
            }),
            SizedBox(height: 0.01.sh),
            TextButton(
              onPressed: () {
                Get.to(() => SignUpScreen());
              },
              child: Text(
                '회원 가입하기',
                style: TextStyle(fontSize: 16, color: AppColor().mainColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: textTheme().titleSmall,
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme().bodyMedium,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
