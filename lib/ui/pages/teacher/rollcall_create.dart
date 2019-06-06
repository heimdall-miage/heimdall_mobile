import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';

class RollCallCreate extends StatefulWidget {
  @override
  State createState() => _RollCallCreateState();
}

class _RollCallCreateState extends Logged<RollCallCreate> {
  List<ClassGroup> _classGroups = [];
  RollCall _rollCall = new RollCall();
  bool includeBaseContainer = false;



  @override
  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();
    _getClassGroups();

  }

  _getClassGroups() async {
    List<ClassGroup> classGroups = await api.getClasses();
    setState(() {
      _classGroups = classGroups;
      loading = false;
    });
  }

  List<DropdownMenuItem<ClassGroup>> get _classGroupsDropdown {
    List<DropdownMenuItem<ClassGroup>> items = new List();
    for (ClassGroup classGroup in _classGroups) {
      items.add(new DropdownMenuItem(
          value: classGroup,
          child: new Text(classGroup.name)
      ));
    }
    return items;
  }

  _onClassGroupChanged(ClassGroup classGroup) async {
    setState(() {
      _rollCall.classGroup = classGroup;
      loading = true;
    });
    List<Student> students = await api.getStudentsInClass(classGroup.id);
    List<StudentPresence> presences = new List<StudentPresence>();
    for (Student student in students) {
      presences.add(new StudentPresence(student: student, present: true));
    }
    setState(() {
      _rollCall.studentPresences.clear();
      _rollCall.studentPresences.addAll(presences);
      loading = false;
    });

  }

  _save() async {
    setState(() {
      loading = true;
    });
    _rollCall.teacher = user;
    print(user.id);
    RollCall rollcall;
    try {
      rollcall = await api.createRollCall(_rollCall);
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      showSnackBar(SnackBar(
          content: Text('Erreur, impossible de sauvegarder !'),
          backgroundColor: Colors.red
      ));
    }
    if (rollcall != null) {
      setState(() {
        loading = false;
      });
      showSnackBar(SnackBar(
          content: Text('Appel enregistré !'),
          backgroundColor: Colors.lightGreen
      ));
    }
  }

  Color _getPresenceColor(StudentPresence studentPresence, double opacity) {
      if (studentPresence.present == false) {
        return Color.fromRGBO(200, 0, 0, opacity);
      } else if (studentPresence.lateDuration.inMinutes > 0) {
        return Color.fromRGBO(255, 150, 0, opacity);
      }
      return Color.fromRGBO(0, 150, 0, opacity);
  }

  _askLateDuration(StudentPresence studentPresence) async {
    Duration duration = await showDurationPicker(
      context: context,
      initialTime: studentPresence.lateDuration,
      snapToMins: 5.0,
    );
    if (duration != null) {
      if (_rollCall.diff.compareTo(duration) > 0) {
        setState(() {
          studentPresence.present = true;
          studentPresence.lateDuration = duration;
        });
      } else {
        showSnackBar(SnackBar(
            content: Text('Durée de retard invalide !'),
            backgroundColor: Colors.red
        ));
      }
    }
  }

  _togglePresent(StudentPresence studentPresence) {
    setState(() {
      // Reset duration
      if (studentPresence.lateDuration != Duration) {
        studentPresence.lateDuration = Duration();
      }
      studentPresence.present = !studentPresence.present;
    });
  }

  Widget _getStudentPresenceStatus(StudentPresence studentPresence) {
    if (studentPresence.lateDuration != Duration()) {
      return Align(
          child: Chip(
              label: Text('Retard de ${studentPresence.lateDuration.inMinutes
                  .toString()} minutes'),
              backgroundColor: _getPresenceColor(studentPresence, 0.7)
          ),
          alignment: Alignment.topLeft
      );
    }
    return Align(
        child: Chip(
          label: Text(studentPresence.present ? 'Présent.e' : 'Absent.e'),
          backgroundColor: _getPresenceColor(studentPresence, 0.7),
        ),
        alignment: Alignment.topLeft
    );
  }

  @override
  Widget getBody() {
    final TextStyle hourStyle = new TextStyle(fontSize: 20, color: Colors.lightBlue);
    return Padding(
        padding: EdgeInsets.only(top: 20, left: 5, right: 5),
        child: Column(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text(_rollCall.startAt.format(context), style: hourStyle),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _rollCall.startAt,
                            );
                            if (time != null) {
                              setState(() {
                                _rollCall.startAt = time;
                              });
                            }
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 10), child: Text('à')),
                        Padding(padding: EdgeInsets.only(left: 10), child:
                        FlatButton(
                          child: Text(_rollCall.endAt.format(context), style: hourStyle),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _rollCall.endAt,
                            );
                            if (time != null) {
                              setState(() {
                                _rollCall.endAt = time;
                              });
                            }
                          },
                        ),),
                      ],
                    ),
                    Padding(
                      child: DropdownButton<ClassGroup>(
                        isExpanded: true,
                        hint: Text('Choisissez une classe'),
                        items: _classGroupsDropdown,
                        value: _rollCall.classGroup,
                        onChanged: _onClassGroupChanged,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Card(
                      child: _rollCall.studentPresences.length == 0 ? Center(
                          child: Text("En attente d'une sélection de classe...")) : ListView
                          .builder(
                          itemCount: _rollCall.studentPresences.length,
                          itemBuilder: (BuildContext context, int index) {
                            StudentPresence studentPresence = _rollCall
                                .studentPresences[index];
                            return Ink(
                              color: _getPresenceColor(
                                  _rollCall.studentPresences[index], 0.1),
                              child: ListTile(
                                title: Text(
                                  studentPresence.student.fullNameReversed,
                                  style: TextStyle(fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: _getStudentPresenceStatus(
                                    studentPresence),
                                contentPadding: EdgeInsets.only(left: 15,
                                    right: 10,
                                    bottom: 38,
                                    top: 5),
                                dense: true,
                                leading: studentPresence.student.photo == null
                                    ? Icon(Icons.person, size: 80)
                                    : CachedNetworkImage(
                                    imageUrl: api.serverRootUrl +
                                        studentPresence.student.photo,
                                    height: 80),
                                trailing: IconButton(
                                  icon: Icon(Icons.access_time),
                                  onPressed: () =>
                                      _askLateDuration(studentPresence),
                                ),
                                onTap: () => _togglePresent(studentPresence),
                              ),
                            );
                          }
                      )
                  )
              ),
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
                  child: Text('Valider'),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Theme.of(context).primaryColor,
                  onPressed: _save
              ))
            ]
        )
    );
  }

}