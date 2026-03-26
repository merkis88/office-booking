import 'package:wordpice/core/config/app_api_config.dart';

class ProfilePhotoResponseModel {
  const ProfilePhotoResponseModel({required this.photoUrl});

  final String? photoUrl;

  factory ProfilePhotoResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return ProfilePhotoResponseModel(
      photoUrl: _buildFileUrl(
        (data['photo_url'] as String?) ?? (data['photo'] as String?),
      ),
    );
  }

  static String? _buildFileUrl(String? rawPath) {
    final trimmed = rawPath?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      final baseOriginUri = Uri.parse(AppApiConfig.baseOrigin);
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return uri.replace(
          scheme: baseOriginUri.scheme,
          host: baseOriginUri.host,
          port: baseOriginUri.hasPort ? baseOriginUri.port : null,
        ).toString();
      }
      return trimmed;
    }

    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/storage/$trimmed';
    return '${AppApiConfig.baseOrigin}$normalizedPath';
  }
}
