import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/components/named_card.dart';
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
    if (justificativeFile != null && _presence.excuse != null) {
      setState(() {
        loading = true;
      });
      StudentPresence returnedPresence;
      try {
        dynamic result = await api.post('student/presence/${_presence.id}/excuse', {
          'photoBase64': base64Encode(justificativeFile.readAsBytesSync()),
          'extension': p.extension(justificativeFile.path),
          'excuse': _presence.excuse
        });
        returnedPresence = StudentPresence.fromApi(result);
      } catch (e) {
        print(e);
      }

      if (returnedPresence != null) {
        Navigator.pop(context, returnedPresence);
      } else {
        setState(() {
          loading = false;
        });
        showSnackBar(SnackBar(content: Text('Erreur lors de l\'enregistrement !'), backgroundColor: Colors.red));
      }
    } else {
      showSnackBar(SnackBar(content: Text('Renseignez une raison et un justificatif.'), backgroundColor: Colors.red));
    }
  }

  Future<void> _selectPicture() async {
    File tempFile =
        await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);
    setState(() {
      justificativeFile = tempFile;
    });
  }

  Future<void> _takePicture() async {
    File tempFile =
        await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 200, maxWidth: 200);
    setState(() {
      justificativeFile = tempFile;
    });
  }

  void _getExcuses() async {
    List<String> excuses = await api.getExcuses();
    setState(() {
      _excuses = excuses;
      loading = false;
    });
  }

  String _getExcuseLabel(String excuse) {
    switch (excuse) {
      case 'sick':
        return 'Malade';
      case 'family':
        return 'Raison familiale';
      case 'transport':
        return 'Problème de transport';
      case 'work':
        return 'Raison professionnelle';
      case 'other':
      default:
        return 'Autre raison';
    }
  }

  List<DropdownMenuItem<String>> get _excusesDropdown {
    List<DropdownMenuItem<String>> items = new List();
    for (String excuse in _excuses) {
      items.add(new DropdownMenuItem(value: excuse, child: new Text(_getExcuseLabel(excuse))));
    }
    return items;
  }

  /*Widget _displayPicture() {
    if (justificativeFile == null && _presence.excuseProof == null) {
      return Center(child: Text('En attente du justificatif'));
    }
    if (justificativeFile == null && _presence.excuseProof != null) {
      return Image(
          image: NetworkImage(_presence.excuseProof, headers: api.authHeader));
    } else {
      print(justificativeFile.path);
      return Image(image: AssetImage(justificativeFile.path));
    }
  }*/

  @override
  Widget getBody() {
    return Padding(
        padding: EdgeInsets.only(top: 20, left: 5, right: 5),
        child: Column(children: <Widget>[
          NamedCard(
            title: 'Raison',
            children: <Widget>[
              Padding(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Choisissez la raison'),
                  items: _excusesDropdown,
                  value: _presence.excuse,
                  onChanged: (val) {
                    setState(() {
                      _presence.excuse = val;
                    });
                  },
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              )
            ],
          ),
          NamedCard(
            title: 'Justificatif',
            children: <Widget>[
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add_photo_alternate),
                          Text('Importer une \n photo', textAlign: TextAlign.center,)
                        ],
                      ),
                      onPressed: _selectPicture,
                    ),
                    FlatButton(
                      child: Row(
                        children: <Widget>[Icon(Icons.add_a_photo), Text('Prendre une \n photo', textAlign: TextAlign.center,)],
                      ),
                      onPressed: _takePicture,
                    ),
                  ],
                  ),
                width: double.infinity,
                ),
            ],
            ),
          /*Expanded(
            child: _displayPicture(),
            ),*/
          SizedBox(
              width: double.infinity,
              child: RaisedButton(
                  child: Text('Valider'),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Theme
                      .of(context)
                      .accentColor,
                  textColor: Colors.white,
                  onPressed: _saveJustification
                  )
              )
        ]));
  }
}
