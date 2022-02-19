part of 'sensor_data.dart';

/// Represent a value provided by a [SensorData].
///
/// Considering the following fake accelerometer data:
///
/// ```lang-none
///               Timestamp,Acc X,Acc Y,Acc Z,AngA X,AngA Y,AngA Z
/// 2021-12-10 22:06:10.200, 0.13, 0.20, 9.81,  0.00,  0.00, 89.75
/// ...
/// ```
///
/// an object of this class can be built programmatically by
///
/// ```
/// final SensorValue<Accelerometer, Duration, double> value = SensorValue(
///   Point3(
///     Duration.parse("2021-12-10 22:06:10.200"),
///     x: {Metric.acceleration: 0.13, Metric.accelerometerAngle: 0.00},
///     y: {Metric.acceleration: 0.20, Metric.accelerometerAngle: 0.00},
///     z: {Metric.acceleration: 9.81, Metric.accelerometerAngle: 89.75},
///   ),
///   metrics: {Metric.acceleration, Metric.accelerometerAngle},
/// );
/// ```
///
/// This class has the following contracts, meaning that building an object
/// disrespecting any of these contracts will not throw any errors, but the
/// caller may face unexpected behaviour:
///
/// - the metric values passed as keys to the inner [Point3] object **should**
///   be compatible with the [metrics] attribute of this object. This means
///   that each metric used as keys in the [Point3.x], [Point3.y] and [Point.z]
///   attributes of point should be exactly equal to [metrics].
class SensorValue<S extends Sensor, X, Y> {
  final Point3<X, Map<Metric<S>, Y>> values;
  final Set<Metric<S>> metrics;

  const SensorValue(
    this.values, {
    required this.metrics,
  });

  X get key => values.key;

  TransposedSensorValue<S, X, Y> transpose() {
    return TransposedSensorValue(
      Map<Metric<S>, Point3<X, Y>>.fromIterable(
        metrics,
        value: (metric) => Point3(
          key,
          x: values.x[metric]!,
          y: values.y[metric]!,
          z: values.z[metric]!,
        ),
      ),
      key: key,
    );
  }
}

/// Represent a value provided by a [TransposedSensorData].
///
/// Considering the following fake accelerometer data:
///
/// ```lang-none
///               Timestamp,Acc X,Acc Y,Acc Z,AngA X,AngA Y,AngA Z
/// 2021-12-10 22:06:10.200, 0.13, 0.20, 9.81,  0.00,  0.00, 89.75
/// ...
/// ```
///
/// an object of this class can be built programmatically by
///
/// ```
/// final TransposedSensorValue<Accelerometer, Duration, double> value;
/// value = TransposedSensorValue(
///   {
///     Metric.acceleration: Point3(
///       Duration.parse("2021-12-10 22:06:10.200"),
///       x: 0.13,
///       y: 0.20,
///       z: 9.81,
///     ),
///     Metric.accelerometerAngle: Point3(
///       Duration.parse("2021-12-10 22:06:10.200"),
///       x: 0.03,
///       y: 0.00,
///       z: 89.75,
///     ),
///   },
///   key: Duration.parse("2021-12-10 22:06:10.200"),
/// );
/// ```
///
/// This class has the following contracts, meaning that building an object
/// disrespecting any of these contracts will not throw any errors, but the
/// caller may face unexpected behaviour:
///
/// - the domain values passed as keys to the inner [Point3] objects **should**
///   be compatible with the [key] attribute of this object. This means that,
///   for each [Point3] `point` used as value in the [points] attribute of this
///   object, `point.key` should be equal to [key].
class TransposedSensorValue<S extends Sensor, X, Y> {
  final Map<Metric<S>, Point3<X, Y>> points;
  final X key;

  const TransposedSensorValue(
    this.points, {
    required this.key,
  });

  Set<Metric<S>> get metrics => points.keys.toSet();

  SensorValue<S, X, Y> transpose() {
    return SensorValue(
      Point3(
        key,
        x: points.map((metric, point) => MapEntry(metric, point.x)),
        y: points.map((metric, point) => MapEntry(metric, point.y)),
        z: points.map((metric, point) => MapEntry(metric, point.z)),
      ),
      metrics: metrics,
    );
  }
}
