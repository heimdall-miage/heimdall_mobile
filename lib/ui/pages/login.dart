import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/exceptions/auth.dart';
import 'package:heimdall/helper/validation.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/ui/components/password_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;

class Login extends StatefulWidget {
  @override
  State createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String verificationId;
  LoginFormData _data = LoginFormData();
  TextEditingController _urlController = TextEditingController();
  bool _urlIsValid;
  FocusNode _urlFocus = FocusNode();
  FocusNode _usernameFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _loading = false;
  final storageL = new FlutterSecureStorage();
  
  /* List data;

  Future<String> getData() async {
    debugPrint("début");
    try {
      var response = await http.get(
      "http://192.168.1.44:8000/api/etudiant/?format=json",
      headers: {
        "Accept": "application/json"
      }
    );
         // print("frvf");
    //data = json.decode(response.body);
    data = jsonDecode(response.body);
    
    /*this.setState(() {
      data = json.decode(response.body);
    });*/
    //print("toto");
    }
    catch(error) 
    {
      print("Erreur :");
      print(error);
    }
    
    
    
    
    //debugPrint(data.toString());
    
    return "Success!";
  }*/

  @override
  void initState() {
    super.initState();
    _urlController.text = AppModel.of(context).api?.apiUrl;
    _urlFocus.addListener(() {
      if (!_urlFocus.hasFocus) {
        _verifyServerUrl(_urlController.text);
      }
    });
    //this.getData();
  }

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

  Future<String> _verifyServerUrl(String url) async {
    //final validateResult = Validator.validateUrl(url);
    // Url format is not valid and does not contains http, try with https
    print('url'+url);
    if (url != null && !url.contains('http')) {
      url = url + ':8000/api';
      return await _verifyServerUrl('http://' + url);
    } else if (url == null) {
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);
      if (!url.contains('api')) url += ':8000/api';
      print('Verify : $url');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          //if (data.containsKey('result') && data['result'] == 'heimdall') {
            setState(() {
              this._urlIsValid = true;
              _urlController.text = url;
            });
            return url;
          //}
        }
      } catch (e) {
        // If https don't work, try with http protocol
        if (url.contains('https://')) {
          return await _verifyServerUrl(url.replaceFirst('https', 'http'));
        }
      }
    }

    setState(() {
      this._urlIsValid = true;
      _urlController.text = url;
    });

    return url;
  }

  Future<void> _signIn() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      _formKey.currentState.save();
      try {
        await AppModel.of(context).signIn(_data.serverUrl, _data.username, _data.password);

        // TEMP
        setState(() {
          _loading = false;
        });
        String role = await storageL.read(key: 'userRole');
        Navigator.pushNamedAndRemoveUntil(
            context, '/' + role.toString().toLowerCase() + '/home', (Route<dynamic> route) => false);
      } on AuthException catch (e) {
        _showLoginErrorDialog(e);
        setState(() {
          _loading = false;
        });
      } on ApiConnectException catch (e) {
        _showLoginErrorDialog(e);
        setState(() {
          _loading = false;
        });
      } catch (e) {
        print(e); // TODO handler
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
                                //errorText: _urlIsValid == false ? "Ce serveur Heimdall n'existe pas" : null,
                              ),
                              //validator: Validator.validateUrl,
                              textInputAction: TextInputAction.next,
                              focusNode: _urlFocus,
                              controller: _urlController,
                              onFieldSubmitted: (val) {
                                _urlFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_usernameFocus);
                              },
                              onSaved: (String value) => _data.serverUrl = value,
                            ),
                            Divider(color: Colors.transparent),
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
