import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heimdall/components/password_field.dart';
import 'package:heimdall/heimdall_api.dart';
import 'package:heimdall/helper/validation.dart';
import 'package:heimdall/model/user.dart';
import "package:http/http.dart" as http;

class Login extends StatefulWidget {
  @override
  State createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String verificationId;
  LoginFormData _data = LoginFormData();
  String _verifiedUrl;
  bool _urlIsValid;
  FocusNode _urlFocus = FocusNode();
  FocusNode _usernameFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _loading = false;

  // TODO : Nice dialog with real error handling
  void _showLoginErrorDialog(e) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          print(e);
          return AlertDialog(
            title: new Text("Connexion refusée"),
            content: new Text(e.message),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _verifyServerUrl(String url) async {
    if (!url.endsWith('/')) url += '/';
    print('Verify : $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('result') && data['result'] == 'heimdall') {
          setState(() {
            print('URL IS VALID');
            this._urlIsValid = true;
          });
          this._verifiedUrl = url;
          return;
        }
      }
    } on Exception catch (e) {
      print(e); // TEMP
    }

    // Recheck after adding /api to the url
    if (!url.contains('api')) {
      return await _verifyServerUrl(url + 'api/');
    }

    setState(() {
      print('URL NOT VALID');
      this._urlIsValid = false;
    });
  }

  Future<void> _signIn() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      _formKey.currentState.save();
      try {
        User user = await HeimdallApi.of(context).login(_data.serverUrl, _data.username, _data.password).timeout(
            Duration(seconds: 10), onTimeout: () {
          throw PlatformException(
              code: 'SIGN_IN_TIMEOUT',
              message: 'La connexion a pris trop de temps');
        });

        // TEMP
        setState(() {
          _loading = false;
        });
        print((await HeimdallApi.of(context).test()).toString());
//        Navigator.pushNamedAndRemoveUntil(
//            context, '/home', (Route<dynamic> route) => false);
      } on Exception catch (e) {
        _showLoginErrorDialog(e);
        setState(() {
          _loading = false;
        });
      }
    }
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
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: "Adresse du serveur",
                                icon: const Icon(Icons.computer),
                                errorText: _urlIsValid == false ? "Ce serveur Heimdall n'existe pas" : null,
                              ),
                              validator: Validator.validateUrl,
                              textInputAction: TextInputAction.next,
                              initialValue: HeimdallApi.of(context).clientApiUrl,
                              focusNode: _urlFocus,
                              onFieldSubmitted: (val) async {
                                _verifyServerUrl(val);
                                _urlFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_usernameFocus);
                              },
                              onSaved: (String value) => _data.serverUrl = _verifiedUrl ?? value,
                            ),
                            Divider(color: Colors.transparent),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Numéro étudiant / Nom d'utilisateur",
                                  icon: const Icon(Icons.person)),
                              validator: Validator.validateUsername,
                              textInputAction: TextInputAction.next,
                              initialValue: HeimdallApi.of(context).user?.username,
                              focusNode: _usernameFocus,
                              onFieldSubmitted: (val) {
                                _usernameFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocus);
                              },
                              onSaved: (String value) => _data.username = value,
                            ),
                            Divider(color: Colors.transparent),
                            PasswordField(
                              focusNode: _passwordFocus,
                              onFieldSubmitted: (val) {
                                _signIn();
                              },
                              onSaved: (String value) => _data.password = value,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: RaisedButton(
                                      child: const Text('Connexion'),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: _signIn,
                                    ))),
                          ],
                        )),
                    Divider(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          child: Text("Mot de passe oublié"),
                          onPressed: () {
                            Navigator.pushNamed(context, '/reset_password');
                          },
                        ),
                      ],
                    )
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
