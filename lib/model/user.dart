class User {
  static final String STUDENT = 'Student';
  static final String TEACHER = 'Teacher';
  final String username;
  String plainPassword;
  String type;

  User({this.username, this.type});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'username': username,
    };
    if (plainPassword != null) {
      data['plainPassword'] = plainPassword;
    }
    return data;
  }
}