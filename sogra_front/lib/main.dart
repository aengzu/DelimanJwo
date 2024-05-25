import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:sizing/sizing.dart';
import 'package:sogra_front/view/auth_view/login_screen.dart';
import 'package:sogra_front/view/auth_view/login_screen2.dart';
import 'package:sogra_front/view/auth_view/signup_screen.dart';
import 'package:sogra_front/view/main_screens.dart';

import 'package:sogra_front/view/splash_view/splash_screen.dart';

import 'constants/theme.dart';
import 'controller/user_controller.dart';

void main() async {
  Get.put(UserController());
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Naver Map SDK with hardcoded client ID
  await NaverMapSdk.instance.initialize(
    clientId: 't64l7eu1tk', // Replace with your actual Naver Maps API client ID
    onAuthFailed: (error) {
      print('Auth failed: $error');
    },
  );

  runApp(const DelimanjooApp());
}

class DelimanjooApp extends StatelessWidget {
  const DelimanjooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SizingBuilder(
      builder: () => GetMaterialApp(
        theme: theme(),
        title: 'DelimanjooApp',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
