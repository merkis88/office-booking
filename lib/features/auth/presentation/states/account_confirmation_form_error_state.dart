class AccountConfirmationFormErrorState {
  const AccountConfirmationFormErrorState({this.email, this.code});

  final String? email;
  final String? code;

  static const empty = AccountConfirmationFormErrorState();

  bool get hasErrors => email != null || code != null;

  factory AccountConfirmationFormErrorState.validate({
    required String email,
    required String code,
  }) {
    return AccountConfirmationFormErrorState(
      email: email.isEmpty
          ? 'Поле e-mail не заполнено'
          : (!email.contains('@') ? 'Неверный формат e-mail' : null),
      code: code.isEmpty
          ? 'Код подтверждения обязателен'
          : (code.length != 6 ? 'Код должен содержать 6 символов' : null),
    );
  }

  factory AccountConfirmationFormErrorState.fromApi(
    Map<String, String> fieldErrors,
  ) {
    return AccountConfirmationFormErrorState(
      email: fieldErrors['email'],
      code: fieldErrors['code'],
    );
  }
}
