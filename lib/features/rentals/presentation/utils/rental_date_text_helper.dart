class RentalDateTextHelper {
  RentalDateTextHelper._();

  static const _months = <String>[
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  static String formatDayMonth(DateTime? selectedDate) {
    final now = DateTime.now();
    final value = selectedDate ?? DateTime(now.year, now.month, now.day);
    return '${value.day} ${_months[value.month - 1]}';
  }

  static String formatFullDate(DateTime value) {
    return '${value.day} ${_months[value.month - 1]}, ${value.year}';
  }

  static String formatFullDateFromApi(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      final now = DateTime.now();
      return formatFullDate(DateTime(now.year, now.month, now.day));
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) return formatFullDate(parsed);

    final withoutTime = rawDate.split(' ').first.trim();
    final parts = withoutTime.split('.');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return formatFullDate(DateTime(year, month, day));
      }
    }

    return rawDate;
  }
}
