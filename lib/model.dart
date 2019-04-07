import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/heimdall_api.dart';
import 'package:heimdall/model/user.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model {
  static AppModel of(BuildContext context) => ScopedModel.of<AppModel>(context);
  final GlobalKey navigator = GlobalKey<NavigatorState>();
  final HeimdallApi api = new HeimdallApi();
  User user;

  Future<void> signIn(String apiUrl, String username, String password) async {
    this.user = await api.signIn(apiUrl, username, password);
  }

  Future<User> resumeExistingConnection() async {
    // No user in memory (probably the app was closed and reopen)
    if (api.userToken == null) {
      print('Getting token from storage');
      final storage = new FlutterSecureStorage();

      final String apiUrl = await storage.read(key: "apiUrl");
      if (apiUrl == null) {
        return null;
      }
      this.api.apiUrl = apiUrl;

      final String userToken = await storage.read(key: "userToken");
      if (userToken == null) {
        return null;
      }
      this.api.userToken = UserToken.fromJson(json.decode(userToken));
    }

    this.user = User.fromJson(await api.refreshUserToken());

    return this.user;
  }


  /// Test endpoint (TEMP)
  Future<String> test() async {
    final data = await api.get("test");
    return data[0];
  }
}
