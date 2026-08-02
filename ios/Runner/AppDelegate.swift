import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let mapsAPIKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String,
          !mapsAPIKey.isEmpty else {
      fatalError("Google Maps API key is missing. Set apikey in the project .env file.")
    }
    GMSServices.provideAPIKey(mapsAPIKey)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
