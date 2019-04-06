class AuthException implements Exception {
  AuthExceptionType type;
  AuthException(this.type);

  // TODO : Translation auto?
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
      case AuthExceptionType.timeout:
        return "La connexion a pris trop de temps";
        break;
      default:
        return "Erreur inconnue lors de l'authentification";
        break;
    }
  }
}

enum AuthExceptionType { bad_credentials, not_authenticated, invalid_token, invalid_refresh_token, timeout, unknown }