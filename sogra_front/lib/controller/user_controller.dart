import 'package:get/get.dart';

import '../model/user.dart';

// NOTE: 유저의 정보를 가져오기 위한 클래스입니다.
class UserController extends GetxController {
  var user = User(
    id: '',
    password: '',
  ).obs;

  void setUser(User newUser) {
    user.value = newUser;
  }
}
