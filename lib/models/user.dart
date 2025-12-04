/// User 모델
class User {
  final int id;
  final String username;

  User({
    required this.id,
    required this.username,
  });

  /// JSON에서 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}