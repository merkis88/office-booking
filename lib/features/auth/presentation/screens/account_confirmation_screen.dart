import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/domain/entities/resend_verification_params.dart';
import 'package:wordpice/features/auth/domain/entities/verify_email_params.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';
import 'package:wordpice/features/auth/presentation/states/account_confirmation_form_error_state.dart';
import 'package:wordpice/features/auth/presentation/widgets/buttons/auth_action_button.dart';
import 'package:wordpice/features/auth/presentation/widgets/cards/auth_form_card.dart';
import 'package:wordpice/features/auth/presentation/widgets/sections/auth_text.dart';
import 'package:wordpice/features/auth/presentation/widgets/styles/auth_styles.dart';
import 'package:wordpice/features/splash/presentation/widgets/splash_logo.dart';

class AccountConfirmationScreen extends StatefulWidget {
  const AccountConfirmationScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<AccountConfirmationScreen> createState() =>
      _AccountConfirmationScreenState();
}

class _AccountConfirmationScreenState extends State<AccountConfirmationScreen> {
  static const _codeLength = 6;

  final _emailController = TextEditingController();
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isSubmitting = false;
  bool _isResending = false;
  String? _statusMessage;
  AccountConfirmationFormErrorState _errors =
      AccountConfirmationFormErrorState.empty;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _codeValue =>
      _controllers.map((controller) => controller.text).join();

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _goToAuth() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  bool _validateForm({required String email, required String code}) {
    _errors = AccountConfirmationFormErrorState.validate(
      email: email,
      code: code,
    );
    return !_errors.hasErrors;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final code = _codeValue.trim();
    final isValid = _validateForm(email: email, code: code);

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
      await repository.verifyEmail(VerifyEmailParams(email: email, code: code));

      if (!mounted) return;
      _goToAuth();
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _errors = AccountConfirmationFormErrorState.fromApi(error.fieldErrors);
        if (error.fieldErrors.isEmpty) {
          _statusMessage = error.message;
        }
      });
    } catch (_) {
      // Intentionally ignore connection errors in the UI.
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _resendCode() async {
    final email = _emailController.text.trim();
    final emailErrors = AccountConfirmationFormErrorState.validate(
      email: email,
      code: '000000',
    );

    if (emailErrors.email != null) {
      setState(() {
        _errors = AccountConfirmationFormErrorState(
          email: emailErrors.email,
          code: _errors.code,
        );
        _statusMessage = null;
      });
      return;
    }

    setState(() {
      _isResending = true;
      _statusMessage = null;
    });

    try {
      final repository = AppScope.of(context).authRepository;
      final result = await repository.resendVerification(
        ResendVerificationParams(email: email),
      );

      if (!mounted) return;
      setState(() {
        _errors = AccountConfirmationFormErrorState(
          email: null,
          code: _errors.code,
        );
        _statusMessage = result.message;
      });
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _errors = AccountConfirmationFormErrorState.fromApi(error.fieldErrors);
        _statusMessage = error.fieldErrors.isEmpty ? error.message : null;
      });
    } catch (_) {
      // Intentionally ignore connection errors in the UI.
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _onChanged(int index, String value) {
    if (_errors.code != null) {
      setState(() {
        _errors = AccountConfirmationFormErrorState(
          email: _errors.email,
          code: null,
        );
      });
    }

    final sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (sanitizedValue.length > 1) {
      _fillCodeFrom(index, sanitizedValue);
      return;
    }

    if (sanitizedValue.isNotEmpty && _controllers[index].text != sanitizedValue) {
      _controllers[index].text = sanitizedValue;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (_controllers[index].text.isNotEmpty) {
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
      return;
    }

    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _fillCodeFrom(int startIndex, String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return;
    }

    var targetIndex = startIndex;
    for (final symbol in digits.characters) {
      if (targetIndex >= _codeLength) {
        break;
      }
      _controllers[targetIndex].text = symbol;
      _controllers[targetIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      targetIndex += 1;
    }

    for (var i = targetIndex; i < _codeLength; i++) {
      _controllers[i].clear();
    }

    if (targetIndex >= _codeLength) {
      _focusNodes[_codeLength - 1].unfocus();
      return;
    }

    _focusNodes[targetIndex].requestFocus();
  }

  Widget _codeBox(int index) {
    return SizedBox(
      width: 44,
      height: 44,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.formSurface,
          errorStyle: const TextStyle(fontSize: 0, height: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
        onChanged: (value) => _onChanged(index, value),
      ),
    );
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
                            child: AuthTitleText('Подтверждение\nаккаунта'),
                          ),
                          const SizedBox(height: 30),
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
                          const SizedBox(height: 20),
                          const AuthBodyText('Код'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_codeLength, _codeBox),
                          ),
                          if (_errors.code != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errors.code!,
                              style: AuthStyles.helperText.copyWith(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                          if (_statusMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _statusMessage!,
                              style: AuthStyles.helperText.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Center(
                            child: AuthActionButton(
                              label: _isSubmitting
                                  ? 'Подтверждение...'
                                  : 'Подтвердить',
                              onPressed: _isSubmitting ? null : _submit,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: _isResending ? null : _resendCode,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: AuthBodyText(
                                _isResending
                                    ? 'Отправка...'
                                    : 'Повторно отправить код',
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
