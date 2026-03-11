class RegisterFormErrorState {
  const RegisterFormErrorState({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.confirmPassword,
    this.personalData,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? personalData;

  static const empty = RegisterFormErrorState();

  bool get hasErrors =>
      firstName != null ||
      lastName != null ||
      email != null ||
      password != null ||
      confirmPassword != null ||
      personalData != null;

  RegisterFormErrorState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? personalData,
  }) {
    return RegisterFormErrorState(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      personalData: personalData,
    );
  }

  factory RegisterFormErrorState.validate({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool isPersonalDataAccepted,
  }) {
    return RegisterFormErrorState(
      firstName: firstName.isEmpty ? 'Введите имя' : null,
      lastName: lastName.isEmpty ? 'Введите фамилию' : null,
      email: email.isEmpty
          ? 'Поле e-mail не заполнено'
          : (!email.contains('@') ? 'Введите корректный e-mail' : null),
      password: password.isEmpty ? 'Введите пароль' : null,
      confirmPassword: passwordConfirmation.isEmpty
          ? 'Подтвердите пароль'
          : (password.isNotEmpty && password != passwordConfirmation
                ? 'Пароли не совпадают'
                : null),
      personalData: isPersonalDataAccepted
          ? null
          : 'Подтвердите согласие на обработку персональных данных',
    );
  }

  factory RegisterFormErrorState.fromApi(Map<String, String> fieldErrors) {
    return RegisterFormErrorState(
      firstName: fieldErrors['first_name'],
      lastName: fieldErrors['last_name'],
      email: fieldErrors['email'],
      password: fieldErrors['password'],
      confirmPassword: fieldErrors['password_confirmation'],
    );
  }
}
