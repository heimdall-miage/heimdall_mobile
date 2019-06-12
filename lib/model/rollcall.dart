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
    this.status = RollCall.STATUS_DRAFT,
  }) {
    if (dateStart == null) dateStart = new DateTime.now();
    if (dateEnd == null) dateEnd = new DateTime.now().add(new Duration(hours: 2));
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

  Duration get diff {
    return dateEnd.difference(dateStart);
  }

  bool get isPassed => dateEnd == null ? null : dateEnd.isBefore(new DateTime.now());

  factory RollCall.fromApi(dynamic data) {
    if (data is int) {
      return new RollCall(id: data);
    }
    if (data is Map<String, dynamic>) {
      return RollCall.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory RollCall.fromJson(Map<String, dynamic> json) => new RollCall(
    id: json["id"],
    classGroup: json["class_group"] == null ? null : ClassGroup.fromApi(json["class_group"]),
    teacher: json["teacher"] == null ? null : Teacher.fromApi(json["teacher"]),
    studentPresences: json["student_presences"] == null ? null :  new List<StudentPresence>.from(json["student_presences"].map((x) => StudentPresence.fromApi(x))),
    dateStart: DateTime.parse(json["date_start"]),
    dateEnd: DateTime.parse(json["date_end"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "class_group": forApi ? classGroup.id : classGroup.toJson(),
    "teacher": forApi ? teacher.id : teacher.toJson(),
    "student_presences": new List<dynamic>.from(studentPresences.map((x) => x.toJson(forApi: forApi))),
    "date_start": dateStart.toIso8601String(),
    "date_end": dateEnd.toIso8601String(),
    "status": status,
  };
}
