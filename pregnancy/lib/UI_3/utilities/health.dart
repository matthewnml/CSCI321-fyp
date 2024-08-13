import 'package:health/health.dart';

// Define the types of data you want to access from HealthKit
const types = [HealthDataType.HEART_RATE]; // Request heart rate
const permissions = [HealthDataAccess.READ];
final now = DateTime.now();
final midnight = DateTime(now.year, now.month, now.day); // Start of the current day

class HealthService {
  final Health health = Health(); // Create an instance of Health

  // Function to fetch the heart rate data from HealthKit
  Future<List<HealthDataPoint>?> getHeartRate() async {
    // Request Authorization
    final bool requested = await health.requestAuthorization(types, permissions: permissions);
    print('Authorization granted: $requested');

    if (requested) {
      try {
        // Fetch heart rate data within the specified time interval
        List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(
          startTime: midnight, // Start of the current day
          endTime: now, // Current time
          types: types,
        );

        print('Data points retrieved: ${heartRateData.length}');
        
        for (var dataPoint in heartRateData) {
          print('Data Point: ${dataPoint.dateFrom} - ${dataPoint.value}');
        }

        return heartRateData;
      } catch (e) {
        print('Error retrieving data: $e');
        return Future.error(-1); // Return -1 in case of failure
      }
    } else {
      print('Authorization not granted');
      return Future.error(-1); // Return -1 in case of failure
    }
  }
}
