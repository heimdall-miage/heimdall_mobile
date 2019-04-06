import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/model/user.dart';
import "package:http/http.dart" as http;
import 'package:scoped_model/scoped_model.dart';

class HeimdallApi extends Model {
  static HeimdallApi of(BuildContext context) => ScopedModel.of<HeimdallApi>(context);

  // TODO Save url + token/refreshToken, keystore ? ==> https://pub.dartlang.org/packages/flutter_secure_storage

  String _clientApiUrl; // TEMP (dev) : http://192.168.1.20/api
  User user;

  set clientApiUrl(String clientApiUrl) {
    if (clientApiUrl.endsWith('/')) {
      clientApiUrl = clientApiUrl.substring(0, clientApiUrl.length - 1);
    }
    this._clientApiUrl = clientApiUrl;
  }
  get clientApiUrl => _clientApiUrl;

  Future<http.Response> _get(String endpoint, { bool refreshed = false }) async {
    try {
      final response = await http.get('$_clientApiUrl/$endpoint', headers: {'Authorization': 'Bearer ${user.token}'});

      print(response.body);
      switch (response.statusCode) {
        case 200:
          return response;
        case 401:
          if (refreshed) {
            throw new Exception("Connexion refusée.");
            // TODO : Redirection login screen, connexion refusée
          }
          await _refreshToken();
          return _get(endpoint, refreshed: true);
      }

    } on Exception catch (e) {
      print(e.toString()); // TODO
    }

    return null;
  }

  Future<User> login(String apiUrl, String username, String password) async {
    clientApiUrl = apiUrl;
    final response = await http.post('$_clientApiUrl/login_check',
        headers: {'Content-Type': 'application/json'},
        body: '{"username":"$username","password":"$password"}');

    // TODO : Handle most of response code with custom messages
    if (response.statusCode == 200) {
      this.user = User.fromApiJson(username, json.decode(response.body));

      final storage = new FlutterSecureStorage();
      storage.write(key: 'apiUrl', value: apiUrl);
      storage.write(key: 'user', value: json.encode(user.toJson()));

      return this.user;
    }

    if (response.statusCode == 401) {
      throw Exception("Identifiants incorrects.");
    }

    throw Exception("Erreur inconnue lors de l'identification.");
  }

  Future<User> _refreshToken() async {
    if (this.user == null) {
      return null;
    }
    final response = await http.post('$_clientApiUrl/token/refresh', body: {'refresh_token': this.user.refreshToken});

    if (response.statusCode == 200) { // TODO : Gérer erreurs
      Map data = json.decode(response.body);
      this.user.token = data['token'];
      this.user.type = data['type'];
      return this.user;
    }

    throw Exception("Reconnexion nécessaire.");
  }

  Future<User> resumeExistingConnection() async {
    // No user in memory (probably the app was closed and reopen)
    if (user == null) {
      final storage = new FlutterSecureStorage();
      Map<String, String> storedInfos = await storage.readAll();

      if (!storedInfos.containsKey("apiUrl")) {
        return null;
      }
      this.clientApiUrl = storedInfos['apiUrl'];

      if (!storedInfos.containsKey("user")) {
        return null;
      }
      this.user = User.fromStoredJson(json.decode(storedInfos['user']));
    }

    return _refreshToken();
  }

  Future<String> test() async {
    final response = await _get("test");
    return response.body.toString();
  }
}
