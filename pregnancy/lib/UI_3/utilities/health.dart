import 'package:health/health.dart';

// Define the types of data you want to access from HealthKit
const types = [HealthDataType.HEART_RATE]; //Request heart rate
const permissions = [HealthDataAccess.READ];
final now = DateTime.now();
final yesterday = now.subtract(const Duration(days: 1));

class HealthService {
  final Health health = Health(); // Create an instance of HealthFactory

  // Function to fetch the heart rate data from HealthKit
  Future<List<HealthDataPoint>?> getHeartRate() async {
    // Request Authorization
    final bool requested = await health.requestAuthorization(types, permissions: permissions);
    
    if (requested) {
      // Fetch heart rate data within the specified time interval
      List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(startTime: yesterday, endTime: now, types: types);

      // Remove duplicates and keep unique data points (if necessary)
      // heartRateData = Health.removeDuplicates(heartRateData);
      return heartRateData;
    }
    return Future.error(-1); // Return -1 in case of failure
  }
}
