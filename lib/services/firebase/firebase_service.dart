import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/firebase_options.dart';

/// Controls Firebase bootstrapping for supported platforms only.
final bool isFirebaseSupported = platformInfo.isMobile;

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static bool _initialized = false;
  static bool _messagingAvailable = false;

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  static bool get isMessagingAvailable => _messagingAvailable;

  static bool _isServiceUnavailableError(Object error) {
    final message = error.toString().toUpperCase();
    return message.contains('SERVICE_NOT_AVAILABLE') || message.contains('MISSING_INSTANCEID_SERVICE');
  }

  static Future<void> initialize() async {
    if (!isFirebaseSupported || _initialized) return;

    _initialized = true;

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (error, stackTrace) {
      if (_isServiceUnavailableError(error)) {
        log('Firebase services are unavailable on this device. Push notifications are disabled.');
        return;
      }
      log(
        'Firebase initialization failed. Push notifications are disabled.',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      _messagingAvailable = true;
    } catch (error, stackTrace) {
      if (_isServiceUnavailableError(error)) {
        log('FCM is unavailable on this device. Push notifications are disabled.');
        _messagingAvailable = false;
        return;
      }
      log(
        'FCM auto-init is unavailable on this device. Push notifications are disabled.',
        error: error,
        stackTrace: stackTrace,
      );
      _messagingAvailable = false;
    }
  }
}
