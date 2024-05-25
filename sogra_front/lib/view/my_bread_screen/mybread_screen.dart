import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizing/sizing.dart';
import '../../constants/image_assets.dart';
import '../../controller/login_controller.dart';
import '../../controller/user_profile_controller.dart';
import '../components/appbar_preffered_size.dart';

class MybreadScreen extends StatelessWidget {
  final UserProfileController userProfileController = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '델리만쥬',
          style: GoogleFonts.gugi(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: appBarBottomLine(),
      ),
      body: Obx(() {
        var user = userProfileController.user.value;
        if (user != null) {
          return Padding(
            padding: EdgeInsets.only(top: 0.03.sh, left: 0.02.sw, right: 0.02.sw),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfile(user.id, "초급자", ImageAssets.defaultProfile),
              ],
            ),
          );
        } else {
          userProfileController.fetchUserInfo(loginController.token.value);
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  Widget _buildProfile(String id, String rank, String url) {
    return Center( // Center 위젯으로 프로필을 가운데 정렬
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(url, width: 90, height: 90),
          SizedBox(height: 10),
          Text(
            id,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          SizedBox(height: 5),
          Text(
            rank,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
