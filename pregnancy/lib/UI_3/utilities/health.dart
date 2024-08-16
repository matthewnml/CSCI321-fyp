import 'package:health/health.dart';

// Define the types of data you want to access from HealthKit
const types = [HealthDataType.HEART_RATE, HealthDataType.RESTING_HEART_RATE]; // Include Resting Heart Rate
const permissions = [HealthDataAccess.READ,HealthDataAccess.READ];
final now = DateTime.now();
final midnight = DateTime(now.year, now.month, now.day); // Start of the current day

class HealthService {
  final Health health = Health(); // Create an instance of Health

  // Function to fetch the heart rate data from HealthKit
  Future<List<HealthDataPoint>?> getHeartRate() async {
    final bool requested = await health.requestAuthorization(types, permissions: permissions);
    print('Authorization granted: $requested');

    if (requested) {
      try {
        List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(
          startTime: midnight, // Start of the current day
          endTime: now, // Current time
          types: [HealthDataType.HEART_RATE],
        );

        // print('Data points retrieved: ${heartRateData.length}');
        
        // for (var dataPoint in heartRateData) {
        //   print('Data Point: ${dataPoint.dateFrom} - ${dataPoint.value}');
        // }

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

  // Function to fetch the resting heart rate
  Future<num?> getRestingHeartRate() async {
    final bool requested = await health.requestAuthorization(types, permissions: permissions);
    print('Authorization granted: $requested');

    if (requested) {
      try {
        List<HealthDataPoint> restingHeartRateData = await health.getHealthDataFromTypes(
          startTime: midnight, // Start of the current day
          endTime: now, // Current time
          types: [HealthDataType.RESTING_HEART_RATE],
        );

        print('Resting heart rate points retrieved: ${restingHeartRateData.length}');
        
        if (restingHeartRateData.isNotEmpty) {
          final lastPoint = restingHeartRateData.last;
          print('Latest Resting Heart Rate: ${lastPoint.value}');
          return (lastPoint.value as NumericHealthValue).numericValue;
        } else {
          return null; // No data available
        }
      } catch (e) {
        print('Error retrieving resting heart rate data: $e');
        return null; // Return null in case of failure
      }
    } else {
      print('Authorization not granted');
      return null; // Return null in case of failure
    }
  }

  // Function to get the range (min and max) of heart rates
  Future<Map<String, double>?> getHeartRateRange() async {
    final bool requested = await health.requestAuthorization(types, permissions: permissions);
    print('Authorization granted: $requested');

    if (requested) {
      try {
        List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.HEART_RATE],
        );

        if (heartRateData.isNotEmpty) {
          final minRate = heartRateData
              .map((point) => (point.value as NumericHealthValue).numericValue.toDouble())
              .reduce((value, element) => value < element ? value : element);

          final maxRate = heartRateData
              .map((point) => (point.value as NumericHealthValue).numericValue.toDouble())
              .reduce((value, element) => value > element ? value : element);

          return {
            'min': minRate,
            'max': maxRate,
          };
        } else {
          return null; // No data available
        }
      } catch (e) {
        print('Error retrieving heart rate range: $e');
        return null; // Return null in case of failure
      }
    } else {
      print('Authorization not granted');
      return null; // Return null in case of failure
    }
  }
}
