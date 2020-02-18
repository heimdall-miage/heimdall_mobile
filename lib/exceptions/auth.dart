class AuthException implements Exception {
  AuthExceptionType type;
  AuthException(this.type);
  
  String get message {
    switch (type) {
      case AuthExceptionType.bad_credentials:
        return "Identifiants incorrects";
        break;
      case AuthExceptionType.not_authenticated:
        return "Vous devez vous connecter";
        break;
      case AuthExceptionType.invalid_token:
      case AuthExceptionType.invalid_refresh_token:
        return "Reconnexion nécessaire";
        break;
      default:
        return "Erreur inconnue lors de l'authentification";
        break;
    }
  }

  @override
  String toString() {
    return "AuthException: " + message;
  }
}

enum AuthExceptionType { bad_credentials, not_authenticated, invalid_token, invalid_refresh_token, unknown }