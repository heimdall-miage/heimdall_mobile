import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';

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
    RollCall rollcall = await api.createRollCall(_rollCall);
    if (rollcall != null) {
      changeRoute(context, 'home',roleSpecific: true);
    }
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
                          color: _rollCall.studentPresences[index].present
                              ? Color.fromRGBO(0, 200, 0, 0.2)
                              : Color.fromRGBO(200, 0, 0, 0.2),
                          child: ListTile(
                            title: Text(studentPresence.student.lastname + ' ' +
                                studentPresence.student.firstname),
                            leading: studentPresence.student.photo == null
                                ? null
                                : CachedNetworkImage(
                                imageUrl: api.serverRootUrl +
                                    studentPresence.student.photo,
                                height: 40),
                            trailing: IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                        title: Text('Retard de ' + studentPresence.student.firstname + ' ' + studentPresence.student.lastname),
                                        children: <Widget>[
                                          // TODO
                                        ],
                                      );
                                    }
                                  );
                                }
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