import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/user.dart';

abstract class Logged<T extends StatefulWidget> extends State<T> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    setState(() {
      user = checkLoggedIn(context);
    });
  }

  User checkLoggedIn(BuildContext context) {
    if (!AppModel.of(context).isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
      return null;
    } else {
      return AppModel.of(context).user;
    }
  }

  Widget getBody();

  Widget getNav() {
    return null;
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(SnackBar snackbar) {
    return scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = loading ? Center(child: Stack(children: <Widget>[CircularProgressIndicator()])) :
    SafeArea(
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: getBody()
            )
        )
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Heimdall"),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.solidUserCircle),
            onPressed: () {
              changeRoute(context, '/account');
            },
          ),
        ],
      ),
      body: _body,
      bottomNavigationBar: getNav(),
    );
  }

  // Pour changer de route uniquement si on y est pas déjà (évite une animation inutile)
  void changeRoute(BuildContext context, String newRouteName) {
    if (ModalRoute.of(context).settings.name != newRouteName) {
      Navigator.pushNamed(context, newRouteName);
    }
  }
}