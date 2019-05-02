import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/exceptions/auth.dart';
import 'package:heimdall/model/user.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

class HeimdallApi {
  String apiUrl;
  UserToken userToken;
  http.Client client = new http.Client();

  Future<Map<String, dynamic>> refreshUserToken() {
    if (userToken == null && apiUrl == null) {
      throw new AuthException(AuthExceptionType.not_authenticated);
    }
    return userToken.refresh(apiUrl);
  }

  Future<dynamic> _sendRequest(http.BaseRequest request, { bool refreshed = false }) async {
    if (userToken == null && apiUrl == null) {
      throw new AuthException(AuthExceptionType.not_authenticated);
    }

    if (userToken.isTokenExpired) {
      refreshUserToken();
    }
    
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer ${userToken.token}';
    request.headers[HttpHeaders.acceptHeader] = ContentType.json.mimeType;
    request.headers[HttpHeaders.contentTypeHeader] = ContentType.json.mimeType;
    http.StreamedResponse response = await client.send(request)
        .timeout(Duration(seconds: 10), onTimeout: () {
      throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
    });

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
  }

  Future<dynamic> get(String endpoint) async {
    return _sendRequest(new http.Request("GET", Uri.parse('$apiUrl/$endpoint')));
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final http.Request request = new http.Request("POST", Uri.parse('$apiUrl/$endpoint'));
    request.body = json.encode(data);
    return _sendRequest(request);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final http.Request request = new http.Request("POST", Uri.parse('$apiUrl/$endpoint'));
    request.body = json.encode(data);
    return _sendRequest(request);
  }

  Future<dynamic> delete(String endpoint) async {
    return _sendRequest(new http.Request("DELETE", Uri.parse('$apiUrl/$endpoint')));
  }

  Future<User> signIn(String apiUrl, String username, String password) async {
    if (apiUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw new AuthException(AuthExceptionType.bad_credentials);
    }
    this.apiUrl = apiUrl;
    Response response;
    try {
      response = await http.post('$apiUrl/login_check',
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
          body: '{"username":"$username","password":"$password"}')
          .timeout(Duration(seconds: 10), onTimeout: () {
            throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
          }
      );
    } on SocketException catch (e) {
      throw new ApiConnectException(type: ApiConnectExceptionType.unknown, errorMessage: e.toString());
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final User user = User.fromJson(data['user']);
      this.userToken = UserToken.fromJson(data);

      // Save the url & token on the phone to be able to reconnect the user later
      final storage = new FlutterSecureStorage();
      storage.write(key: 'apiUrl', value: apiUrl);
      storage.write(key: 'userToken', value: json.encode(userToken.toJson()));

      return user;
    }

    if (response.statusCode == 401) {
      throw new AuthException(AuthExceptionType.bad_credentials);
    }

    throw new AuthException(AuthExceptionType.unknown);
  }
}

class UserToken {
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
}