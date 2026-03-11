import 'package:flutter/foundation.dart';

class AppApiConfig {
  AppApiConfig._();

  static const Duration requestTimeout = Duration(seconds: 15);

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost/api';
      case TargetPlatform.fuchsia:
        return 'http://localhost/api';
    }
  }
}
