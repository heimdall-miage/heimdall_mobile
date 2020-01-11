import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/exceptions/auth.dart';
import 'package:heimdall/helper/validation.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/ui/components/password_field.dart';
import "package:http/http.dart" as http;

class ResetPassword extends StatefulWidget {
  @override
  State createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  String verificationId;
  LoginFormData _data = LoginFormData();
  TextEditingController _urlController = TextEditingController();
  bool _urlIsValid;
  FocusNode _urlFocus = FocusNode();
  FocusNode _usernameFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = AppModel.of(context).api?.apiUrl;
    _urlFocus.addListener(() {

    });
  }

  void resetPassword() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Heimdall'),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(child: Container(
                padding: EdgeInsets.only(left: 30, right: 30, top: 50),
                child: Column(
                  children: <Widget>[
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Numéro étudiant / Nom d'utilisateur",
                                  icon: const Icon(Icons.person)),
                              validator: Validator.validateUsername,
                              textInputAction: TextInputAction.next,
                              initialValue: AppModel.of(context).user?.username,
                              focusNode: _usernameFocus,
                              onFieldSubmitted: (val) {
                                _usernameFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocus);
                              },
                              onSaved: (String value) => _data.username = value,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: RaisedButton(
                                      child: const Text('Mot de passe oublié'),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: resetPassword,
                                    ))),
                          ],
                        )),
                  ],
                ))),
            _loading ? Container(
              color: Color.fromRGBO(100, 100, 100, 0.5),
              child: Center(child: CircularProgressIndicator()),
            ) : Container(),
          ],
        )
    );
  }

}

class LoginFormData {
  String serverUrl = '';
  String username = '';
  String password = '';
}
