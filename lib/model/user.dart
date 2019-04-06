

class User {
  static final String STUDENT = 'Student';
  static final String TEACHER = 'Teacher';
  final String username;
  String type;

  User({this.username, this.type});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      type: json['type'],
    );
  }
}