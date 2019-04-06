import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/user.dart';
import 'package:heimdall/ui/pages/login.dart';
import 'package:scoped_model/scoped_model.dart';

final model = new AppModel();

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storage = new FlutterSecureStorage();
    return
      ScopedModel<AppModel>(
        model: model,
        child: MaterialApp(
            title: 'Heimdall',
            home: FutureBuilder<User>(
                future: model.resumeExistingConnection(),
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
                          print('User logged in!');
                          AppModel.of(context).test().then((val) {print(val);});
                          if (model.user.type == User.STUDENT) {
//                          return StudentHome(); // TODO
                          }
                          if (model.user.type == User.TEACHER) {
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