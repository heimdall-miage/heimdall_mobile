import 'package:heimdall/model/student.dart';
import 'package:heimdall/model/teacher.dart';

class User {
  static final String STUDENT = 'Student';
  static final String TEACHER = 'Teacher';
  final String username;
  String plainPassword;

  User({this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['type'] == STUDENT) {
      return Student(
        username: json['username'],
        photo: json['photo'],
      );
    } else if (json['type'] == TEACHER) {
      return Teacher(
        username: json['username'],
      );
    }
    throw new Exception('User type not supported.');
  }
}