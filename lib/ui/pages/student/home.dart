
import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {

  List<StudentPresence> _studentPresences = [];
  bool includeBaseContainer = false;

  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();
    _getPresence();
  }

  void _getPresence() async {
    List<StudentPresence> studentPresences = await api.getStudentPresences();
    setState(() {
      _studentPresences = studentPresences;
      loading = false;
    });
  }

  @override
  Widget getBody() {

    return ListView.builder(
        itemCount: _studentPresences.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text("Absence du " + _studentPresences[index].rollCall.dateStart.toString()),
            onTap: () => Navigator.of(context).pushNamed('/student/justify', arguments: _studentPresences[index]),
          );
        }
    );
  }



}