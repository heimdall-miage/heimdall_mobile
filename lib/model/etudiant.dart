import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/model/user.dart';

class Etudiant extends User {
  //String photo;
  ClassGroup classGroup;
  List<StudentPresence> presences;
  String get type => 'etudiant';

  Etudiant(
      {int id, String username, String firstname, String lastname, DateTime lastLogin/*, this.photo*/, this.classGroup, this.presences})
      : super(id: id,
                  username: username,
                  firstname: firstname,
                  lastname: lastname,
                  lastLogin: lastLogin);

  factory Etudiant.fromApi(dynamic data) {
    if (data is int) {
      return new Etudiant(id: data);
    }
    if (data is Map<String, dynamic>) {
      return Etudiant.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory Etudiant.fromJson(Map<String, dynamic> json) => new Etudiant(
    id: json["id"],
    username: json["username"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    lastLogin: json["last_login"] == null ? null : DateTime.parse(json["last_login"]),
    /*photo: json["photo"] == null ? null : json["photo"],*/
    classGroup: json['class_group'] == null ? null : ClassGroup.fromApi(json['class_group']),
    presences: json['presences'] == null ? null : new List<StudentPresence>.from(json["presences"].map((x) => StudentPresence.fromApi(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": User.STUDENT,
    "username": username,
    "firstname": firstname,
    "lastname": lastname,
    "last_login": lastLogin == null ? null : lastLogin,
    /*"photo": photo == null ? null : photo,*/
    "class_group": classGroup == null ? null : classGroup.toJson(),
    "presences": presences == null ? null : new List<dynamic>.from(presences.map((x) => x.toJson())),
  };
}