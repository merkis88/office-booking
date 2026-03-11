class VerifyEmailParams {
  const VerifyEmailParams({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;
}
