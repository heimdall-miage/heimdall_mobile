import 'package:flutter/material.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/teacher.dart';
import 'package:heimdall/ui/components/loading_button.dart';
import 'package:heimdall/ui/components/named_card.dart';
import 'package:heimdall/ui/components/password_field.dart';
import 'package:heimdall/ui/pages/logged.dart';

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
  Teacher teacher;

  @override
  initState() {
    super.initState();
    teacher = user; // Cast user as teacher
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).requestFocus(new FocusNode()); // reset focus
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await api.post('teacher/update_password', _data);

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
  Widget getBody() {
    return Column(children: <Widget>[
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
    ]);
  }
}