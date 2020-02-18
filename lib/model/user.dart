import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/professeur.dart';

abstract class User {
  static final String STUDENT = 'Etudiant';
  static final String TEACHER = 'Professeur';
  final int id;
  final String username;
  String firstname;
  String lastname;
  String email;
  DateTime lastLogin;
  get type;
  String get fullName => firstname + ' ' + lastname;
  String get fullNameReversed => lastname + ' ' + firstname;

  User({this.id, this.username, this.firstname, this.lastname, this.email, this.lastLogin});

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    if (json['role'] == 'Etudiant') {
      print("go student");
      return Etudiant.fromJson(json);
    } else if (json['role'] == 'Professeur') {
      print("go prof");
      return Professeur.fromJson(json);
    }
    throw new Exception('User type not supported.');
  }

  Map<String, dynamic> toJson();
}