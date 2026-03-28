import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoriteHeartToggle extends StatefulWidget {
  const FavoriteHeartToggle({
    super.key,
    this.initialFilled = false,
    this.filled,
    this.size = 27,
    this.filledColor = const Color(0xFFF06292),
    this.outlinedColor = const Color(0xFF7C8FA0),
    this.onTap,
    this.isBusy = false,
  });

  final bool initialFilled;
  final bool? filled;
  final double size;
  final Color filledColor;
  final Color outlinedColor;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  State<FavoriteHeartToggle> createState() => _FavoriteHeartToggleState();
}

class _FavoriteHeartToggleState extends State<FavoriteHeartToggle> {
  late bool _isFilled;

  @override
  void initState() {
    super.initState();
    _isFilled = widget.initialFilled;
  }

  @override
  void didUpdateWidget(covariant FavoriteHeartToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled != null && widget.filled != oldWidget.filled) {
      _isFilled = widget.filled!;
    }
  }

  void _handleTap() {
    if (widget.isBusy) return;

    final onTap = widget.onTap;
    if (onTap != null) {
      onTap();
      return;
    }

    setState(() => _isFilled = !_isFilled);
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = widget.filled ?? _isFilled;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.isBusy
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isFilled ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: widget.size,
                color: isFilled ? widget.filledColor : widget.outlinedColor,
              ),
      ),
    );
  }
}
