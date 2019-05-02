import 'package:heimdall/model/user.dart';

class Student extends User {
  String photo;

  Student({String username, this.photo}) : super(username: username);
}