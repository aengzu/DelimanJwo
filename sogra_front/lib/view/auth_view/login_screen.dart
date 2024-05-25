// NOTE: splash_screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizing/sizing.dart';
import 'package:sogra_front/constants/color.dart';
import 'package:sogra_front/constants/image_assets.dart';
import 'package:sogra_front/controller/splash_controller.dart';
import 'package:sogra_front/view/auth_view/signup_screen.dart';
import 'package:sogra_front/view/components/custom_btn.dart';

import 'login_screen2.dart';



class LoginScreen extends StatelessWidget {
  // NOTE : 스플래시 스크린 UI 구현부입니다.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(ImageAssets.character, height: 0.17.sh, width: 0.36.sw, fit: BoxFit.fill),
              SizedBox(height: 0.01.sh,),
              Image.asset(ImageAssets.logoYellow, height: 0.1.sh, width: 0.6.sw, fit: BoxFit.fill,),
              SizedBox(height: 0.03.sh,),
              CustomButton(label: "로그인하기", onPressed: (){Get.to(LoginScreen2());}),
              SizedBox(height: 0.02.sh),
              CustomButton(label: "가입하기", onPressed: (){Get.to(SignUpScreen());}),
            ],
          ),),

      ),
    );
  }
}
