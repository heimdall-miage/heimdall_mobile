import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/student.dart';
import 'package:heimdall/ui/components/loading_button.dart';
import 'package:heimdall/ui/components/named_card.dart';
import 'package:heimdall/ui/components/password_field.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class Account extends StatefulWidget {
  @override
  State createState() => _AccountState();
}

class _AccountState extends Logged<Account> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final Map<String, dynamic> _data = Map<String, dynamic>();
  final Map<String, FocusNode> _focusNodes = {
    'newPassword': FocusNode(),
    'oldPassword': FocusNode(),
  };
  Student student;

  @override
  initState() {
    super.initState();
    student = user;
    // Get user photo
    if (student.photo == null) {
      api.get('student/photo')
          .then((photoUrl) {
        setState(() {
          student.photo = photoUrl;
        });
      }).catchError((error) {
        // If the error is a 404, the user simply does not have a photo, do nothing
        if (!(error is ApiConnectException) || error.responseStatusCode != 404) {
          showErrorDialog(error);
        }
      });
    }
  }


  Future<void> _changeAvatar() async {
    File avatarFile = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);
    if (avatarFile != null) {
      String url = await api.post('student/photo', {
        'photoBase64': base64Encode(avatarFile.readAsBytesSync()),
        'extension': p.extension(avatarFile.path)
      });
      if (url != null) {
        setState(() {
          student.photo = url;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await AppModel
          .of(context)
          .api
          .post('student/update_password', _data);

      _data.clear();
      setState(() {
        _newPasswordController.text = "";
        _oldPasswordController.text = "";
      });
    }
  }

  Future<void> _signOut() async {
    AppModel.of(context).signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = loading ? Center(child: Stack(children: <Widget>[CircularProgressIndicator()])) :
    SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              actions: <Widget>[
                FlatButton(
                  child: Text('Modifier la photo'),
                  onPressed: _changeAvatar,
                ),
              ],
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                background: student.photo != null ? Image(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(student.photo),
                ) : null,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([

                NamedCard(
                    title: 'Mot de passe',
                    children: <Widget>[
                      Form(
                          key: _formKey,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(children: <Widget>[
                              PasswordField(
                                controller: _newPasswordController,
                                labelText: "Nouveau mot de passe",
                                helperText: "Laissez vide pour ne pas changer",
                                validator: (String value) {
                                  return value.isEmpty ? null : _oldPasswordController.text == value ? 'Doit être différent du mot de passe actuel' : null;
                                },
                                strengthChecker: true,
                                textInputAction: TextInputAction.next,
                                focusNode: _focusNodes['newPassword'],
                                onFieldSubmitted: (val) {
                                  _focusNodes['newPassword'].unfocus();
                                  FocusScope.of(context).requestFocus(_focusNodes['oldPassword']);
                                },
                                onSaved: (String value) => _data['newPassword'] = value,
                              ),
                              PasswordField(
                                controller: _oldPasswordController,
                                labelText: "Mot de passe actuel",
                                validator: (String value) => value.isEmpty ? "Vous devez renseigner votre mot de passe actuel." : null,
                                textInputAction: TextInputAction.done,
                                focusNode: _focusNodes['oldPassword'],
                                onFieldSubmitted: (val) {
                                  _focusNodes['oldPassword'].unfocus();
                                },
                                onSaved: (String value) => _data['oldPassword'] = value,
                              ),
                              ButtonTheme.bar(
                                child: ButtonBar(
                                  children: <Widget>[
                                    LoadingButton(
                                      text: 'ENREGISTRER',
                                      buttonType: ButtonType.FlatButton,
                                      action: _updatePassword,
                                      errorAction: showErrorDialog,
                                      successText: "Mot de passe mis à jour !",
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ))
                    ]
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FlatButton(
                    splashColor: Colors.grey,
                    child: Text('Déconnexion'),
                    onPressed: _signOut,
                  ),
                ),
              ]),
            )
          ],
        )
    );

    return Scaffold(
      key: scaffoldKey,
      body: _body,
    );
  }
}