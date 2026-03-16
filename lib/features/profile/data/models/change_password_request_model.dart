import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';

class ChangePasswordRequestModel {
  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  factory ChangePasswordRequestModel.fromParams(ChangePasswordParams params) {
    return ChangePasswordRequestModel(
      currentPassword: params.currentPassword,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
