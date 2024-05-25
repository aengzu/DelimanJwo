import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/base_url.dart';

class AuthService {
  String? _token;

  get baseUrl => AppUrl.baseUrl;

  Future<String> login(String username, String password) async {
    final response = await http.post(
        Uri.parse('${baseUrl}auth/token'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'username': Uri.encodeComponent(username), // 필드명 변경
          'password': Uri.encodeComponent(password)
        }
    );

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      _token = jsonDecode(decodedBody)['access_token'];
      print('Server response: $decodedBody'); // 디버깅 로그 추가
      return _token!;
    } else {
      print('Failed to login with status code: ${response.statusCode}, body: ${response.body}'); // 디버깅 로그 추가
      throw Exception('Failed to login with status code: ${response.statusCode}');
    }
  }

  Future<String> register(String id, String password) async {
    final response = await http.post(
        Uri.parse('${baseUrl}auth/'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id": id,
          "password": password,
        })
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['access_token'];
    } else {
      throw Exception('Failed to register with status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String token) async {
    final response = await http.get(
        Uri.parse('${baseUrl}users/me'),
        headers: {'Authorization': 'Bearer $token'}
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch user info: Status code ${response.statusCode}, body: ${response.body}');
    }
  }

  bool isLoggedIn() => _token != null;
}
