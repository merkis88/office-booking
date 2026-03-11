import 'package:wordpice/features/auth/domain/entities/register_params.dart';

class RegisterRequestModel {
  const RegisterRequestModel({
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

  factory RegisterRequestModel.fromParams(RegisterParams params) {
    return RegisterRequestModel(
      firstName: params.firstName,
      lastName: params.lastName,
      patronymic: params.patronymic,
      email: params.email,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'patronymic': patronymic,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
