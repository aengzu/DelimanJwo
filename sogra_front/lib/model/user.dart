class User {
  final String id;
  String? rank;
  final String password;

  User({
    required this.id,
    this.rank,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      rank: json['rank'] ?? '', // 'rank'가 null일 경우 빈 문자열로 처리
      password: json['password'] ?? '',
    );
  }

  Map<String, String> toJson() {
    return {
      'id': id,
      'password': password,
    };
  }
}
