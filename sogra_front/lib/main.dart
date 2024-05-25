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
import 'controller/login_controller.dart';
import 'controller/user_profile_controller.dart';

void main() async {
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
        initialBinding: BindingsBuilder(() {
          Get.put(UserController());
          Get.put(LoginController()); // LoginController를 초기화합니다.
          Get.lazyPut(() => UserProfileController(), fenix: true); // UserProfileController를 나중에 사용될 때 초기화합니다.
        }),
      ),
    );
  }
}
