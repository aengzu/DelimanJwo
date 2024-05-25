import 'package:get/get.dart';
import '../model/user.dart';

class UserController extends GetxController {
  var user = User(
    id: '', password: '',
  ).obs;

  void setUser(User newUser) {
    user.value = newUser;
    print('User set: ${user.value.id}, ${user.value.rank}'); // 디버그 로그 추가
  }
}
