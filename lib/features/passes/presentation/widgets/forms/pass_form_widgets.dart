import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/passes/presentation/widgets/styles/pass_form_styles.dart';

class PassFieldLabel extends StatelessWidget {
  const PassFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: PassFormStyles.fieldLabel);
  }
}

class PassInputField extends StatelessWidget {
  const PassInputField({
    super.key,
    required this.hint,
    this.trailing,
    this.hasTrailingBox = false,
    this.onTap,
    this.borderRadius,
  });

  final String hint;
  final Widget? trailing;
  final bool hasTrailingBox;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: PassFormStyles.fieldRadius,
      child: Container(
        height: PassFormStyles.fieldHeight,
        padding: PassFormStyles.fieldPadding,
        decoration: PassFormStyles.outlinedBox(
          borderRadius ?? PassFormStyles.fieldRadius,
        ),
        child: Row(
          children: [
            Expanded(child: Text(hint, style: PassFormStyles.fieldText)),
            if (trailing != null)
              hasTrailingBox
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: PassFormStyles.outlinedBox(
                        PassFormStyles.trailingRadius,
                      ),
                      child: Center(child: trailing),
                    )
                  : trailing!,
          ],
        ),
      ),
    );
  }
}

class PassEditableInputField extends StatelessWidget {
  const PassEditableInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PassFormStyles.fieldHeight,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: PassFormStyles.editableFieldDecoration.copyWith(
          hintText: hint,
        ),
      ),
    );
  }
}

class PassFieldErrorText extends StatelessWidget {
  const PassFieldErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: PassFormStyles.helperText.copyWith(
          color: Colors.red.shade700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class PassFieldSuccessText extends StatelessWidget {
  const PassFieldSuccessText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: PassFormStyles.helperText.copyWith(
          color: Colors.green.shade700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class PassSubmitButton extends StatelessWidget {
  const PassSubmitButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PassFormStyles.buttonWidth,
      height: PassFormStyles.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.formSurface,
          shape: const RoundedRectangleBorder(
            borderRadius: PassFormStyles.fieldRadius,
          ),
        ),
        child: Text(text, style: PassFormStyles.buttonText),
      ),
    );
  }
}

class PassQrPreview extends StatelessWidget {
  const PassQrPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PassFormStyles.qrPreviewSize,
      height: PassFormStyles.qrPreviewSize,
      decoration: PassFormStyles.outlinedBox(PassFormStyles.fieldRadius),
      child: const Icon(Icons.qr_code_2, size: 120),
    );
  }
}
