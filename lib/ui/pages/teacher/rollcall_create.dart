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
              DataTable(
                columns: [
                  DataColumn(label: Text('Photo')),
                  DataColumn(label: Text('Nom')),
                  DataColumn(label: Text('Retard')),
                ],
                rows: _rollCall.studentPresences.length == 0 ? [] : _rollCall.studentPresences.map(
                      (studentPresence) =>
                      DataRow(
                          selected: studentPresence.present,
                          onSelectChanged: (b) {
                            setState(() {
                              studentPresence.present = !studentPresence.present;
                            });
                          },
                          cells: [
                            DataCell(
                              CachedNetworkImage(imageUrl: api.serverRootUrl + studentPresence.student.photo),
                            ),
                            DataCell(
                              Text(studentPresence.student.lastname + ' ' + studentPresence.student.firstname),
                            ),
                            DataCell(
                              Icon(FontAwesomeIcons.clock),
                            ),
                          ]),
                ).toList(),
              ),
              RaisedButton(child: Text('Valider'), onPressed: _save)
            ]
        )
    );
  }

}