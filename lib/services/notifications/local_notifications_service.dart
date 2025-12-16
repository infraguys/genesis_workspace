import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  LocalNotificationsService(this._flutterLocalNotificationsPlugin);

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final WindowsInitializationSettings initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Workspace',
      appUserModelId: 'Com.Genesis.Workspace',
      // Search online for GUID generators to make your own
      guid: '4c1dc691-5ece-47c8-ba3a-0b3a7684b1cc',
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (_) {},
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showNotification({required int messageId, required String title, required String body}) async {
    NotificationDetails notificationDetails = NotificationDetails(
      linux: LinuxNotificationDetails(
        timeout: LinuxNotificationTimeout.fromDuration(Duration(seconds: 5)),
        category: LinuxNotificationCategory.email,
      ),
      macOS: DarwinNotificationDetails(),
    );
    await _flutterLocalNotificationsPlugin.show(messageId, title, body, notificationDetails);
  }
}
