class ApiConnectException implements Exception {
  ApiConnectExceptionType type;
  int responseStatusCode;
  String errorMessage;
  ApiConnectException({this.type, this.responseStatusCode, this.errorMessage});

  String get message {
    switch (type) {
      case ApiConnectExceptionType.http:
        if (responseStatusCode == null && errorMessage == null) {
          return "Erreur HTTP inconnue";
        }
        return responseStatusCode.toString() + ": " + errorMessage;
        break;
      case ApiConnectExceptionType.timeout:
        return "La connexion a pris trop de temps";
        break;
      default:
        return "Erreur HTTP: " + errorMessage;
        break;
    }
  }

  @override
  String toString() {
    return "ApiConnectException: " + message;
  }
}

enum ApiConnectExceptionType { timeout, http, unknown }