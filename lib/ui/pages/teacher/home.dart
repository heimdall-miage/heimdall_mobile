import 'package:flutter/material.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/ui/pages/logged.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {
  List<RollCall> _rollCalls = [];
  bool includeBaseContainer = false;

  @override
  void initState() {
    super.initState();
    _getRollCalls();
  }

  void _getRollCalls() async {
    List<RollCall> rollCalls = await api.getRollCalls();
      setState(() {
        _rollCalls = rollCalls;
      });
  }

  @override
  Widget getBody() {
    return _rollCalls.length == 0 ? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _rollCalls.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text("Appel du " + _rollCalls[index].dateStart.toString()),
          );
        }
    );
  }

}