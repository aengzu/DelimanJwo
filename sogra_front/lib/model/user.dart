class User {
  final String memberId;
  String? rank;
  final String password;

  User({
    required this.memberId,
    this.rank,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      memberId: json['memberId'],
      password: json['password'],
    );
  }

  Map<String, String> toJson() {
    return {
      'memberId': memberId,
      'password': password,
    };
  }
}
