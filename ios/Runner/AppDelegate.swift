import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("APNS registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}

//import UIKit
//import Flutter
//import FirebaseCore
//import FirebaseMessaging
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//let methodChannelName = "genesis.workspace"
//override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//) -> Bool {
//     FirebaseApp.configure()
//     UNUserNotificationCenter.current().delegate = self
//     application.registerForRemoteNotifications()
//
//if #available(iOS 10.0, *) {
//    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//}
//
//   // Setup method channel
//  if let controller = window?.rootViewController as? FlutterViewController {
//    let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)
//
//    // Method channel handler (if needed for other purposes)
//    methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) in
//      // Handle method channel calls here if needed
//    }
//  }
//GeneratedPluginRegistrant.register(with: self)
//return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
// func application(application: UIApplication,
//               didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//  Messaging.messaging().apnsToken = deviceToken
// }
// override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//  // Handle the notification data here and pass it to Dart
//  if let controller = window?.rootViewController as? FlutterViewController {
//    let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)
//
//    // Passing the userInfo to Dart
//    methodChannel.invokeMethod("handleMessageBackground", arguments: userInfo) { _ in
//      completionHandler(UIBackgroundFetchResult.newData)
//    }
//  } else {
//    completionHandler(UIBackgroundFetchResult.noData)
//  }
// }
//}


//import FirebaseMessaging
//import Flutter
//import UIKit
//import flutter_local_notifications
//
//@main
//@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    application.registerForRemoteNotifications()
//    return didFinish
//  }
//
//  override func application(
//    _ application: UIApplication,
//    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//  ) {
//    Messaging.messaging().apnsToken = deviceToken
//    let apnsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//    NSLog("APNS token registered: \(apnsToken)")
//      if #available(iOS 10.0, *) {
//          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//      }
//    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//  }
//
//  override func application(
//    _ application: UIApplication,
//    didFailToRegisterForRemoteNotificationsWithError error: Error
//  ) {
//    NSLog("APNS registration failed: \(error.localizedDescription)")
//    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
//  }
//
//    
//  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
//      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//            GeneratedPluginRegistrant.register(with: registry)
//        }
//    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
//  }
//}
