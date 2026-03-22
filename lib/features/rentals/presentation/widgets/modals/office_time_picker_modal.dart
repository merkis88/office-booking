import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class OfficeTimePickerModal extends StatefulWidget {
  const OfficeTimePickerModal({
    super.key,
    required this.availableTime,
    this.submitLabel = 'Забронировать',
  });

  final String availableTime;
  final String submitLabel;

  static Future<String?> show(
    BuildContext context, {
    required String availableTime,
    String submitLabel = 'Забронировать',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => OfficeTimePickerModal(
        availableTime: availableTime,
        submitLabel: submitLabel,
      ),
    );
  }

  @override
  State<OfficeTimePickerModal> createState() => _OfficeTimePickerModalState();
}

class _OfficeTimePickerModalState extends State<OfficeTimePickerModal> {
  late final List<int> _hours;
  int? _fromHour;
  int? _toHour;

  @override
  void initState() {
    super.initState();
    _hours = _parseHours(widget.availableTime);
  }

  List<int> _parseHours(String text) {
    final parts = text.split('-').map((e) => e.trim()).toList();
    if (parts.length != 2) {
      return List<int>.generate(14, (i) => 9 + i);
    }

    int parseHour(String value) {
      final hh = value.split(':').first.trim();
      return int.tryParse(hh) ?? 9;
    }

    final start = parseHour(parts[0]);
    final end = parseHour(parts[1]);
    if (end < start) {
      return List<int>.generate(14, (i) => 9 + i);
    }
    return List<int>.generate(end - start + 1, (i) => start + i);
  }

  String _formatHour(int hour) => '${hour.toString().padLeft(2, '0')}:00';

  void _onHourTap(int hour) {
    setState(() {
      if (_fromHour == null || _toHour != null) {
        _fromHour = hour;
        _toHour = null;
        return;
      }
      if (hour < _fromHour!) {
        _toHour = _fromHour;
        _fromHour = hour;
      } else {
        _toHour = hour;
      }
    });
  }

  bool _isSelected(int hour) {
    if (_fromHour == null) {
      return false;
    }
    if (_toHour == null) {
      return hour == _fromHour;
    }
    return hour >= _fromHour! && hour <= _toHour!;
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _fromHour != null && _toHour != null;

    return Dialog(
      backgroundColor: AppColors.modalBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _hours.map((hour) {
                final selected = _isSelected(hour);
                return InkWell(
                  onTap: () => _onHourTap(hour),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 44,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0x407C8FA0)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatHour(hour),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 190,
              height: 34,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.formSurface,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: canSubmit
                    ? () => Navigator.of(context).pop(
                        '${_formatHour(_fromHour!)} - ${_formatHour(_toHour!)}',
                      )
                    : null,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.submitLabel,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
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
