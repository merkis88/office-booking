import 'package:flutter/material.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/passes/presentation/widgets/forms/pass_form_widgets.dart';
import 'package:wordpice/features/passes/presentation/widgets/modals/pass_confirmation_modal.dart';
import 'package:wordpice/features/passes/presentation/widgets/styles/pass_form_styles.dart';

class EmployeePassScreen extends StatefulWidget {
  const EmployeePassScreen({super.key});

  @override
  State<EmployeePassScreen> createState() => _EmployeePassScreenState();
}

class _EmployeePassScreenState extends State<EmployeePassScreen> {
  static const int _tabIndex = 2;

  final int _selectedBottomIndex = _tabIndex;
  final TextEditingController _emailController = TextEditingController();

  void _onAnyFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onAnyFieldChanged);
  }

  void _onBottomChanged(int index) {
    AppTabNavigator.goToTab(context, index);
  }

  Future<void> _showPurchaseModal() {
    return PassConfirmationModal.show(
      context,
      email: _emailController.text.trim(),
    );
  }

  bool get _canBuyPass => _emailController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailController.removeListener(_onAnyFieldChanged);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 46, 20, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _EmployeePassHeader(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: AppColors.formBlockBackground,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _EmployeePassField(
                        label: 'Эл.почта*',
                        hint: 'Введите электронную почту',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 30),
                    PassSubmitButton(
                      text: 'Купить пропуск',
                      onPressed: _canBuyPass ? _showPurchaseModal : null,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: SizedBox(
                        width: 340,
                        child: Image.asset(
                          'assets/images/passes/employerPasses.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmployeePassHeader extends StatelessWidget {
  const _EmployeePassHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          'Пропуск сотрудника',
          style: PassFormStyles.title,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class _EmployeePassField extends StatelessWidget {
  const _EmployeePassField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(width: double.infinity, child: PassFieldLabel(label)),
        const SizedBox(height: 10),
        PassEditableInputField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
