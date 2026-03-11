import 'package:wordpice/features/auth/domain/entities/registered_user.dart';

class VerifyEmailResult {
  const VerifyEmailResult({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  final bool success;
  final String message;
  final RegisteredUser user;
  final String token;
}
