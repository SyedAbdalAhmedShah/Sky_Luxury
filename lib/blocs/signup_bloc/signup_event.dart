abstract class SignupEvent {}

class UserSignupEvent extends SignupEvent {
  final String password;
  final String userName;
  final String email;
  UserSignupEvent(
      {required this.password, required this.userName, required this.email});
}
