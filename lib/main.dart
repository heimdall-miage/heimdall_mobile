import 'package:flutter/material.dart';
import 'package:heimdall/heimdall_api.dart';
import 'package:heimdall/login.dart';
import 'package:heimdall/model/user.dart';
import 'package:scoped_model/scoped_model.dart';

final api = HeimdallApi();

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      ScopedModel<HeimdallApi>(
        model: api,
        child: MaterialApp(
            title: 'Heimdall',
            home: FutureBuilder<User>(
                future: api.resumeExistingConnection(),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Container(child: Center(child: CircularProgressIndicator()), color: Colors.white);
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        if (snapshot.data != null) {
                          if (api.user.type == User.STUDENT) {
//                          return StudentHome(); // TODO
                          }
                          if (api.user.type == User.TEACHER) {
//                          return TeacherHome();
                          }
                        }
                        return Login();
                      }
                  }
                }
            ),
            routes: {
              '/login': (context) => Login(),
//              '/reset_password': (context) => ResetPassword(),
//              '/account': (context) => Account(),
//              '/home': (context) => Home(),
            }),
      );
  }
}