import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizing/sizing.dart';
import 'package:http/http.dart' as http;
import 'package:sogra_front/constants/theme.dart';
import '../../constants/color.dart';
import '../../constants/image_assets.dart';
import '../../controller/login_controller.dart';
import '../../controller/user_profile_controller.dart';
import '../components/appbar_preffered_size.dart';

class MybreadScreen extends StatefulWidget {
  @override
  _MybreadScreenState createState() => _MybreadScreenState();
}

class _MybreadScreenState extends State<MybreadScreen> {
  final UserProfileController userProfileController = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '델리만쥐',
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
            padding: EdgeInsets.only(top: 0.03.sh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfile(user.id, "초급자", ImageAssets.defaultProfile),
                SizedBox(height: 0.02.sh),
                Container(
                  height: 0.05.sh,
                  width: double.maxFinite,
                  color: AppColor().tertiaryColor,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 5.0),
                    child: Text(
                      '내 수집빵',
                      style: textTheme().bodyMedium,
                    ),
                  ),
                ),
                SizedBox(height: 0.02.sh),
                Expanded(child: _buildBreadGrid()), // 빵 그리드 추가
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

  Widget _buildBreadGrid() {
    List<String> breadImages = [
      ImageAssets.bread1,
      ImageAssets.bread2,
      ImageAssets.bread3,
      ImageAssets.bread4,
      ImageAssets.bread5,
      ImageAssets.bread6,
      ImageAssets.bread6,
      ImageAssets.bread6,
      ImageAssets.bread6,
      ImageAssets.bread6,
      ImageAssets.bread6,
      ImageAssets.bread6,
    ];

    List<String> breadShops = [
      '성심당',
      '르뺑',
      '콜마르브레드',
      '성심당',
      '하루빵',
      '해뜨는빵집',
      '맛빵',
      '빵 가게 8',
      '빵 가게 9',
      '빵 가게 10',
      '빵 가게 11',
      '빵 가게 12',
    ];

    List<String> breadNames = [
      '오덕빵',
      '메롱빵',
      '눈물젖은빵',
      '우솝빵',
      '잠빵',
      '비밀빵', // Assuming there's a sixth bread name as a placeholder
      '비밀빵',
      '비밀빵',
      '비밀빵',
      '비밀빵',
      '비밀빵',
      '비밀빵',
    ];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: breadImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showBreadDetails(context, index + 1, breadShops[index]), // 레스토랑 ID를 사용하여 호출
            child: _buildBread(breadNames[index], breadImages[index]),
          );
        },
      ),
    );
  }

  Future<void> _showBreadDetails(BuildContext context, int restaurantId, String name) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/restaurants/$restaurantId/menus'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print(data);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: textTheme().titleMedium),
                  SizedBox(height: 10),
                  if (data.isNotEmpty)
                    Column(
                      children: data.map((menu) {
                        return Column(
                          children: [
                            Image.network(menu['image_url'], width: 100, height: 100),
                            SizedBox(height: 10),
                            Text(menu['name'], style: textTheme().bodyMedium),
                            SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    )
                  else
                    Text('No menu available', style: textTheme().bodyMedium),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('확인', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      print('Failed to load menu details');
    }
  }

  Widget _buildBread(String name, String url) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(url, width: 90, height: 90), // 이미지 크기 줄이기
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 12, // 텍스트 크기 줄이기
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
