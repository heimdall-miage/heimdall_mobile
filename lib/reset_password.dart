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
    // TODO: implement build
    return null;
  }


}

class LoginFormData {
  String serverUrl = '';
  String username = '';
  String password = '';
}
