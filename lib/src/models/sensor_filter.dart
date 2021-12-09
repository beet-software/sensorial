import 'package:sensorial/src/models/sensor.dart';

abstract class SensorFilter<S extends Sensor> {
  static const _AccelerometerFilter accelerometer = _AccelerometerFilter();
  static const _GyroscopeFilter gyroscope = _GyroscopeFilter();

  final Sensor sensor;

  const SensorFilter({required this.sensor});
}

class _AccelerometerFilter extends SensorFilter<Accelerometer> {
  const _AccelerometerFilter() : super(sensor: Sensor.accelerometer);
}

class _GyroscopeFilter extends SensorFilter<Gyroscope> {
  const _GyroscopeFilter() : super(sensor: Sensor.gyroscope);
}
