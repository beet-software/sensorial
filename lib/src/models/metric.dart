import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/models/sensor.dart';

abstract class Metric<S extends Sensor> {
  static const Acceleration acceleration = Acceleration._();
  static const AccelerometerAngle accelerometerAngle = AccelerometerAngle._();
  static const AngularVelocity angularVelocity = AngularVelocity._();

  const Metric();

  Point3<X, double> transform<X>(Point3<X, double> data);
}

class Acceleration extends Metric<Accelerometer> {
  const Acceleration._();

  @override
  Point3<X, double> transform<X>(Point3<X, double> data) => data;
}

class AccelerometerAngle extends Metric<Accelerometer> {
  const AccelerometerAngle._();

  @override
  Point3<X, double> transform<X>(Point3<X, double> data) {
    return Point3(
      data.key,
      x: 9.18368 * (9.8 - data.x),
      y: 9.18368 * (9.8 - data.y),
      z: 9.18368 * (9.8 - data.z),
    );
  }
}

class AngularVelocity extends Metric<Gyroscope> {
  const AngularVelocity._();

  @override
  Point3<X, double> transform<X>(Point3<X, double> data) => data;
}
