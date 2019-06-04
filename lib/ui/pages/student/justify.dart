
import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';

class Justify extends StatefulWidget {
  @override
  State createState() => _JustifyState();
}

class _JustifyState extends Logged<Justify> {
  StudentPresence _presence;
  List<String> _excuses = [];
  bool includeBaseContainer = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _presence = ModalRoute.of(context).settings.arguments;
  }

  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();
    _getExcuses();
  }

  void _getExcuses() async {
    List<String> excuses = await api.getExcuses();
    setState(() {
      _excuses = excuses;
      loading = false;
    });
  }

  List<DropdownMenuItem<String>> get _excusesDropdown {
    List<DropdownMenuItem<String>> items = new List();
    for (String excuse in _excuses) {
      items.add(new DropdownMenuItem(
          value: excuse,
          child: new Text(excuse)
      ));
    }
    return items;
  }

  @override
  Widget getBody() {
    return Column(
      children: <Widget>[
        DropdownButton<String>(
          isExpanded: true,
          hint: Text('Choisissez la justification'),
          items: _excusesDropdown,
          value: _presence.excuse,
          onChanged: (val) {
            setState(() {
              _presence.excuse = val;
            });
          },
        ),
      ],
    );

  }

}