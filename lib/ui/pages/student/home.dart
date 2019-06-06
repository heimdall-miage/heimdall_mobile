
import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:onesignal/onesignal.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {

  List<StudentPresence> _studentPresences = [];
  bool includeBaseContainer = false;

//todo refresh auto après validation excuse
  @override
  void didUpdateWidget(old) {
    super.didChangeDependencies();
    _getPresence();
  }

  void _getPresence() async {
    List<StudentPresence> studentPresences = await api.getStudentPresences();
    setState(() {
      _studentPresences = studentPresences;
      loading = false;
    });
  }

  Widget _getPresenceValidationStatus(StudentPresence studentPresence) {
    //a justifier : excuseproof null, en attente de validation dde l'admin : excusevalidated=null, validé =1, refusé =0

    //a justifier : rouge
    if (studentPresence.excuseProof == null) {
      return Align(
          child: Chip(
              label: Text('a justifier'),
              backgroundColor: Color.fromRGBO(250, 0, 0, 0.7),
          ),
          alignment: Alignment.topLeft
      );
    }
    //en attente de validation : orange
    else if (studentPresence.excuseValidated == null && studentPresence.excuseProof!=null) {
      return Align(
          child: Chip(
            label: Text('en attende de validation'),
            backgroundColor: Color.fromRGBO(250, 150, 0, 0.7),
          ),
          alignment: Alignment.topLeft
      );
    }
    //validé : vert
    else if (studentPresence.excuseValidated == true) {
      return Align(
          child: Chip(
            label: Text('Validé'),
            backgroundColor: Color.fromRGBO(0, 150, 0, 0.7),
          ),
          alignment: Alignment.topLeft
      );
    }
    //refusé : noir
    return Align(
        child: Chip(
          label: Text('Refusé'),
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.7),
        ),
        alignment: Alignment.topLeft
    );
  }

  @override
  Widget getBody() {

    return ListView.builder(
        itemCount: _studentPresences.length,
        itemBuilder: (BuildContext context, int index) {
          print(_studentPresences[index].excuseProof);
          print(_studentPresences[index].excuseValidated);
          return ListTile(
            title: Text("Absence du " + _studentPresences[index].rollCall.dateStart.toString()),
            subtitle: _getPresenceValidationStatus(_studentPresences[index]),
            onTap: () => Navigator.of(context).pushNamed('/student/justify', arguments: _studentPresences[index]),
          );
        }
    );
  }



}