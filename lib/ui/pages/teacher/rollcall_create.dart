import 'package:flutter/material.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/rollcall.dart';
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

  void _getClassGroups() async {
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

  @override
  Widget getBody() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
            children: <Widget>[
              DropdownButton<ClassGroup>(
                isExpanded: true,
                items: _classGroupsDropdown,
                value: _rollCall.classGroup,
                onChanged: (classGroup) {
                  setState(() {
                    _rollCall.classGroup = classGroup;
                  });
                },
              ),
            ]
        )
    );
  }

}