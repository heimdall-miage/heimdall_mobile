import 'package:flutter/material.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/professeur.dart';
import 'package:heimdall/model/user.dart';
import 'package:heimdall/ui/pages/reset_password.dart';
import 'package:heimdall/ui/pages/login.dart';
import 'package:heimdall/ui/pages/etudiant/account.dart' as student_account;
import 'package:heimdall/ui/pages/etudiant/home.dart' as student_home;
import 'package:heimdall/ui/pages/etudiant/justify.dart';
import 'package:heimdall/ui/pages/professeur/account.dart' as teacher_account;
import 'package:heimdall/ui/pages/professeur/home.dart' as teacher_home;
import 'package:heimdall/ui/pages/professeur/rollcall_form.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart'; //One Signal for push notification system

final model = new AppModel();

void main() => runApp(App());

class App extends StatelessWidget {
  Future<User> checkExistingConnection(BuildContext context) async {
    try {
      return await model.resumeExistingConnection();
    }  on ApiConnectException catch (e) {
      print(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'fr_FR';

    return
      ScopedModel<AppModel>(
        model: model,
        child: MaterialApp(
            theme: ThemeData(
              primaryColor: Color.fromRGBO(230, 230, 230, 1),
              accentColor: Colors.lightBlue,
            ),
            home: FutureBuilder<User>(
                future: checkExistingConnection(context),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    default:
                      if (snapshot.hasError) {
                        print(snapshot);
                        //return null;
                        return Text('Error: ${snapshot.error}'); // TODO : Gestion erreur
                      } else {
                        if (snapshot.data != null) {
                          if (model.user is Etudiant) {
                            return student_home.Home();
                          }
                          if (model.user is Professeur) {
                            return teacher_home.Home();
                          }
                        }
                        return Login();
                      }
                  }
                }
            ),
            routes: {
              // Globales
              '/login': (context) => Login(),
              '/reset_password': (context) => ResetPassword(),

              // Student specifics
              '/etudiant/home': (context) => student_home.Home(),
              '/etudiant/account': (context) => student_account.Account(),
              '/etudiant/justify' : (context) => Justify(),

              // Teacher specifics
              '/professeur/home': (context) => teacher_home.Home(),
              '/professeur/account': (context) => teacher_account.Account(),
              '/professeur/rollcall': (context) => RollCallForm(),
            }),
      );
  }
}