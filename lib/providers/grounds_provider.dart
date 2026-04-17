import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ground_service.dart';

/// Single source of truth for all grounds data.
/// Replaces duplicate StreamSubscriptions in home.dart, categories.dart, search_screen.dart.
class GroundsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _grounds = [];
  bool _loading = true;
  String? _error;
  StreamSubscription? _sub;

  List<Map<String, dynamic>> get grounds => _grounds;
  bool get loading => _loading;
  String? get error => _error;

  /// Grounds filtered by category ('ALL' returns everything)
  List<Map<String, dynamic>> byCategory(String category) {
    if (category == 'ALL') return _grounds;
    return _grounds.where((g) => g['category'] == category).toList();
  }

  /// Single ground by id
  Map<String, dynamic>? byId(String id) {
    try {
      return _grounds.firstWhere((g) => g['id'] == id);
    } catch (_) {
      return null;
    }
  }

  GroundsProvider() {
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _loading = true;
    _error = null;
    _sub = GroundService.getGroundsByCategory('ALL').listen(
      (grounds) {
        _grounds = grounds;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  /// Retry after error
  void retry() => _listen();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
