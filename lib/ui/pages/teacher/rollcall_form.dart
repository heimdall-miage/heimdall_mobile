import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class RollCallForm extends StatefulWidget {
  @override
  State createState() => _RollCallFormState();
}

class _RollCallFormState extends Logged<RollCallForm> {
  List<ClassGroup> _classGroups = [];
  RollCall _rollCall = new RollCall();
  bool includeBaseContainer = false;
  bool _loadingStudents = false;
  bool _isUpdate = false;
  bool _draftLoadAsked = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context).settings.arguments != null) {
      _rollCall = ModalRoute.of(context).settings.arguments;
      _isUpdate = true;
    }
    if (!_isUpdate && !_draftLoadAsked) {
      _draftLoadAsked = true;
      setState(() {
        loading = true;
      });
      _resumeDraft();
      setState(() {
        loading = false;
      });
    }
  }

  _init() async {
    setState(() {
      loading = true;
    });
    _rollCall.teacher = user;
    await _getClassGroups();
    setState(() {
      loading = false;
    });
  }

  _getClassGroups() async {
    List<ClassGroup> classGroups = await api.getClasses();
    setState(() {
      _classGroups = classGroups;
      if (_rollCall.classGroup != null) {
        _rollCall.classGroup = _classGroups.singleWhere((classGroup) => classGroup.id == _rollCall.classGroup.id);
      }
    });
  }

  static const String draftFile = 'current_rollcall.json';
  _resumeDraft() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$draftFile');
      if (!(await file.exists())) {
        return;
      }
      String text = await file.readAsString();
      RollCall rollCall = RollCall.fromApi(jsonDecode(text));
      if (rollCall != null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Continuer l'appel ?"),
              content: new Text('Vous avez déjà un appel en cours (non validé) le ${DateFormat('dd/MM/yyy à kk:mm').format(rollCall.dateStart)} avec la classe "${rollCall.classGroup.name}", voulez-vous le récupérer ?'),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Supprimer cet appel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteDraft();
                  },
                  ),
                new FlatButton(
                  child: new Text("Non"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  ),
                new FlatButton(
                  child: new Text("Oui"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Use the classgroup object from the list, otherwise the dropdown init fail
                    rollCall.classGroup = _classGroups.singleWhere((group) => group.id == rollCall.classGroup.id);
                    setState(() {
                      _rollCall = rollCall;
                    });
                  },
                  ),
              ],
              );
          },
          );
      }
    } catch (e) {
      print("Couldn't read file");
    }
  }

  _deleteDraft() async {
    if (_isUpdate) return;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$draftFile');
    await file.delete();
  }

  _saveDraft() async {
    if (_isUpdate) return;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$draftFile');
    await file.writeAsString(jsonEncode(_rollCall.toJson(forApi: false)));
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
      _loadingStudents = true;
    });
    List<Student> students = await api.getStudentsInClass(classGroup.id);
    List<StudentPresence> presences = new List<StudentPresence>();
    for (Student student in students) {
      presences.add(new StudentPresence(student: student, present: true));
    }
    setState(() {
      _rollCall.studentPresences.clear();
      _rollCall.studentPresences.addAll(presences);
      _loadingStudents = false;
    });
    _saveDraft();
  }

  _save() async {
    if (_rollCall.classGroup == null || _rollCall.studentPresences.isEmpty) {
      showSnackBar(SnackBar(
          content: Text('La classe est vide !'),
          backgroundColor: Colors.red
      ));
      return;
    }
    setState(() {
      loading = true;
    });
    RollCall rollcall;
    try {
      if (_isUpdate) {
        rollcall = await api.updateRollCall(_rollCall);
      } else {
        rollcall = await api.createRollCall(_rollCall);
      }
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
      _deleteDraft();
      setState(() {
        loading = false;
      });
      Navigator.of(context).pop(rollcall);
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
        _saveDraft();
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
      if (studentPresence.lateDuration != Duration()) {
        studentPresence.lateDuration = Duration();
      }
      studentPresence.present = !studentPresence.present;
    });
    _saveDraft();
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
    final TextStyle hourStyle = new TextStyle(fontSize: 20, color: Theme.of(context).accentColor);
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
                      child: _loadingStudents ? Center(child: Stack(
                          children: <Widget>[CircularProgressIndicator()]))
                          : _rollCall.studentPresences.length == 0 ? Center(
                          child: Text(_rollCall.classGroup == null
                              ? "En attente d'une sélection de classe..."
                              : "Cette classe n'a aucun élève.")
                           )
                          : ListView.builder(
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
                                    : Image.network(
                                    studentPresence.student.photo,
                                    headers: api.authHeader,
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
                  child: Text('Confirmer et enregistrer'),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  onPressed: _save
              ))
            ]
        )
    );
  }

}