import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/ui/pages/logged.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {
  List<RollCall> _rollCalls = [];
  List<RollCall> _rollCalls2 = [];
  bool includeBaseContainer = false;

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();
    _getRollCalls();
  }


  void _getRollCalls() async {
    List<RollCall> rollCalls = await api.getRollCalls(20);
      setState(() {
        _rollCalls = rollCalls;
        loading = false;
      });
  }

  void _getRollCallsLastWeek() async {
    List<RollCall> rollCalls = await api.getRollCallsLastWeek();
    setState(() {
      _rollCalls2 = rollCalls;
      loading = false;
    });
  }


  void _showAddRollCall() {
    Navigator.of(context).pushNamed('/teacher/rollcall/create');
  }

  @override
  Widget getFloatingButton() {
    return FloatingActionButton(
      child: Icon(FontAwesomeIcons.tasks),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).textTheme.title.color,
      onPressed: _showAddRollCall,
    );
  }

  @override
  Widget getBody() {
    return ListView.builder(
        itemCount: _rollCalls.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text("Appel du " + _rollCalls[index].dateStart.toString()),
          );
        }
    );
  }

}