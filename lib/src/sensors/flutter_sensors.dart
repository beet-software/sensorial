import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

part 'sensor_channel.dart';

part 'sensor_event.dart';

part 'sensors.dart';

class SensorManager {
  /// Singleton for the sensor manager.
  static final SensorManager _singleton = SensorManager._internal();

  /// Returns the singleton instance. Builds the instance first if is null.
  factory SensorManager() => _singleton;

  /// Internal constructor of the class.
  SensorManager._internal();

  /// Sensor channel to call the platform methods.
  final _SensorChannel _sensorChannel = _SensorChannel();

  /// Opens a stream to receive sensor updates from the desired sensor
  /// defined in the [request].
  Stream<SensorEvent> sensorUpdates({
    required int sensorId,
    required Duration interval,
  }) async* {
    yield* await _sensorChannel.sensorUpdates(
        sensorId: sensorId, interval: interval);
  }

  /// Checks if the [sensorId] is available in the system or supported by the
  /// plugin.
  Future<bool> isSensorAvailable(int sensorId) =>
      _sensorChannel.isSensorAvailable(sensorId);

  /// Updates the interval between updates for an specific sensor.
  Future<void> updateSensorInterval({
    required int sensorId,
    required Duration interval,
  }) =>
      _sensorChannel.updateSensorInterval(
          sensorId: sensorId, interval: interval);
}
