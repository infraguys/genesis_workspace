import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/firebase_options.dart';
import 'package:genesis_workspace/flavor.dart';
import 'package:genesis_workspace/main.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    name: "workspace",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  inspect(message);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  runZonedGuarded(
    () {
      Flavor.current = Flavor.prod;
      WidgetsFlutterBinding.ensureInitialized();
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      return Main.startApp();
    },
    (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);
    },
  );
}
