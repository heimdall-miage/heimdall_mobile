import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/user.dart';

class Teacher extends User {
  List<ClassGroup> classGroups;
  List<RollCall> rollCalls;
  get type => 'teacher';

  Teacher({int id, String username, String firstname, String lastname, DateTime lastLogin, this.classGroups, this.rollCalls})
      : super(id: id, username: username, firstname: firstname, lastname: lastname, lastLogin: lastLogin);

  factory Teacher.fromApi(dynamic data) {
    if (data is int) {
      return new Teacher(id: data);
    }
    if (data is Map<String, dynamic>) {
      return Teacher.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory Teacher.fromJson(Map<String, dynamic> json) => new Teacher(
    id: json["id"],
    username: json["username"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    lastLogin: json["last_login"] == null ? null : DateTime.parse(json["last_login"]),
    classGroups: json['class_groups'] == null ? null : new List<ClassGroup>.from(json["class_groups"].map((x) => ClassGroup.fromApi(x))),
    rollCalls: json['roll_calls'] == null ? null : new List<RollCall>.from(json["roll_calls"].map((x) => RollCall.fromApi(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": User.TEACHER,
    "username": username,
    "firstname": firstname,
    "lastname": lastname,
    "last_login": lastLogin == null ? null : lastLogin,
    "class_groups": classGroups == null ? null : new List<dynamic>.from(classGroups.map((x) => x.toJson())),
    "roll_calls": rollCalls == null ? null : new List<dynamic>.from(rollCalls.map((x) => x.toJson())),
  };
}