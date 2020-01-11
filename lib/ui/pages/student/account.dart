import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
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
  final _formKeyInfos = GlobalKey<FormState>();
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
    student = user; // Cast user as student
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
          // TODO : Cheat, to do better (work only once)
          student.photo = url + "?v=" + (Random()).nextInt.toString();
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).requestFocus(new FocusNode()); // reset focus
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
    } else {
      throw new Exception('Certains champs sont vides ou invalides.');
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
                  image: NetworkImage(student.photo, headers: api.authHeader),
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
                NamedCard(
                    title: 'Informations',
                    children: <Widget>[
                      Form(
                          key: _formKeyInfos,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(children: <Widget>[
                              TextFormField(
                                key: widget.key,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(right: 10, top: 12, bottom: 12),
                                    labelText: "Email secondaire",
                                    errorMaxLines: 6,
                                    suffix: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Icon(
                                        Icons.person,
                                        size: 18,
                                        color:Colors.grey,
                                      ),
                                    ),
                                    icon: const Icon(Icons.lock)
                                ),
                                autocorrect: false,
                              ),
                              TextFormField(
                                key: widget.key,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(right: 10, top: 12, bottom: 12),
                                    labelText: "Téléphone",
                                    errorMaxLines: 6,
                                    suffix: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Icon(
                                        Icons.person,
                                        size: 18,
                                        color:Colors.grey,
                                      ),
                                    ),
                                    icon: const Icon(Icons.lock)
                                ),
                                autocorrect: false,
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