//
//  AppDelegate.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseMessaging
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    // 1 Sets AppDelegate as the delegate for UNUserNotificationCenter. You implemented the necessary delegate methods in the previous step.
    UNUserNotificationCenter.current().delegate = self
    // 2 Creates options related to what kind of push notification permissions your app will request. In this case, you’re asking for alerts, badges and sound.
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions) { _, _ in }
    // 3 Registers your app for remote notifications.
    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self

    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
        if error != nil || user == nil {
          // Show the app's signed-out state.
        } else {
          // Show the app's signed-in state.
        }
      }
    
    return true
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error)
  }
  
  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

  func application(
    _ app: UIApplication,
    open url: URL, options: [UIApplication.OpenURLOptionsKey:Any] = [:]
  ) -> Bool {
    var handled: Bool

    handled = GIDSignIn.sharedInstance.handle(url)
    if handled {
      return true
    }

    // Handle other custom URL types.

    // If not handled by this app, return false.
    return false
  }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
  /// будет ли выводиться уведомление, если приложение открыто
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([[.banner, .sound]])
  }
/// обработка уведомления при нажатии на него
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
  
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

}

extension AppDelegate: MessagingDelegate {
  func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String?
  ) {
    let tokenDict = ["token": fcmToken ?? ""]
    UserDefaults.standard.set(fcmToken, forKey: "token")
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: tokenDict)
  }
}
