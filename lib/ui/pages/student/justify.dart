
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:toast/toast.dart';


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
    dynamic result = await api.post('student/presence/' + _presence.id.toString(), {
    'photoBase64': base64Encode(justificativeFile.readAsBytesSync()),
    'extension': p.extension(justificativeFile.path),
      'excuse': _presence.excuse
    });
    StudentPresence returnedPresence = StudentPresence.fromApi(result);

    Toast.show("Justificatif envoyé",context ,duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    if (returnedPresence != null) {
      Navigator.pop(context, returnedPresence);
    } else {
      showSnackBar(SnackBar(
          content: Text('Erreur lors de l\'enregistrement !'),
          backgroundColor: Colors.red
      ));
    }
    }
  }

  Future<void> _savePicture() async {
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

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Widget _displayPicture(){
    if(justificativeFile==null && _presence.excuseProof==null){
        return Text('pas de justification');
    }
    if(justificativeFile==null && _presence.excuseProof!=null){
      print(api.serverRootUrl+_presence.excuseProof);
      return Image(image: CachedNetworkImageProvider(api.serverRootUrl+_presence.excuseProof));
    }

    else{
      print(justificativeFile.path);
      return Image(image: AssetImage(justificativeFile.path));
    }
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
            onPressed: _savePicture,
      ),
        _displayPicture(),
        FlatButton(
          child: Text('Valider'),
          onPressed: _saveJustification,
    ),

    ],


    );
    }

}

