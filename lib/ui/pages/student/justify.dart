
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class Justify extends StatefulWidget {
  @override
  State createState() => _JustifyState();
}

class _JustifyState extends Logged<Justify> {
  StudentPresence _presence;
  List<String> _excuses = [];
  bool includeBaseContainer = false;
  File justificativeFile;
  Image temp;

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

  Future<void> _saveJustification() async {
    if (justificativeFile != null) {
    String url = await api.post('student/presence/' + _presence.id.toString(), {
    'photoBase64': base64Encode(justificativeFile.readAsBytesSync()),
    'extension': p.extension(justificativeFile.path),
      'excuse': _presence.excuse
    });
    if (url != null) {
      // todo
    }
    }
  }

  Future<void> _displayPicture() async {
    File tempFile = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);
    setState(() {
        justificativeFile=tempFile;
    });

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
          FlatButton(
            child: Text('Ajouter une photo'),
            onPressed: _displayPicture,
      ),

        justificativeFile == null ? Text('coucou') :
        Image(
        image: AssetImage(
            justificativeFile.path
        ),
    ),

        FlatButton(
          child: Text('Valider'),
          onPressed: _saveJustification,
        ),

      ],


    );

  }

}