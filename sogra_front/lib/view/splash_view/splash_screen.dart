// NOTE: splash_screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizing/sizing.dart';
import 'package:sogra_front/constants/color.dart';
import 'package:sogra_front/constants/image_assets.dart';
import 'package:sogra_front/controller/splash_controller.dart';



class SplashScreen extends StatelessWidget {
  // NOTE : 스플래시 스크린 UI 구현부입니다.


  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: AppColor().mainColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 0.03.sw),
              Image.asset(ImageAssets.logo, height: 0.4.sh, width: 0.6.sw),
            ],
          ),),

      ),
    );
  }
}
