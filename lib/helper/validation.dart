class Validator {
  // TODO : Translations
  static String validatePhoneNumber(String phone) {
    RegExp regExp = RegExp(r'^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$');
    if (phone.isNotEmpty && regExp.hasMatch(phone)) {
      return null;
    }
    return 'Votre numéro de téléphone n\'est pas valide.';
  }

  static String validateZip(String zip) {
    if (zip.isNotEmpty && zip.length == 5 && int.tryParse(zip) != null) {
      return null;
    }
    return 'Ce code postal est invalide, il doit être composé de 5 chiffres.';
  }

  static String validateString(String str) {
    if (str.isNotEmpty) {
      return null;
    }
    return 'Ce champ ne peut pas être vide.';
  }

  static String validateUsername(String username) {
    if (username.isNotEmpty) {
      return null;
    }
    return 'Votre nom d\'utilisateur ne peut pas être vide.';
  }

  static String validateEmail(String email) {
    RegExp regExp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (email.isNotEmpty && regExp.hasMatch(email)) {
      return null;
    }
    return 'Votre adresse email n\'est pas valide.';
  }

  static String validateUrl(String url) {
    try {
      Uri.parse(url);
      return null;
    } on FormatException catch (e) {
      return 'L\'url n\'est pas valide.';
    }
  }
}