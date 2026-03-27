import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    this.imageSize = 56,
    this.spacing = 10,
    this.fontSize = 22,
    this.scaleDown = true,
  });

  static const String _logoAsset = 'assets/images/logo/app_logo.png';

  final double imageSize;
  final double spacing;
  final double fontSize;
  final bool scaleDown;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _logoAsset,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            'Рабочая точка.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SpectralSC',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );

    if (!scaleDown) {
      return content;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: content,
    );
  }
}
