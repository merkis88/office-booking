class RegisterParams {
  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  final String firstName;
  final String lastName;
  final String patronymic;
  final String email;
  final String password;
  final String passwordConfirmation;
}
