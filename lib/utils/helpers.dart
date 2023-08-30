import 'dart:math';

import 'package:bufalabuona/env/app_env.dart';
import 'package:flutter/foundation.dart';

String? validateEmail(String? value) {
  const String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  final RegExp regex = RegExp(pattern);
  if (value == null || !regex.hasMatch(value)) {
    return 'Email non valida';
  } else {
    return null;
  }
}

String? validateText(String? value) {
  return value == null || value.isEmpty ? 'Inserisci un valore' : null;
}

String? validatePassword(String? value) {
  return value == null || value.isEmpty || value.length<6 ? 'Inserisci almeno 6 caratteri' : null;
}

String randomString(int length) {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  final Random r = Random();
  return String.fromCharCodes(
      Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}

Future<String?> get authRedirectUri async{

  if (kIsWeb) {
    return null;
  } else {
    return AppEnv().myAuthRedirectUri;
  }
}