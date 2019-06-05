import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student.dart';
import 'package:heimdall/model/teacher.dart';

class ClassGroup {
  int id;
  String name;
  List<Student> students;
  List<Teacher> teachers;
  List<RollCall> rollCalls;

  ClassGroup({
    this.id,
    this.name,
    this.students,
    this.teachers,
    this.rollCalls,
  });

  factory ClassGroup.fromApi(dynamic data) {
    if (data is int) {
      return new ClassGroup(id: data);
    }
    if (data is Map<String, dynamic>) {
      return ClassGroup.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory ClassGroup.fromJson(Map<String, dynamic> json) => new ClassGroup(
    id: json["id"],
    name: json["name"],
    students: json["students"] == null ? null : new List<Student>.from(json["students"].map((x) => Student.fromApi(x))),
    teachers: json["teachers"] == null ? null : new List<Teacher>.from(json["teachers"].map((x) => Teacher.fromApi(x))),
    rollCalls: json["roll_calls"] == null ? null : new List<RollCall>.from(json["roll_calls"].map((x) => RollCall.fromApi(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "students": students == null ? null : new List<dynamic>.from(students.map((x) => x.toJson())),
    "teachers": teachers == null ? null : new List<dynamic>.from(teachers.map((x) => x.toJson())),
    "roll_calls": rollCalls == null ? null : new List<dynamic>.from(rollCalls.map((x) => x.toJson())),
  };
}
