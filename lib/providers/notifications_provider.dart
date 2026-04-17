import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

/// Global unread notification count — accessible from anywhere without
/// re-subscribing per screen. Replaces the StreamSubscription in user_main.dart.
class NotificationsProvider extends ChangeNotifier {
  final String uid;

  int _unreadCount = 0;
  StreamSubscription? _sub;

  int get unreadCount => _unreadCount;

  NotificationsProvider({required this.uid}) {
    _sub = NotificationService.getUserUnreadCount(uid).listen(
      (count) {
        if (_unreadCount != count) {
          _unreadCount = count;
          notifyListeners();
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
