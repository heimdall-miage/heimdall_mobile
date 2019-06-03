import 'dart:core';

import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student.dart';

class StudentPresence {
  Student student;
  RollCall rollCall;
  int id;
  bool present;
  int lateDuration; // late is a reserved keyword
  String excuse;
  String excuseProof;
  bool excuseValidated;

  StudentPresence({
    this.student,
    this.rollCall,
    this.id,
    this.present,
    this.lateDuration,
    this.excuse,
    this.excuseProof,
    this.excuseValidated,
  });

  factory StudentPresence.fromJson(Map<String, dynamic> json) => new StudentPresence(
    student: json["student"] == null ? null : Student.fromJson(json["student"]),
    rollCall: json["roll_call"] == null ? null : RollCall.fromJson(json["roll_call"]),
    id: json["id"],
    present: json["present"],
    lateDuration: json["late"],
    excuse: json["excuse"],
    excuseProof: json["excuse_proof"],
    excuseValidated: json["excuse_validated"],
  );



  Map<String, dynamic> toJson() => {
    "student": student.toJson(),
    "roll_call": rollCall == null ? null : rollCall.toJson(),
    "id": id,
    "present": present,
    "late": lateDuration,
    "excuse": excuse,
    "excuse_proof": excuseProof,
    "excuse_validated": excuseValidated,
  };
}