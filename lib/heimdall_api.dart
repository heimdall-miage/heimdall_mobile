import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/exceptions/auth.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/model/user.dart';
import "package:http/http.dart" as http;
import 'package:onesignal/onesignal.dart';

import 'model/class_group.dart';

class HeimdallApi {
  String apiUrlProtocol;
  String apiUrlHostname;
  String apiUrlBaseEndpoint;
  String userToken;
  http.Client client = new http.Client();
  final storage = new FlutterSecureStorage();

  Future<List<Etudiant>> getStudentsInClass(int classId) async {
    dynamic result = await get('class/$classId/students');
    return new List<Etudiant>.from(result.map((x) => Etudiant.fromJson(x)));
  }

  Future<List<ClassGroup>> getClasses() async {
    dynamic result = await get('class');
    return new List<ClassGroup>.from(result.map((x) => ClassGroup.fromJson(x)));
  }

  Future<List<RollCall>> getRollCalls([int limit]) async {
    dynamic result = await get('rollcall', limit == null ? null : {'limit': limit.toString()});
    return new List<RollCall>.from(result.map((x) => RollCall.fromJson(x)));
  }

  Future<List<RollCall>> getRollCallsLastWeek() async {
    dynamic result = await get('rollcall/lastweek');
    return new List<RollCall>.from(result.map((x) => RollCall.fromJson(x)));
  }

  Future<RollCall> updateRollCall(RollCall rollCall) async {
    dynamic result = await put('rollcall/${rollCall.id}', rollCall.toJson());
    return RollCall.fromJson(result);
  }

  Future<RollCall> createRollCall(RollCall rollCall) async {
    dynamic result = await post('rollcall', rollCall.toJson());
    return RollCall.fromJson(result);
  }

  Future<List<StudentPresence>> getStudentPresences() async {
    dynamic result = await get('student/presence');
    return new List<StudentPresence>.from(result.map((x) => StudentPresence.fromJson(x)));
  }

  Future<List<StudentPresence>> getStudentRetards() async {
    dynamic result = await get('student/Retards');
    return new List<StudentPresence>.from(result.map((x) => StudentPresence.fromJson(x)));
  }


  Future<List<String>> getExcuses() async {
    dynamic result = await get('student/presence/excuses');
    return new List<String>.from(result);
  }

  /*void ResetPassword() async {
    dynamic result = await get('student/reset_password');
  }*/

  Map<String, String> get authHeader {
    return {
      HttpHeaders.authorizationHeader: 'json ${userToken.toString()}',
    };
  }

  String get serverRootUrl {
    return apiUrlProtocol + '://' + apiUrlHostname + '/';
  }

  String get apiUrl {
    if (apiUrlProtocol == null || apiUrlHostname == null || apiUrlBaseEndpoint == null) {
      return null;
    }
    String url = apiUrlProtocol + '://' + apiUrlHostname + apiUrlBaseEndpoint;
    return url;
  }

  set apiUrl(String url) {
    Uri uri = Uri.parse(url);
    apiUrlProtocol = uri.scheme;
    apiUrlHostname = uri.host;
    print(apiUrlHostname);
    if(!apiUrlHostname.endsWith(':8000')) {
      apiUrlHostname = apiUrlHostname + ':8000';
    }
    apiUrlBaseEndpoint = uri.path;
    if (apiUrlBaseEndpoint.endsWith('/')) {
      apiUrlBaseEndpoint = apiUrlBaseEndpoint.substring(0, apiUrlBaseEndpoint.length - 1);
    }
  }

  Uri getApiUri(String endpoint, [Map<String, String> parameters]) {
    Uri uri;
    if (apiUrlProtocol == 'https') {
      uri = Uri.https(apiUrlHostname, apiUrlBaseEndpoint + '/' + endpoint, parameters);
    } else {
      uri = Uri.http(apiUrlHostname, apiUrlBaseEndpoint + '/' + endpoint, parameters);
    }
    return uri;
  }

  Future<String> refreshUserToken() async {
    if (userToken == null && apiUrlHostname == null) {
      throw new AuthException(AuthExceptionType.not_authenticated);
    }
    return storage.read(key: 'userToken');
  }

 /* Future<dynamic> _sendRequest(http.BaseRequest request, { bool refreshed = false }) async {
    if (userToken == null && apiUrl == null) {
      throw new AuthException(AuthExceptionType.not_authenticated);
    }

    if (userToken == null) {
      refreshUserToken();
    }
    userToken = storage.read(key: 'userToken').toString();
    String tok = userToken.toString();
    print('Bearer ${tok}');
    request.headers[HttpHeaders.authorizationHeader] = 'token ${userToken.toString()}';
    request.headers[HttpHeaders.acceptHeader] = ContentType.json.mimeType;
    request.headers[HttpHeaders.contentTypeHeader] = ContentType.json.mimeType;
    http.StreamedResponse response = await client.send(request)
        .timeout(Duration(seconds: 30), onTimeout: () {
      throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
    });
    print(request.headers[HttpHeaders.authorizationHeader]);
    final responseBody = json.decode((await http.Response.fromStream(response)).body);
    print(responseBody);
    switch (response.statusCode) {
      case 200:
      case 201:
        return responseBody;
      case 401:
      // The token may have expired, we try to refresh it and send the request again
        if (refreshed == true) { // Second 401 => logout.
          throw new AuthException(AuthExceptionType.invalid_token);
          // TODO : Redirection login screen, connection refused
        }
        refreshUserToken();
        return _sendRequest(request, refreshed: true);
      default:
        String message = response.reasonPhrase;
        if (responseBody is Map<String, dynamic> && responseBody.containsKey('message')) {
          message = responseBody['message'];
        }
        throw new ApiConnectException(type: ApiConnectExceptionType.http, responseStatusCode: response.statusCode, errorMessage: message);
    }
  }*/

  Future<dynamic> get(String endpoint, [Map<String, String> parameters]) async {
    Map<String,String> param = {'Authorization': 'token $userToken'};
    print("endpoint:" +endpoint);
    print("param:"+param.toString());
    print(getApiUri(endpoint, param));
    return new http.Request("GET", getApiUri(endpoint, param));
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final http.Request request = new http.Request("POST", getApiUri(endpoint));
    request.body = json.encode(data);
    return request;
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final http.Request request = new http.Request("POST", getApiUri(endpoint));
    request.body = json.encode(data);
    return request;
  }

  Future<dynamic> delete(String endpoint) async {
    return new http.Request("DELETE", getApiUri(endpoint));
  }

  /*_registerOneSignal(String onesignalAppId, User user) async {
    try {
      print('REGISTER TO ONESIGNAL : ' + onesignalAppId);
      await OneSignal.shared.init(onesignalAppId, iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: true
      });
      await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

      OSPermissionSubscriptionState state = await OneSignal.shared.getPermissionSubscriptionState();

      print('ONESIGNAL USER ID : ' + state.subscriptionStatus.userId);

      dynamic result = await post('device_subscribe', { 'id': state.subscriptionStatus.userId});
      print('ONESIGNAL SUBSCRIBE API RESULT : ');
      print(result);
    } catch (e) {
      print("FAIL ONESIGNAL : " + e.toString());
    }
  }*/

  Future<User> signIn(String apiUrl, String username, String password) async {
    User user;
    if (apiUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw new AuthException(AuthExceptionType.bad_credentials);
    }
    this.apiUrl = apiUrl;
    http.Response response;
    print('$apiUrl/api/utilisateur/connexion');
    var bodytext = jsonEncode({ 'username': '$username', 'password': '$password' });
    //'{"username":"$username","password":"$password"}'
    try {
      response = await http.post('$apiUrl/utilisateur/connexion',
          headers: {"Content-Type": "application/json"},
          body: bodytext)
          .timeout(Duration(seconds: 10), onTimeout: () {
            throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
          }
      );
    } on SocketException catch (e) {
      throw new ApiConnectException(type: ApiConnectExceptionType.unknown, errorMessage: e.toString());
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String token = data['token'];
      print(data['token']);
      http.Response responseUtil;
      try {
        responseUtil = await http.get('$apiUrl/utilisateur/user_connecte',
            headers: {"Authorization": "token $token"})
            .timeout(Duration(seconds: 10), onTimeout: () {
              throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
            }
        );
      } on SocketException catch (e) {
        throw new ApiConnectException(type: ApiConnectExceptionType.unknown, errorMessage: e.toString());
      }
      if (responseUtil.statusCode == 200) {
        Map<String, dynamic> dataUser = json.decode(responseUtil.body);
        print(dataUser);
        final User user = User.fromJson(dataUser);
        print(user);
        /*this.userToken = UserToken.fromJson(data);
        print("token");
        print(this.userToken);*/

        //_registerOneSignal("heimdall", user);

        // Save the url & token on the phone to be able to reconnect the user later
        final storage = new FlutterSecureStorage();
        storage.write(key: 'apiUrl', value: apiUrl);
        storage.write(key: 'userToken', value: token);
        storage.write(key: 'userRole', value: dataUser['role']);
      }
      else {
        print("erreur user");
      }
      

     /* */

      return user;
    }

    if (response.statusCode == 401) {
      throw new AuthException(AuthExceptionType.bad_credentials);
    }

    throw new AuthException(AuthExceptionType.unknown);
  }
}

/*class UserToken {
  String refreshToken;
  int refreshTokenExpires;
  String token;
  int tokenExpires;

  UserToken({this.token, this.refreshToken, this.tokenExpires, this.refreshTokenExpires});

  factory UserToken.fromJson(Map<String, dynamic> json) {
    return UserToken(
      refreshToken: json['refresh_token'],
      refreshTokenExpires: json['refresh_token_expires'],
      token: json.containsKey('token') ? json['token'] : null,
      tokenExpires: json.containsKey('token_expires') ? json['token_expires'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'refresh_token': refreshToken,
    'refresh_token_expires': refreshTokenExpires,
  };

  bool get isTokenExpired => tokenExpires == null ? false : DateTime.now().millisecondsSinceEpoch >= tokenExpires;
  bool get isRefreshTokenExpired => refreshTokenExpires == null ? false : DateTime.now().millisecondsSinceEpoch >= refreshTokenExpires;

  // Returns the actualized user infos if successfull
  Future<Map<String, dynamic>> refresh(String apiUrl) async {
    if (!isRefreshTokenExpired) {
      http.Response response;
      try {
        response = await http.post(
            '$apiUrl/token/refresh', body: {'refresh_token': refreshToken})
            .timeout(Duration(seconds: 10), onTimeout: () {
              throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
            });
      } on SocketException catch (e) {
        throw new ApiConnectException(type: ApiConnectExceptionType.unknown, errorMessage: e.toString());
      }
      if (response.statusCode == 200) {
        Map<String, dynamic> newTokenData = json.decode(response.body);
        this.refreshToken = newTokenData['refresh_token'];
        this.refreshTokenExpires = newTokenData['refresh_token_expires'];
        this.token = newTokenData['token'];
        this.tokenExpires = newTokenData['token_expires'];

        // Update the stored token
        final storage = new FlutterSecureStorage();
        storage.write(key: 'userToken', value: json.encode(this.toJson()));

        return newTokenData['user'];
      }
    }

    throw new AuthException(AuthExceptionType.invalid_refresh_token);
  }
}*/