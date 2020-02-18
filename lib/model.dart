import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/heimdall_api.dart';
import 'package:heimdall/helper/flash.dart';
import 'package:heimdall/model/user.dart';
import 'package:scoped_model/scoped_model.dart';
import "package:http/http.dart" as http;


class AppModel extends Model {
  static AppModel of(BuildContext context) => ScopedModel.of<AppModel>(context);
  final GlobalKey navigator = GlobalKey<NavigatorState>();
  final HeimdallApi api = new HeimdallApi();
  Flash _flash;
  User user;
  bool get isLoggedIn => user != null;

  set flash(flash) => _flash = flash;
  Flash get flash {
    Flash flash = _flash;
    _flash = null;
    return flash;
  }

  Future<void> signIn(String apiUrl, String username, String password) async {
    this.user = await api.signIn(apiUrl, username, password);
  }

  Future<void> signOut() async {
    await api.delete('token/refresh');
    user = null;
    deleteStoredToken();
  }

  void deleteStoredToken() {
    final storage = new FlutterSecureStorage();
    storage.delete(key: "userToken");
  }

  Future<User> resumeExistingConnection() async {
    // No user in memory (probably the app was closed and reopen)
    print("usertok:"+api.userToken.toString());
         final storage = new FlutterSecureStorage();
     String apiUrl = api.apiUrl;
    if (api.userToken == null) {
      print('Getting token from storage');
 

      

      if (apiUrl == null) {
        return null;
      }
      this.api.apiUrl = apiUrl;

      final String userToken = await storage.read(key: "userToken");
      this.api.userToken = userToken.toString();
      if (userToken == null) {
        return null;
      }
      print('$apiUrl/utilisateur/user_connecte');
      print({"Authorization": "token $userToken"});
      http.Response responseUtil;
      try {
        responseUtil = await http.get('$apiUrl/utilisateur/user_connecte',
            headers: {"Authorization": "token $userToken"})
            .timeout(Duration(seconds: 10), onTimeout: () {
              throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
            }
        );
      } on SocketException catch (e) {
        throw new ApiConnectException(type: ApiConnectExceptionType.unknown, errorMessage: e.toString());
      }
      print("resp"+responseUtil.statusCode.toString());
      if (responseUtil.statusCode == 200) {
        Map<String, dynamic> dataUser = json.decode(responseUtil.body);
        print(dataUser);
        this.user = User.fromJson(dataUser);
        this.api.userToken = userToken;
      }
      
      //this.api.userToken = UserToken.fromJson(json.decode(userToken));
    }

    //this.user = User.fromJson(await api.refreshUserToken());

    return this.user;
  }
}
