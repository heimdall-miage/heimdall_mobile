import 'dart:core';

import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student.dart';

class StudentPresence {
  Student student;
  RollCall rollCall;
  int id;
  bool present;
  Duration lateDuration = const Duration(minutes: 0); // late is a reserved keyword
  String excuse;
  String excuseProof;
  bool excuseValidated;

  StudentPresence({
    this.student,
    this.rollCall,
    this.id,
    this.present,
    this.lateDuration = const Duration(minutes: 0),
    this.excuse,
    this.excuseProof,
    this.excuseValidated,
  });

  factory StudentPresence.fromApi(dynamic data) {
    if (data is int) {
      return new StudentPresence(id: data);
    }
    if (data is Map<String, dynamic>) {
      return StudentPresence.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory StudentPresence.fromJson(Map<String, dynamic> json) => new StudentPresence(
    student: json["student"] == null ? null : Student.fromApi(json["student"]),
    rollCall: json["roll_call"] == null ? null : RollCall.fromApi(json["roll_call"]),
    id: json["id"],
    present: json["present"],
    lateDuration: Duration(minutes: json["late"] != null ? json["late"] : 0),
    excuse: json["excuse"],
    excuseProof: json["excuse_proof"],
    excuseValidated: json["excuse_validated"],
  );

  Map<String, dynamic> toJson() => {
    "student": student.id,
    "roll_call": rollCall == null ? null : rollCall.toJson(),
    "id": id,
    "present": present,
    "late": lateDuration != null && lateDuration.inMinutes > 0 ? lateDuration.inMinutes : null,
    "excuse": excuse,
    "excuse_proof": excuseProof,
    "excuse_validated": excuseValidated,
  };
}