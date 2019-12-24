import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {
  List<RollCall> _rollCalls = [];
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
    await initializeDateFormatting('fr_FR', null);
    List<RollCall> rollCalls = await api.getRollCalls(20);
      setState(() {
        _rollCalls = rollCalls;
        loading = false;
      });
  }

  void _showRollcallForm([RollCall rollcall]) async {
    dynamic returnedRollcall = await Navigator.of(context).pushNamed('/teacher/rollcall', arguments: rollcall);
    if (returnedRollcall != null) {
      showSnackBar(SnackBar(
        content: Text("L'appel a bien été enregistré."),
        backgroundColor: Colors.lightGreen,
      ));
      int rollcallKey = _rollCalls.indexWhere((rollcall) => rollcall.id == returnedRollcall.id);
      print(rollcallKey);
      if (rollcallKey == -1) {
        setState(() {
          _rollCalls.insert(0, returnedRollcall);
        });
      } else {
        setState(() {
          _rollCalls[rollcallKey] = returnedRollcall;
        });
      }
    }
  }

  @override
  Widget getFloatingButton() {
    return FloatingActionButton(
      child: Icon(FontAwesomeIcons.tasks),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).textTheme.title.color,
      onPressed: _showRollcallForm,
    );
  }

  @override
  Widget getBody() {
    return ListView.builder(
        itemCount: _rollCalls.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_rollCalls[index].classGroup.name),
            subtitle: Text("${DateFormat('EEEE dd MMM yyy').format(_rollCalls[index].dateStart)} de ${_rollCalls[index].startAt.format(context)} à ${_rollCalls[index].endAt.format(context)} (${_rollCalls[index].diff.inHours}h)"),
            trailing: _rollCalls[index].isPassed ? Chip(label: Text('Terminé'), backgroundColor: Color.fromRGBO(0, 150, 0, 0.7)) : Chip(label: Text('En cours'), backgroundColor: Color.fromRGBO(255, 150, 0, 0.7)),
            //onTap: _rollCalls[index].isPassed ? null : () => _showRollcallForm(_rollCalls[index]),
            onTap: () => _showRollcallForm(_rollCalls[index]),
          );
        }
    );
  }

}