abstract class LoginEvents {}

class UserLoginEvent extends LoginEvents {
  final String email;
  final String password;
  UserLoginEvent({required this.email, required this.password});
}

class AdminLoginEvent extends LoginEvents {
  final String email;
  final String password;
  AdminLoginEvent({required this.email, required this.password});
}

class ResetPasswordEvent extends LoginEvents {
  final String email;
  ResetPasswordEvent({required this.email});
}
