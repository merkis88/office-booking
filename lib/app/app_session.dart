import 'package:wordpice/features/auth/domain/entities/registered_user.dart';

class AppSession {
  String? _token;
  RegisteredUser? _currentUser;

  String? get token => _token;
  RegisteredUser? get currentUser => _currentUser;
  bool get isAuthenticated =>
      _token != null && _token!.isNotEmpty && _currentUser != null;

  void setAuthenticated({required String token, required RegisteredUser user}) {
    _token = token;
    _currentUser = user;
  }

  void updateUser(RegisteredUser user) {
    _currentUser = user;
  }

  void clear() {
    _token = null;
    _currentUser = null;
  }
}
