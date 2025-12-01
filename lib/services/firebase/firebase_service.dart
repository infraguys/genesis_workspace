import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/firebase_options.dart';

/// Controls Firebase bootstrapping for supported platforms only.
final bool isFirebaseSupported =
    kIsWeb || Platform.isAndroid || Platform.isIOS;

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static bool _initialized = false;

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  Future<void> initialize() async {
    if (!isFirebaseSupported || _initialized) return;

    await Firebase.initializeApp(
      name: 'genesis_workspace',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    _initialized = true;
  }
}
