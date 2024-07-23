import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let readTypes: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
            ]
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
                if !success {
                    print("Error requesting HealthKit authorization: \(String(describing: error))")
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
