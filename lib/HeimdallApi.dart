import 'dart:async';
import 'dart:convert';
import "package:http/http.dart" as http;

class HeimdallApi {
  // TODO : Gérer ça via une config à faire au lancement de l'appli, keystore ? ==> https://pub.dartlang.org/packages/flutter_secure_storage
  static final String clientApiUrl = "http://192.168.1.20/api";
  ApiAccess apiAccess;

  Future<bool> login(String username, String password) async {
    Map data = {'username': username, 'password': password};
    final response = await http.post('$clientApiUrl/login_check', headers: {'Content-Type': 'application/json'}, body: json.encode(data));

    if (response.statusCode == 200) { // TODO : Gérer erreurs
      apiAccess = ApiAccess.fromJson(json.decode(response.body));
      return true;
    }

    return false;
  }

  Future<bool> refreshToken() async {
    final response = await http.post('$clientApiUrl/token/refresh', body: {'refresh_token': apiAccess.refreshToken});

    if (response.statusCode == 200) { // TODO : Gérer erreurs
      apiAccess = ApiAccess.fromJson(json.decode(response.body));
      return true;
    }

    return false;
  }

  Future<String> test() async {
    final response = await get("test");
    return response.body.toString();
  }

  Future<http.Response> get(String endpoint, { bool refreshed = false }) async {
    try {
      final response = await http.get('$clientApiUrl/$endpoint', headers: {'Authorization': 'Bearer ${apiAccess.token}'});

      switch (response.statusCode) {
        case 200:
          print('Return response');
          return response;
        case 401:
          if (refreshed) {
            return null; // TODO : Redirection login screen, connexion refusée
          }
          await refreshToken();
          return get(endpoint, refreshed: true);
      }

    } on Exception catch (e) {
      print(e.toString()); // TODO
    }

    return null;
  }
}

class ApiAccess {
  final String token;
  final String refreshToken;

  ApiAccess({this.token, this.refreshToken});

  factory ApiAccess.fromJson(Map<String, dynamic> json) {
    return ApiAccess(
      token: json['token'],
      refreshToken: json['refresh_token'],
    );
  }
}
