import 'dart:async';

class AuthSessionService {
  final _sessionExpiredController = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  void notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  void dispose() {
    _sessionExpiredController.close();
  }
}
