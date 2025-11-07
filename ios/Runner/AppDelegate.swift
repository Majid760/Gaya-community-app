import UIKit
import Flutter
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?

  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func applicationDidEnterBackground(_ application: UIApplication){
           application.applicationIconBadgeNumber = 0
        }
    
}



 

 /// Notification For BigQuery
//class NotificationService: UNNotificationServiceExtension {
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        if let userInfo = request.content.userInfo as? [AnyHashable: Any] {
//            Messaging.serviceExtension().exportDeliveryMetricsToBigQuery(withMessageInfo: userInfo)
//        }
//        contentHandler(request.content)
//    }
//}
