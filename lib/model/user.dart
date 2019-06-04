import 'package:heimdall/model/student.dart';
import 'package:heimdall/model/teacher.dart';

abstract class User {
  static final String STUDENT = 'Student';
  static final String TEACHER = 'Teacher';
  final int id;
  final String username;
  String firstname;
  String lastname;
  DateTime lastLogin;
  get type;
  String get fullName => firstname + ' ' + lastname;

  User({this.id, this.username, this.firstname, this.lastname, this.lastLogin});

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['type'] == STUDENT) {
      return Student.fromJson(json);
    } else if (json['type'] == TEACHER) {
      return Teacher.fromJson(json);
    }
    throw new Exception('User type not supported.');
  }

  Map<String, dynamic> toJson();
}