part of 'flutter_sensors.dart';

typedef SensorCallback = Function(int sensor, List<double> data, int accuracy);

class _SensorChannel {
  /// Method channel of the plugin.
  static const MethodChannel _methodChannel = MethodChannel('flutter_sensors');

  /// List of subscriptions to the update event channel.
  final Map<int, EventChannel> _eventChannels = {};

  /// List of subscriptions to the update event channel.
  final Map<int, Stream<SensorEvent>> _sensorStreams = {};

  /// Register a sensor update request.
  Future<Stream<SensorEvent>> sensorUpdates({
    required int sensorId,
    Duration interval = Durations.SENSOR_DELAY_NORMAL,
  }) async {
    final Stream<SensorEvent> stream;

    Stream<SensorEvent>? sensorStream = _getSensorStream(sensorId);
    if (sensorStream == null) {
      final args = {"interval": _transformDurationToNumber(interval)};
      final eventChannel = await _getEventChannel(sensorId, arguments: args);

      stream = eventChannel.receiveBroadcastStream().map((event) {
        return SensorEvent.fromMap((event as Map).cast<String, dynamic>());
      });

      _sensorStreams.putIfAbsent(sensorId, () => stream);
    } else {
      await updateSensorInterval(sensorId: sensorId, interval: interval);
      stream = sensorStream;
    }
    return stream;
  }

  /// Check if the sensor is available in the device.
  Future<bool> isSensorAvailable(int sensorId) async {
    final bool isAvailable = await _methodChannel.invokeMethod(
      'is_sensor_available',
      {"sensorId": sensorId},
    );
    return isAvailable;
  }

  /// Updates the interval between updates for an specific sensor.
  Future<void> updateSensorInterval({
    required int sensorId,
    required Duration interval,
  }) async {
    return _methodChannel.invokeMethod(
      'update_sensor_interval',
      {"sensorId": sensorId, "interval": _transformDurationToNumber(interval)},
    );
  }

  /// Return the stream associated with the given sensor.
  Stream<SensorEvent>? _getSensorStream(int sensorId) =>
      _sensorStreams[sensorId];

  /// Return the stream associated with the given sensor.
  Future<EventChannel> _getEventChannel(int sensorId, {Map? arguments}) async {
    final EventChannel channel;

    EventChannel? eventChannel = _eventChannels[sensorId];
    if (eventChannel == null) {
      arguments?["sensorId"] = sensorId;
      await _methodChannel.invokeMethod("start_event_channel", arguments);
      channel = EventChannel("flutter_sensors/$sensorId");
      _eventChannels.putIfAbsent(sensorId, () => channel);
    } else {
      channel = eventChannel;
    }
    return channel;
  }

  /// Transform the delay duration object to an int value for each platform.
  num _transformDurationToNumber(Duration delay) =>
      Platform.isAndroid ? delay.inMicroseconds : delay.inSeconds;
}
