import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/core/theme/app_text_styles.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/domain/entities/forgot_password_params.dart';
import 'package:wordpice/features/auth/presentation/widgets/buttons/auth_action_button.dart';
import 'package:wordpice/features/auth/presentation/widgets/cards/auth_form_card.dart';
import 'package:wordpice/features/auth/presentation/widgets/sections/auth_text.dart';
import 'package:wordpice/features/auth/presentation/widgets/styles/auth_styles.dart';
import 'package:wordpice/features/splash/presentation/widgets/splash_logo.dart';
import 'forgot_password_email_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  String? _emailError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _goToEmailSent() async {
    final email = _emailController.text.trim();

    setState(() {
      _emailError = _validateEmail(email);
    });

    if (_emailError != null) return;

    setState(() => _isSubmitting = true);

    try {
      await AppScope.of(context).authRepository.forgotPassword(
        ForgotPasswordParams(email: email),
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ForgotPasswordEmailSentScreen()),
      );
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _emailError = error.fieldErrors['email'] ?? error.message;
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      setState(() {
        _emailError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Введите электронную почту';
    if (!email.contains('@')) return 'Введите корректную электронную почту';
    return null;
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SplashLogo(),
                  const SizedBox(height: 44),
                  IconButton(
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(28, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AuthStyles.screenPadding,
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: AuthFormCard(
                      padding: AuthStyles.formPaddingCompact,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Забыли пароль?',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.title26,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Center(
                            child: AuthHelperText(
                              'Введите адрес эл. почты от аккаунта,\nмы отправим Вам временный пароль\nдля входа в аккаунт',
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'Эл.почта*',
                            style: AppTextStyles.label12Grey.copyWith(
                              fontFamily: AuthStyles.interFontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: AppInputDecorations.authField(
                              hintText: 'Введите электронную почту',
                              errorText: _emailError,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Center(
                            child: SizedBox(
                              width: 200,
                              child: AuthActionButton(
                                label: _isSubmitting
                                    ? 'Отправка...'
                                    : 'Отправить',
                                onPressed: _isSubmitting ? null : _goToEmailSent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
