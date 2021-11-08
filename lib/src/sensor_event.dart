part of flutter_sensors;

/// Class that represents an sensor update event.
class SensorEvent {
  /// ID of the sensor that generated this event.
  final int sensorId;

  /// Time in milliseconds at which the event happened.
  final int timestamp;

  /// List of data.
  final List<double> data;

  /// Accuracy of this event.
  final int accuracy;

  /// Constructor.
  const SensorEvent({
    required this.sensorId,
    required this.data,
    required this.accuracy,
    required this.timestamp,
  });

  /// Construct an object from a map.
  SensorEvent.fromMap(Map<String, dynamic> map)
      : sensorId = map["sensorId"],
        accuracy = map["accuracy"],
        timestamp = map["timestamp"],
        data = (map["data"] as List).cast<double>();
}
