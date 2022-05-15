abstract class SignupStates {}

class InitialSignupState extends SignupStates {}

class LoadingSignupState extends SignupStates {}

class SuccessSignupState extends SignupStates {}

class FailureSignupState extends SignupStates {
  final String message;

  FailureSignupState({required this.message});
}
