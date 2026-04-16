import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  /// main() mein ek baar call karo
  static Future<void> init() async {
    // Release mode mein Crashlytics enable, debug mein disable
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Flutter framework errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Dart async errors (PlatformDispatcher)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Manual error log karo (non-fatal)
  static void log(dynamic error, StackTrace stack, {String? reason}) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: false,
    );
  }

  /// User identity set karo (login ke baad call karo)
  static Future<void> setUser(String uid) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(uid);
  }

  /// Logout pe user clear karo
  static Future<void> clearUser() async {
    await FirebaseCrashlytics.instance.setUserIdentifier('');
  }
}
