import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
        name: "gps_service",
        binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
        if call.method == "startGpsService" {
            LocationService.shared.startTracking()
            result(nil)
        } else if call.method == "stopGpsService" {
            LocationService.shared.stopTracking()
            result(nil)
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
