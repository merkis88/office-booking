class RentalTimeSlotsHelper {
  RentalTimeSlotsHelper._();

  static List<String> mergeContinuousRanges(List<String> ranges) {
    final parsedRanges = ranges
        .map(parseRange)
        .whereType<(int, int)>()
        .toList()
      ..sort((a, b) => a.$1.compareTo(b.$1));

    if (parsedRanges.isEmpty) return const <String>[];

    final merged = <(int, int)>[];
    var current = parsedRanges.first;

    for (var i = 1; i < parsedRanges.length; i++) {
      final next = parsedRanges[i];

      if (next.$1 <= current.$2) {
        current = (current.$1, next.$2 > current.$2 ? next.$2 : current.$2);
        continue;
      }

      merged.add(current);
      current = next;
    }

    merged.add(current);

    return merged.map((range) => formatRange(range.$1, range.$2)).toList();
  }

  static List<String> subtractBookedRange({
    required String sourceRange,
    required String bookedRange,
  }) {
    final source = parseRange(sourceRange);
    final booked = parseRange(bookedRange);
    if (source == null || booked == null) return [sourceRange];

    final sourceStart = source.$1;
    final sourceEnd = source.$2;
    final bookedStart = booked.$1;
    final bookedEnd = booked.$2;

    if (bookedStart <= sourceStart && bookedEnd >= sourceEnd) {
      return const [];
    }

    final result = <String>[];
    if (bookedStart > sourceStart) {
      result.add(formatRange(sourceStart, bookedStart));
    }
    if (bookedEnd < sourceEnd) {
      result.add(formatRange(bookedEnd, sourceEnd));
    }
    return result;
  }

  static (int, int)? parseRange(String text) {
    final parts = text.split('-').map((e) => e.trim()).toList();
    if (parts.length != 2) return null;

    int? parseHour(String value) {
      final hh = value.split(':').first.trim();
      return int.tryParse(hh);
    }

    final start = parseHour(parts[0]);
    final end = parseHour(parts[1]);
    if (start == null || end == null || end <= start) return null;
    return (start, end);
  }

  static String formatRange(int startHour, int endHour) {
    String h(int hour) => '${hour.toString().padLeft(2, '0')}:00';
    return '${h(startHour)} - ${h(endHour)}';
  }

  static int rangeStartHour(String text) => parseRange(text)?.$1 ?? 999;
}
