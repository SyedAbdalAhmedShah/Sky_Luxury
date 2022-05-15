import 'package:sky_luxury/components/strings.dart';

String? validateEmail(String? email) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  if (email == null) {
    return null;
  } else {
    if (email.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(email)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }
}

String? validatePassword(String? password) {
  if (password == null || password == "") {
    return Strings.passwordRequired;
  } else if (password.length < 6) {
    return Strings.passwordValidationText;
  }
  return null;
}

String? validateName(String? name) {
  if (name == null) {
    return null;
  } else {
    if (name.length == 0) {
      return "Name field cannot be empty";
    } else {
      return null;
    }
  }
}
