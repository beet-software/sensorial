import 'package:sensorial/src/sensors/flutter_sensors.dart';

abstract class Sensor {
  static const Accelerometer accelerometer = Accelerometer._();
  static const Gyroscope gyroscope = Gyroscope._();
  static const List<Sensor> values = [accelerometer, gyroscope];

  final int id;

  const Sensor._({required this.id});
}

class Accelerometer extends Sensor {
  const Accelerometer._() : super._(id: Sensors.ACCELEROMETER);
}

class Gyroscope extends Sensor {
  const Gyroscope._() : super._(id: Sensors.GYROSCOPE);
}
