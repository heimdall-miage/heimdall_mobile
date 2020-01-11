
import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {

  List<StudentPresence> _studentPresences = List<StudentPresence>();
  bool includeBaseContainer = false;
  RefreshController _refreshController = RefreshController(initialRefresh:false);

  void initState() {
    super.initState();
    _getPresence();
  }

  void _getPresence() async {
    await initializeDateFormatting('fr_FR', null);
    List<StudentPresence> studentPresences = await api.getStudentPresences();
    if(mounted)
    setState(() {
      _studentPresences = studentPresences;
      loading = false;
    });
    _refreshController.refreshCompleted();
  }

  Widget _getPresenceValidationStatus(StudentPresence studentPresence) {
    String label = 'Justificatif refusé';
    Color color = Color.fromRGBO(250, 0, 0, 0.7);

    //a justifier : rouge
    if (studentPresence.excuseProof == null) {
      label = 'A justifier';
      color = Color.fromRGBO(250, 0, 0, 0.7);
    }
    //en attente de validation : orange
    else if (studentPresence.excuseValidated == null && studentPresence.excuseProof != null) {
      label = 'En attende de validation';
      color = Color.fromRGBO(250, 150, 0, 0.7);
    }
    //validé : vert
    else if (studentPresence.excuseValidated == true) {
      label = 'Justifiée';
      color = Color.fromRGBO(0, 150, 0, 0.7);
    }

    return Chip(
      label: Text(label),
      backgroundColor: color,
    );
  }

  _showPresence(int index) async {
    dynamic returnedPresence = await Navigator.pushNamed(context, '/student/justify', arguments: _studentPresences[index]);
    if (returnedPresence != null) {
      showSnackBar(SnackBar(
        content: Text("La justification a été envoyée."),
        backgroundColor: Colors.lightGreen,
      ));
      setState(() {
        _studentPresences[index] = returnedPresence;
      });
    }
  }

  ListTile _buildItemsForListView(BuildContext context, int index) {
    return ListTile(
      title: Text((!_studentPresences[index].present ? "Absence" : "Retard")),
      subtitle: !_studentPresences[index].present ? Text("${DateFormat('EEEE dd MMM yyy').format(_studentPresences[index].rollCall.dateStart)} de ${_studentPresences[index].rollCall.startAt.format(context)} à ${_studentPresences[index].rollCall.endAt.format(context)} (${_studentPresences[index].rollCall.diff.inHours}h)")
          : Text("${_studentPresences[index].lateDuration.inMinutes}m le ${DateFormat('EEEE dd MMM yyy').format(_studentPresences[index].rollCall.dateStart)}"),
      trailing: _getPresenceValidationStatus(_studentPresences[index]),
      onTap: _studentPresences[index].excuseProof == null || _studentPresences[index].excuseValidated == false
          ? () => _showPresence(index)
          : null,
    );
  }


  @override
  Widget getBody() {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _getPresence,
        controller: _refreshController,
        child: ListView.builder(
            itemCount: _studentPresences.length,
            itemBuilder: _buildItemsForListView
        ),

      ),
    );
  }


}