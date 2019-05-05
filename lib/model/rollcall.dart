import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/model/teacher.dart';

class RollCall {
  static const STATUS_DRAFT = 'draft';
  static const STATUS_VALID = 'valid';
  static const STATUS_CANCEL = 'cancel';

  ClassGroup classGroup;
  Teacher teacher;
  List<StudentPresence> studentPresences;
  int id;
  DateTime dateStart;
  DateTime dateEnd;
  String status = RollCall.STATUS_DRAFT;

  RollCall({
    this.classGroup,
    this.teacher,
    this.studentPresences,
    this.id,
    this.dateStart,
    this.dateEnd,
    this.status,
  });

  factory RollCall.fromJson(Map<String, dynamic> json) => new RollCall(
    classGroup: ClassGroup.fromJson(json["class_group"]),
    teacher: Teacher.fromJson(json["teacher"]),
    studentPresences: new List<StudentPresence>.from(json["student_presences"].map((x) => StudentPresence.fromJson(x))),
    id: json["id"],
    dateStart: DateTime.parse(json["date_start"]),
    dateEnd: DateTime.parse(json["date_end"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "class_group": classGroup.toJson(),
    "teacher": teacher.toJson(),
    "student_presences": new List<dynamic>.from(studentPresences.map((x) => x.toJson())),
    "id": id,
    "date_start": dateStart.toIso8601String(),
    "date_end": dateEnd.toIso8601String(),
    "status": status,
  };
}
