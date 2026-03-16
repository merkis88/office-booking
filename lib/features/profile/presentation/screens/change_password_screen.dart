import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/widgets/buttons/app_outlined_icon_button.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/presentation/states/change_password_form_error_state.dart';
import 'package:wordpice/features/profile/presentation/widgets/sections/change_password_section.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/change_password_styles.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const int _tabIndex = 3;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  ChangePasswordFormErrorState _errors = ChangePasswordFormErrorState.empty;
  String? _successMessage;
  bool _isSubmitting = false;
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _onBottomChanged(int index) {
    if (index == _tabIndex) {
      Navigator.of(context).pop();
      return;
    }
    AppTabNavigator.goToTab(context, index);
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    final errors = ChangePasswordFormErrorState.validate(
      currentPassword: _currentPasswordController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    setState(() {
      _errors = errors;
      _successMessage = null;
    });

    if (errors.hasErrors) return;

    setState(() => _isSubmitting = true);

    try {
      final message = await AppScope.of(context).profileRepository.changePassword(
        ChangePasswordParams(
          currentPassword: _currentPasswordController.text.trim(),
          password: _passwordController.text.trim(),
          passwordConfirmation: _confirmPasswordController.text.trim(),
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPasswordController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _errors = ChangePasswordFormErrorState.empty;
        _successMessage = _localizePasswordMessage(message);
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      final message = _localizePasswordMessage(error.message);
      final lowerMessage = message.toLowerCase();
      final isCurrentPasswordError = lowerMessage.contains('текущий пароль');
      final isConfirmPasswordError = lowerMessage.contains('подтверж');
      final isPasswordMismatchError = lowerMessage.contains('не совпадают');

      setState(() {
        _errors = ChangePasswordFormErrorState(
          currentPassword: isCurrentPasswordError ? message : null,
          password:
              !isCurrentPasswordError &&
                  !isConfirmPasswordError &&
                  !isPasswordMismatchError
              ? message
              : null,
          confirmPassword:
              isConfirmPasswordError || isPasswordMismatchError ? message : null,
        );
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _localizePasswordMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('must be at least') && lower.contains('characters')) {
      final match = RegExp(r'(\d+)').firstMatch(message);
      final minLength = match?.group(1) ?? '8';
      return 'Пароль должен быть минимум из $minLength символов';
    }

    if (lower.contains('current password')) {
      return 'Текущий пароль неверен!';
    }

    if (lower.contains('passwords do not match') ||
        lower.contains('password confirmation')) {
      return 'Пароли не совпадают!';
    }

    return message;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _tabIndex,
      onBottomChanged: _onBottomChanged,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: ChangePasswordStyles.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppOutlinedIconButton(
              icon: Icons.arrow_back_ios_new,
              iconSize: 14,
              size: 30,
              radius: 10,
              onPressed: _goBack,
            ),
            const SizedBox(height: 54),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ChangePasswordStyles.maxContentWidth,
                ),
                child: ChangePasswordSection(
                  currentPasswordController: _currentPasswordController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  currentPasswordError: _errors.currentPassword,
                  passwordError: _errors.password,
                  confirmPasswordError: _errors.confirmPassword,
                  successMessage: _successMessage,
                  isSubmitting: _isSubmitting,
                  obscureCurrentPassword: _obscureCurrentPassword,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  onToggleCurrentPasswordVisibility: () {
                    setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword,
                    );
                  },
                  onTogglePasswordVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onToggleConfirmPasswordVisibility: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  onSubmit: _submit,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
