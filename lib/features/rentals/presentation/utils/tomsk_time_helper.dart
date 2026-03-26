class TomskTimeHelper {
  TomskTimeHelper._();

  static const Duration _tomskOffset = Duration(hours: 7);

  static DateTime now() => DateTime.now().toUtc().add(_tomskOffset);
}
