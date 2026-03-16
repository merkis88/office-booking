class ChangePasswordFormErrorState {
  const ChangePasswordFormErrorState({
    this.currentPassword,
    this.password,
    this.confirmPassword,
  });

  static const empty = ChangePasswordFormErrorState();

  final String? currentPassword;
  final String? password;
  final String? confirmPassword;

  bool get hasErrors =>
      currentPassword != null || password != null || confirmPassword != null;

  factory ChangePasswordFormErrorState.validate({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return ChangePasswordFormErrorState(
      currentPassword: currentPassword.trim().isEmpty
          ? 'Введите текущий пароль'
          : null,
      password: password.trim().isEmpty ? 'Введите новый пароль' : null,
      confirmPassword: passwordConfirmation.trim().isEmpty
          ? 'Подтвердите пароль'
          : (password.trim().isNotEmpty && password != passwordConfirmation
                ? 'Пароли не совпадают!'
                : null),
    );
  }
}
