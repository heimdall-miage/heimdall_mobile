import 'dart:async';
import 'dart:convert';
import "package:http/http.dart" as http;

class HeimdallApi {
  // TODO : Gérer ça via une config à faire au lancement de l'appli, keystore ? ==> https://pub.dartlang.org/packages/flutter_secure_storage
  static final String clientId = "6_10hitwtgqdesw4k8sc44wgsogcos8840owcso0ok04cwgskkwg";
  static final String clientSecret = "1wk8ojwd5ts00osos8wssgkcowooowgs84444ocsc444wg0wcw";
  static final String clientTokenUrl = "http://192.168.1.20/oauth/v2/token";
  static final String clientApiUrl = "http://192.168.1.20/api";
  ApiAccess apiAccess;

  Future<bool> login(String username, String password) async {
    final response = await http.get('$clientTokenUrl?client_id=$clientId&client_secret=$clientSecret&grant_type=password&username=$username&password=$password');

    if (response.statusCode == 200) { // TODO : Gérer erreurs
      apiAccess = ApiAccess.fromJson(json.decode(response.body));
      return true;
    }

    return false;
  }

  Future<bool> refreshToken() async {
    final response = await http.get('$clientTokenUrl?client_id=$clientId&client_secret=$clientSecret&grant_type=refresh_token&refresh_token=' + apiAccess.refreshToken);

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
      final response = await http.get('$clientApiUrl/$endpoint?access_token=' + apiAccess.accessToken);

      if (response.statusCode == 200) {
        return response;
      }

      if (refreshed) {
        // TODO : Déjà refreshed sans succès, on invalide la connexion => Redirection home login
        print('TODO : déjà refreshed');
        return null;
      } else {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json['error'] == 'invalid_grant') {
          print('INVALID GRANT, trying token refresh...');
          if (await refreshToken()) {
            return get(endpoint, refreshed: true);
          }
        } else if (json['error'] == 'access_denied') {
          // TODO : Message access denied
          print('ACCESS DENIED');
        } else {
          print('Error : ${json["error"]} : ${json["error_description"]}');
        }
      }
    } on Exception catch (e) {
      print(e.toString()); // TODO
    }

    return null;
  }
}

class ApiAccess {
  final String accessToken;
  final int expiresIn;
  final String scope;
  final String refreshToken;

  ApiAccess({this.accessToken, this.expiresIn, this.scope, this.refreshToken});

  factory ApiAccess.fromJson(Map<String, dynamic> json) {
    return ApiAccess(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      scope: json['scope'],
      refreshToken: json['refresh_token'],
    );
  }
}
