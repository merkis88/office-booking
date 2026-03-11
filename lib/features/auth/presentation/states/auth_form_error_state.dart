class AuthFormErrorState {
  const AuthFormErrorState({this.email, this.password});

  final String? email;
  final String? password;

  static const empty = AuthFormErrorState();

  bool get hasErrors => email != null || password != null;

  factory AuthFormErrorState.validate({
    required String email,
    required String password,
  }) {
    return AuthFormErrorState(
      email: email.isEmpty
          ? 'Введите e-mail'
          : (!email.contains('@') ? 'Введите корректный e-mail' : null),
      password: password.isEmpty ? 'Введите пароль' : null,
    );
  }

  factory AuthFormErrorState.fromApi(Map<String, String> fieldErrors) {
    return AuthFormErrorState(
      email: fieldErrors['email'],
      password: fieldErrors['password'],
    );
  }
}
