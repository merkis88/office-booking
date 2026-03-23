import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/states/app_empty_state_text.dart';

class QrModal {
  QrModal._();

  static const TextStyle _messageStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  static const TextStyle _titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  static const TextStyle _footerStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static Future<void> showQr(
    BuildContext context, {
    required String qrData,
    required String validUntilText,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: const SizedBox.expand(),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 360,
                      padding: const EdgeInsets.fromLTRB(30, 18, 30, 14),
                      decoration: BoxDecoration(
                        color: AppColors.bottomNavBackground,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 290,
                            height: 290,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black87),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 250,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black87,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _buildFooterText(validUntilText),
                            textAlign: TextAlign.center,
                            style: _footerStyle,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -10,
                      right: -10,
                      child: _CloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showNoActiveRentals(BuildContext context) {
    return _show(
      context,
      title: 'Пропуск',
      child: const AppEmptyStateText(
        text: 'У вас нет активных аренд\nили приглашения как сотрудника',
        style: _messageStyle,
      ),
    );
  }

  static String _buildFooterText(String validUntilText) {
    final normalized = validUntilText.trim();
    final matches = RegExp(
      r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z?',
    ).allMatches(normalized).toList();

    if (matches.isNotEmpty) {
      final lastRaw = matches.last.group(0);
      if (lastRaw != null) {
        return 'Ваш qr-код действует до ${_formatDateTime(lastRaw)}';
      }
    }

    final parsedDirectly = _tryFormatStandaloneValue(normalized);
    return 'Ваш qr-код действует до $parsedDirectly';
  }

  static String _tryFormatStandaloneValue(String value) {
    final direct = DateTime.tryParse(value);
    if (direct != null) {
      return _formatDateTime(value);
    }
    return value;
  }

  static String _formatDateTime(String rawValue) {
    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: const SizedBox.expand(),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.modalBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black87),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: _titleStyle,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            splashRadius: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.black87, width: 2),
              ),
            ),
            child: Icon(Icons.close, size: 25, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
