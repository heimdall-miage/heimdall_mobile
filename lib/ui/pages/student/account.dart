import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/user.dart';
import 'package:heimdall/ui/components/loading_button.dart';
import 'package:heimdall/ui/components/named_card.dart';
import 'package:heimdall/ui/components/password_field.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<String> _changeAvatar() async {
    File avatarFile = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);
//    if (avatarFile != null) {
//      setState(() {
//        user = currentUser;
//      });
//      return newPhotoUrl;
//    }
    return null;
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        bool result = await AppModel
            .of(context)
            .api
            .post('/student/update_password', _data);
        if (result) {
          print('UPDATE OK!');
        } else {
          print('UPDATE PAS OK!');
        }
      } on ApiConnectException catch (e) {
        print(e); // TODO : Erreur
      }
    }
  }

  Future<void> _signOut() async {
    AppModel.of(context).signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
  }

  @override
  Widget getBody() {
    return Column(
            children: <Widget>[
              NamedCard(
                  title: 'Informations personnelles',
                  children: <Widget>[
//                    Image(image: ,), // TODO : Avatar
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
                                    successText: "Mot de passe mis à jour",
                                    errorText: "Erreur de mise à jour",
                                    buttonType: ButtonType.FlatButton,
                                    action: _updatePassword,
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
              )
            ],
      );
  }
}