import 'package:wordpice/features/auth/domain/entities/registered_user.dart';

class RegisterResult {
  const RegisterResult({
    required this.success,
    required this.message,
    required this.user,
  });

  final bool success;
  final String message;
  final RegisteredUser user;
}
