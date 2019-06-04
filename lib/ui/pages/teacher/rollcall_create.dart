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
      changeRoute(context, 'home',roleSpecific: true);
    }
  }

  Color getPresenceColor(StudentPresence presence) {
      if (presence.present == false) {
        return Color.fromRGBO(200, 0, 0, 0.2);
      } else if (presence.lateDuration.inMinutes > 0) {
        return Color.fromRGBO(255, 139, 0, 0.2);
      }
      return Color.fromRGBO(0, 200, 0, 0.2);
  }

  @override
  Widget getBody() {
    final TextStyle hourStyle = new TextStyle(fontSize: 20, color: Colors.lightBlue);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
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
              DropdownButton<ClassGroup>(
                isExpanded: true,
                hint: Text('Choisissez une classe'),
                items: _classGroupsDropdown,
                value: _rollCall.classGroup,
                onChanged: _onClassGroupChanged,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: _rollCall.studentPresences.length,
                      itemBuilder: (BuildContext context, int index) {
                        StudentPresence studentPresence = _rollCall.studentPresences[index];
                        return Ink(
                          color: getPresenceColor(_rollCall.studentPresences[index]),
                          child: ListTile(
                            title: Text(studentPresence.student.lastname + ' ' +
                                studentPresence.student.firstname),
                            leading: studentPresence.student.photo == null
                                ? Icon(Icons.person, size: 40)
                                : CachedNetworkImage(
                                imageUrl: api.serverRootUrl +
                                    studentPresence.student.photo,
                                height: 40),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(studentPresence.lateDuration == Duration() ? '' : studentPresence.lateDuration.inMinutes.toString() + 'min.'),
                                IconButton(
                                    icon: Icon(Icons.access_time),
                                    onPressed: () async {
                                      Duration duration = await showDurationPicker(
                                        context: context,
                                        initialTime: studentPresence.lateDuration,
                                        snapToMins: 5.0,
                                      );
                                      if (duration != null) {
                                        print(duration.toString());
                                        if (_rollCall.diff.compareTo(duration) > 0) {
                                          setState(() {
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
                                )
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _rollCall.studentPresences[index].present =
                                !_rollCall.studentPresences[index].present;
                              });
                            },
                          ),
                        );
                      }
                  )
              ),
              RaisedButton(child: Text('Valider'), onPressed: _save)
            ]
        )
    );
  }

}