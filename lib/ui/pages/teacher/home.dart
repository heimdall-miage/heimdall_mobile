import 'package:flutter/material.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/ui/pages/logged.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {
  @override
  Widget getBody() {
    return Text('Logged in as ' + AppModel.of(context).user.username);
  }

}