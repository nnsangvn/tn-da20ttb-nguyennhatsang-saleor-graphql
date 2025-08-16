abstract class LoginEvent {}

class LoginSubmit extends LoginEvent {
  final String email;
  final String password;

  LoginSubmit({required this.email, required this.password});
}
