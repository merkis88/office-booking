import 'package:wordpice/features/auth/domain/entities/login_params.dart';

class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  factory LoginRequestModel.fromParams(LoginParams params) {
    return LoginRequestModel(email: params.email, password: params.password);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'password': password};
  }
}
