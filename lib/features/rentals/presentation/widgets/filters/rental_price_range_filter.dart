import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class RentalPriceRangeFilter extends StatefulWidget {
  const RentalPriceRangeFilter({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
    required this.formatLabel,
  });

  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues> onChangeEnd;
  final String Function(double value) formatLabel;

  @override
  State<RentalPriceRangeFilter> createState() => _RentalPriceRangeFilterState();
}

class _RentalPriceRangeFilterState extends State<RentalPriceRangeFilter> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final FocusNode _startFocusNode;
  late final FocusNode _endFocusNode;

  double get _step => 1000;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController();
    _endController = TextEditingController();
    _startFocusNode = FocusNode();
    _endFocusNode = FocusNode();

    _startFocusNode.addListener(() {
      if (!_startFocusNode.hasFocus) _applyTypedValue(isStart: true);
    });
    _endFocusNode.addListener(() {
      if (!_endFocusNode.hasFocus) _applyTypedValue(isStart: false);
    });

    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant RentalPriceRangeFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_startFocusNode.hasFocus) {
      _startController.text = _displayText(widget.values.start);
    }
    if (!_endFocusNode.hasFocus) {
      _endController.text = _displayText(widget.values.end);
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _startFocusNode.dispose();
    _endFocusNode.dispose();
    super.dispose();
  }

  void _syncControllers() {
    _startController.text = _displayText(widget.values.start);
    _endController.text = _displayText(widget.values.end);
  }

  String _displayText(double value) => widget.formatLabel(value);

  void _applyTypedValue({required bool isStart}) {
    final controller = isStart ? _startController : _endController;
    final raw = controller.text.replaceAll(RegExp(r'\s+'), '');
    final parsed = int.tryParse(raw);

    if (parsed == null) {
      controller.text = _displayText(
        isStart ? widget.values.start : widget.values.end,
      );
      return;
    }

    double next = parsed.toDouble().clamp(widget.min, widget.max);
    final step = _step;
    if (step > 0) {
      next = ((next - widget.min) / step).round() * step + widget.min;
      next = next.clamp(widget.min, widget.max);
    }

    if (isStart) {
      final end = widget.values.end;
      final start = next <= end ? next : end;
      final values = RangeValues(start, end);
      widget.onChanged(values);
      widget.onChangeEnd(values);
      _startController.text = _displayText(start);
    } else {
      final start = widget.values.start;
      final end = next >= start ? next : start;
      final values = RangeValues(start, end);
      widget.onChanged(values);
      widget.onChangeEnd(values);
      _endController.text = _displayText(end);
    }
  }

  void _handleSliderChanged(RangeValues values) {
    widget.onChanged(_snapValues(values));
  }

  void _handleSliderChangeEnd(RangeValues values) {
    final snapped = _snapValues(values);
    widget.onChanged(snapped);
    widget.onChangeEnd(snapped);
  }

  RangeValues _snapValues(RangeValues values) {
    final step = _step;

    double snap(double value) {
      if (step <= 0) return value;
      final snapped = ((value - widget.min) / step).round() * step + widget.min;
      return snapped.clamp(widget.min, widget.max);
    }

    final start = snap(values.start);
    final end = snap(values.end);
    return RangeValues(
      start <= end ? start : end,
      end >= start ? end : start,
    );
  }

  Widget _valueField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSubmitted,
  }) {
    return SizedBox(
      width: 80,
      height: 35,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1,
        ),
        cursorColor: Colors.black87,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.formSurface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black87, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black87, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        onSubmitted: (_) => onSubmitted(),
        onTapOutside: (_) {
          focusNode.unfocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = widget.max > widget.min;

    return Row(
      children: [
        _valueField(
          controller: _startController,
          focusNode: _startFocusNode,
          onSubmitted: () => _applyTypedValue(isStart: true),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: hasRange
              ? SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: const Color(0xFF7C8FA0),
                    inactiveTrackColor: const Color(0xFFD5DDE4),
                    thumbColor: const Color(0xFF7E94A8),
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 9,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: RangeSlider(
                    values: widget.values,
                    min: widget.min,
                    max: widget.max,
                    onChanged: _handleSliderChanged,
                    onChangeEnd: _handleSliderChangeEnd,
                  ),
                )
              : Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DDE4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        _valueField(
          controller: _endController,
          focusNode: _endFocusNode,
          onSubmitted: () => _applyTypedValue(isStart: false),
        ),
      ],
    );
  }
}
