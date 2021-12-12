import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/models/sensor.dart';

abstract class Metric<S extends Sensor> {
  static const Acceleration acceleration = Acceleration._();
  static const AccelerometerAngle accelerometerAngle = AccelerometerAngle._();
  static const AngularVelocity angularVelocity = AngularVelocity._();

  const Metric();

  Data3<double> transform(Data3<double> data);
}

class Acceleration extends Metric<Accelerometer> {
  const Acceleration._();

  @override
  Data3<double> transform(Data3<double> data) => data;
}

class AccelerometerAngle extends Metric<Accelerometer> {
  const AccelerometerAngle._();

  @override
  Data3<double> transform(Data3<double> data) {
    return Point3(
      0,
      x: 9.18368 * (9.8 - data.x),
      y: 9.18368 * (9.8 - data.y),
      z: 9.18368 * (9.8 - data.z),
    );
  }
}

class AngularVelocity extends Metric<Gyroscope> {
  const AngularVelocity._();

  @override
  Data3<double> transform(Data3<double> data) => data;
}
