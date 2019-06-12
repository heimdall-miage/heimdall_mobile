
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

  Widget _getPresenceValidationStatus(StudentPresence studentPresence) {
    //a justifier : excuseproof null, en attente de validation dde l'admin : excusevalidated=null, validé =1, refusé =0

    //a justifier : rouge
    if (studentPresence.excuseProof == null) {
      return Align(
          child: Chip(
              label: Text('À justifier'),
              backgroundColor: Color.fromRGBO(250, 0, 0, 0.7),
          ),
          alignment: Alignment.topLeft
      );
    }
    //en attente de validation : orange
    else if (studentPresence.excuseValidated == null && studentPresence.excuseProof!=null) {
      return Align(
          child: Chip(
            label: Text('En attende de validation'),
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
    //refusé : rouge
    return Align(
        child: Chip(
          label: Text('Refusé'),
          backgroundColor: Color.fromRGBO(250, 0, 0, 0.7),
        ),
        alignment: Alignment.topLeft
    );
  }

  @override
  Widget getBody() {

    return ListView.builder(
        itemCount: _studentPresences.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_studentPresences[index].present==false ? "Absence du " + _studentPresences[index].rollCall.dateStart.toString():
            "Retard du " + _studentPresences[index].rollCall.dateStart.toString()),
            subtitle: _getPresenceValidationStatus(_studentPresences[index]),

            onTap: () async {
              if(_studentPresences[index].excuseProof==null || _studentPresences[index].excuseValidated==false){

                dynamic returnedPresence = await Navigator.pushNamed(context, '/student/justify', arguments: _studentPresences[index]);
                if (returnedPresence != null) {
                    setState(() {
                      _studentPresences[index] = returnedPresence;
                    });
                }
              }
            },
          );
        }
    );
  }



}