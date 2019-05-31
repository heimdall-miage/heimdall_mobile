import 'package:flutter/material.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/model/teacher.dart';

class RollCall {
  static const STATUS_DRAFT = 'draft';
  static const STATUS_VALID = 'valid';
  static const STATUS_CANCEL = 'cancel';

  int id;
  ClassGroup classGroup;
  Teacher teacher;
  List<StudentPresence> studentPresences;
  DateTime dateStart;
  DateTime dateEnd;
  String status = RollCall.STATUS_DRAFT;

  RollCall({
    this.id,
    this.classGroup,
    this.teacher,
    this.studentPresences,
    this.dateStart,
    this.dateEnd,
    this.status,
  }) {
    if (dateStart == null) dateStart = new DateTime.now();
    if (dateEnd == null) dateEnd = new DateTime.now().add(new Duration(hours: 1));
    if (studentPresences == null) studentPresences = new List<StudentPresence>();
  }

  set startAt(TimeOfDay startAt) {
    final now = new DateTime.now();
    dateStart = new DateTime(now.year, now.month, now.day, startAt.hour, startAt.minute);
  }
  TimeOfDay get startAt => dateStart == null ? null : new TimeOfDay(hour: dateStart.hour, minute: dateStart.minute);

  set endAt(TimeOfDay endAt) {
    final now = new DateTime.now();
    dateEnd = new DateTime(now.year, now.month, now.day, endAt.hour, endAt.minute);
  }
  TimeOfDay get endAt => dateEnd == null ? null : new TimeOfDay(hour: dateEnd.hour, minute: dateEnd.minute);

  factory RollCall.fromJson(Map<String, dynamic> json) => new RollCall(
    id: json["id"],
    classGroup: ClassGroup.fromJson(json["class_group"]),
    teacher: Teacher.fromJson(json["teacher"]),
    studentPresences: new List<StudentPresence>.from(json["student_presences"].map((x) => StudentPresence.fromJson(x))),
    dateStart: DateTime.parse(json["date_start"]),
    dateEnd: DateTime.parse(json["date_end"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "class_group": classGroup.toJson(),
    "teacher": teacher.toJson(),
    "student_presences": new List<dynamic>.from(studentPresences.map((x) => x.toJson())),
    "date_start": dateStart.toIso8601String(),
    "date_end": dateEnd.toIso8601String(),
    "status": status,
  };
}
