import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/core/widgets/layout/app_logo_top_left.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/domain/entities/register_params.dart';
import 'package:wordpice/features/auth/presentation/screens/account_confirmation_screen.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';
import 'package:wordpice/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:wordpice/features/auth/presentation/states/register_form_error_state.dart';
import 'package:wordpice/features/auth/presentation/widgets/buttons/auth_action_button.dart';
import 'package:wordpice/features/auth/presentation/widgets/cards/auth_form_card.dart';
import 'package:wordpice/features/auth/presentation/widgets/sections/auth_text.dart';
import 'package:wordpice/features/auth/presentation/widgets/styles/auth_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPersonalDataAccepted = false;
  bool _isSubmitting = false;
  RegisterFormErrorState _errors = RegisterFormErrorState.empty;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _openPolicy() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
  }

  void _goToAccountConfirmation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountConfirmationScreen(
          initialEmail: _emailController.text.trim(),
        ),
      ),
    );
  }

  void _goToAuth() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  bool _validateForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    _errors = RegisterFormErrorState.validate(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      isPersonalDataAccepted: _isPersonalDataAccepted,
    );
    return !_errors.hasErrors;
  }

  Future<void> _submitRegistration() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final patronymic = _middleNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirmation = _confirmPasswordController.text;

    final isValid = _validateForm(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    setState(() {});
    if (!isValid) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = AppScope.of(context).authRepository;
      await repository.register(
        RegisterParams(
          firstName: firstName,
          lastName: lastName,
          patronymic: patronymic,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );

      if (!mounted) return;
      _goToAccountConfirmation();
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _errors = RegisterFormErrorState.fromApi(error.fieldErrors);
      });
      if (error.fieldErrors.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось выполнить регистрацию')),
        );
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
            const AppLogoTopLeft(),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 112, 24, 12),
                child: SingleChildScrollView(
                  child: AuthFormCard(
                    padding: AuthStyles.formPaddingCompact,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: AuthTitleText('Регистрация')),
                        const SizedBox(height: 26),
                        const AuthLabelText('Имя*'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _firstNameController,
                          decoration: AppInputDecorations.authField(
                            hintText: 'Введите имя',
                            errorText: _errors.firstName,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthLabelText('Фамилия*'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _lastNameController,
                          decoration: AppInputDecorations.authField(
                            hintText: 'Введите фамилию',
                            errorText: _errors.lastName,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthLabelText('Отчество (необязательно)'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _middleNameController,
                          decoration: AppInputDecorations.authField(
                            hintText: 'Введите отчество',
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthLabelText('Эл.почта*'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: AppInputDecorations.authField(
                            hintText: 'Введите электронную почту',
                            errorText: _errors.email,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthLabelText('Пароль*'),
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 24),
                        const AuthLabelText('Подтвердите пароль*'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: AppInputDecorations.authField(
                            hintText: 'Введите пароль',
                            errorText: _errors.confirmPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _isPersonalDataAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    _isPersonalDataAccepted = value ?? false;
                                    _errors = _errors.copyWith(
                                      firstName: _errors.firstName,
                                      lastName: _errors.lastName,
                                      email: _errors.email,
                                      password: _errors.password,
                                      confirmPassword: _errors.confirmPassword,
                                      personalData: null,
                                    );
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: AuthPolicyCheckboxText(
                                'Я принимаю условия обработки персональных данных',
                              ),
                            ),
                          ],
                        ),
                        if (_errors.personalData != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              _errors.personalData!,
                              style: AuthStyles.helperText.copyWith(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Center(
                          child: InkWell(
                            onTap: _openPolicy,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: AuthPolicyText(
                                'Нажимая на кнопку "Зарегистрироваться",\nя соглашаюсь с условиями\nПолитики конфиденциальности',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: AuthActionButton(
                            label: _isSubmitting
                                ? 'Регистрация...'
                                : 'Зарегистрироваться',
                            onPressed: _isSubmitting
                                ? null
                                : _submitRegistration,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: _goToAuth,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const AuthBodyText(
                              'Уже есть аккаунт? Авторизация',
                            ),
                          ),
                        ),
                      ],
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
