import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

abstract class LoginStates {}

class InitialLoginEvent extends LoginStates {}

class LoadingLoginEvent extends LoginStates {}

class SuccessLoginEvent extends LoginStates {
  final UserCredential authResult;
  final bool isAdmin;
  SuccessLoginEvent({required this.authResult, required this.isAdmin});
}

class FailureLoginEvent extends LoginStates {
  final String message;

  FailureLoginEvent({required this.message});
}

class ResetPasswordSuccessfully extends LoginStates {}
