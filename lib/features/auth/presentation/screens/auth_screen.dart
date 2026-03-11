import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/core/widgets/layout/app_logo_top_left.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/domain/entities/login_params.dart';
import 'package:wordpice/features/auth/presentation/screens/account_confirmation_screen.dart';
import 'package:wordpice/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:wordpice/features/auth/presentation/screens/register_screen.dart';
import 'package:wordpice/features/auth/presentation/states/auth_form_error_state.dart';
import 'package:wordpice/features/auth/presentation/widgets/buttons/auth_action_button.dart';
import 'package:wordpice/features/auth/presentation/widgets/cards/auth_form_card.dart';
import 'package:wordpice/features/auth/presentation/widgets/sections/auth_text.dart';
import 'package:wordpice/features/auth/presentation/widgets/styles/auth_styles.dart';
import 'package:wordpice/features/profile/presentation/screens/profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _statusMessage;
  AuthFormErrorState _errors = AuthFormErrorState.empty;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _openAccountConfirmation() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountConfirmationScreen()),
    );
  }

  void _openForgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  bool _shouldShowGlobalErrorOnly(AuthRequestException error) {
    final emailError = error.fieldErrors['email']?.trim();
    final message = error.message.trim();

    return emailError != null &&
        emailError.isNotEmpty &&
        emailError == message &&
        message.toLowerCase().contains('не подтвержден');
  }

  bool _validateForm({required String email, required String password}) {
    _errors = AuthFormErrorState.validate(email: email, password: password);
    return !_errors.hasErrors;
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final isValid = _validateForm(email: email, password: password);

    setState(() {
      _statusMessage = null;
    });

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = AppScope.of(context).authRepository;
      await repository.login(LoginParams(email: email, password: password));

      if (!mounted) return;
      _openProfile();
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _errors = _shouldShowGlobalErrorOnly(error)
            ? AuthFormErrorState.empty
            : AuthFormErrorState.fromApi(error.fieldErrors);
        _statusMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Не удалось выполнить вход. Проверьте подключение к серверу.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AppLogoTopLeft(useHero: true),
            Center(
              child: SingleChildScrollView(
                padding: AuthStyles.screenHorizontalPadding,
                child: AuthFormCard(
                  padding: AuthStyles.formPaddingCompact,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: AuthTitleText('Авторизация')),
                      const SizedBox(height: 26),
                      const AuthLabelText('Эл.почта*'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: AppInputDecorations.authField(
                          hintText: 'Введите электронную почту',
                          errorText: _errors.email,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AuthLabelText('Пароль*'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: AppInputDecorations.authField(
                          hintText: 'Введите пароль',
                          errorText: _errors.password,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _openForgotPassword,
                            child: const AuthBodyText('Забыли пароль?'),
                          ),
                          TextButton(
                            onPressed: _openRegister,
                            child: const AuthBodyText('Зарегистрироваться'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_statusMessage != null) ...[
                        Center(
                          child: Text(
                            _statusMessage!,
                            textAlign: TextAlign.center,
                            style: AuthStyles.helperText.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Center(
                        child: AuthActionButton(
                          label: _isSubmitting ? 'Вход...' : 'Войти',
                          onPressed: _isSubmitting ? null : _submitLogin,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: AuthActionButton(
                          label: 'Подтвердить аккаунт',
                          onPressed: _openAccountConfirmation,
                        ),
                      ),
                    ],
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
