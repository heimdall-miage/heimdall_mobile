

class User {
  static final String STUDENT = 'Student';
  static final String TEACHER = 'Teacher';
  final String username;
  String type;
  String token;
  final String refreshToken;

  User({this.username, this.type, this.token, this.refreshToken});

  factory User.fromApiJson(String username, Map<String, dynamic> json) {
    return User(
      username: username,
      type: json['type'],
      token: json['token'],
      refreshToken: json['refresh_token'],
    );
  }

  factory User.fromStoredJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'refresh_token': refreshToken,
  };
}