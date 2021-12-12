part of 'metric_data.dart';

/// Represents data with range [X] and domain [Y] returned by a sensor [S].
///
/// This represents a collection of points returned by the sensor.
/// [SensorData.async] represents points from a stream (e.g. read real-time from
/// the device's accelerometer) while [SensorData.sync] represents points from a
/// list (e.g. read from a in-memory file).
///
/// Considering the following fake accelerometer data:
///
/// ```lang-none
///               Timestamp,Acc X,Acc Y,Acc Z,AngA X,AngA Y,AngA Z
/// 2021-12-10 22:06:10.200, 0.13, 0.20, 9.81,  0.00,  0.00, 89.75
/// 2021-12-10 22:06:10.400, 0.16, 0.12, 9.80,  0.20,  0.10, 89.20
/// ...
/// ```
///
/// an object of this class can be built programmatically by
///
/// ```dart
/// final SensorData<Accelerometer, DateTime, double> data = SensorData.sync(
///   [
///     Point3(
///       DateTime.parse("2021-12-10 22:06:10.200"),
///       x: {Metric.acceleration: 0.13, Metric.accelerometerAngle: 0.00},
///       y: {Metric.acceleration: 0.20, Metric.accelerometerAngle: 0.00},
///       z: {Metric.acceleration: 9.81, Metric.accelerometerAngle: 89.75},
///     ),
///     Point3(
///       DateTime.parse("2021-12-10 22:06:10.400"),
///       x: {Metric.acceleration: 0.16, Metric.accelerometerAngle: 0.20},
///       y: {Metric.acceleration: 0.12, Metric.accelerometerAngle: 0.10},
///       z: {Metric.acceleration: 9.80, Metric.accelerometerAngle: 89.20},
///     ),
///     // ...
///   ],
///   metrics: {Metric.acceleration, Metric.accelerometerAngle},
/// );
/// ```
///
/// This class has the following contracts, meaning that building an object
/// disrespecting any of these contracts will not throw any errors, but the
/// caller may face unexpected behaviour:
///
/// - the metric values passed to the inner `x`, `y` and `z` fields **should**
///   be compatible with the [metrics] attribute of this object. This means
///   that, for each [Point3] `point` passed either to the list parameter of the
///   [SensorData.sync] method or the stream parameter of the [SensorData.async]
///   method, `point.x`, `point.y` and `point.z` keys should be exactly equal to
///   [metrics].
///
/// A transposed version of this data, which allows easier metric filtering, can
/// be accessed using the [transpose] method.
abstract class SensorData<S extends Sensor, X, Y>
    implements Collector<SensorValue<S, X, Y>> {
  /// Creates a [SensorData] backed by a [stream].
  static AsyncSensorData<S, X, Y> async<S extends Sensor, X, Y>(
    Stream<SensorValue<S, X, Y>> stream, {
    required Set<Metric<S>> metrics,
  }) {
    return AsyncSensorData._value(stream, metrics: metrics);
  }

  /// Creates a [SensorData] backed by a [list].
  static SyncSensorData<S, X, Y> sync<S extends Sensor, X, Y>(
    List<SensorValue<S, X, Y>> list, {
    required Set<Metric<S>> metrics,
  }) {
    return SyncSensorData._value(list, metrics: metrics);
  }

  final Collection<SensorValue<S, X, Y>> _values;

  /// The metrics available by this data.
  final Set<Metric<S>> metrics;

  const SensorData(
    this._values, {
    required this.metrics,
  });

  /// Creates a transposed version of this data.
  TransposedSensorData<S, X, Y> transpose() {
    return _onTransposedData(
      _values.map((point) => point.transpose()),
      metrics: metrics,
    );
  }

  TransposedSensorData<S, X, Y> _onTransposedData(
    Collection<TransposedSensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  });
}

/// Represents a [SensorData] backed by a list.
class SyncSensorData<S extends Sensor, X, Y> extends SensorData<S, X, Y> {
  const SyncSensorData._(
    SyncCollection<SensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) : super(values, metrics: metrics);

  SyncSensorData._value(
    List<SensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) : this._(SyncCollection(values), metrics: metrics);

  @override
  SyncTransposedSensorData<S, X, Y> transpose() =>
      super.transpose() as SyncTransposedSensorData<S, X, Y>;

  @override
  TransposedSensorData<S, X, Y> _onTransposedData(
    Collection<TransposedSensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) {
    return SyncTransposedSensorData._(
      values as SyncCollection<TransposedSensorValue<S, X, Y>>,
      metrics: metrics,
    );
  }

  @override
  SyncCollection<SensorValue<S, X, Y>> collect() =>
      _values as SyncCollection<SensorValue<S, X, Y>>;
}

/// Represents a [SensorData] backed by a stream.
class AsyncSensorData<S extends Sensor, X, Y> extends SensorData<S, X, Y> {
  const AsyncSensorData._(
    AsyncCollection<SensorValue<S, X, Y>> collection, {
    required Set<Metric<S>> metrics,
  }) : super(collection, metrics: metrics);

  AsyncSensorData._value(
    Stream<SensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) : this._(AsyncCollection(values), metrics: metrics);

  @override
  AsyncTransposedSensorData<S, X, Y> transpose() =>
      super.transpose() as AsyncTransposedSensorData<S, X, Y>;

  @override
  TransposedSensorData<S, X, Y> _onTransposedData(
    Collection<TransposedSensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) {
    return AsyncTransposedSensorData._collection(
      values as AsyncCollection<TransposedSensorValue<S, X, Y>>,
      metrics: metrics,
    );
  }

  @override
  AsyncCollection<SensorValue<S, X, Y>> collect() =>
      _values as AsyncCollection<SensorValue<S, X, Y>>;
}

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
/// final TransposedSensorValue<Accelerometer, DateTime, double> data;
/// data = TransposedSensorValue(
///   {
///     Metric.acceleration: Point3(
///       DateTime.parse("2021-12-10 22:06:10.200"),
///       x: 0.13,
///       y: 0.20,
///       z: 9.81,
///     ),
///     Metric.accelerometerAngle: Point3(
///       DateTime.parse("2021-12-10 22:06:10.200"),
///       x: 0.03,
///       y: 0.00,
///       z: 89.75,
///     ),
///   },
///   key: DateTime.parse("2021-12-10 22:06:10.200"),
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

/// Represents data with range [X] and domain[Y] returned by a sensor [S].
///
/// This represents a collection of points transposed in relation with
/// [SensorData]. This means that this class prioritizes the metrics instead of
/// the range.
///
/// Considering the following fake accelerometer data:
///
/// ```lang-none
///               Timestamp,Acc X,Acc Y,Acc Z,AngA X,AngA Y,AngA Z
/// 2021-12-10 22:06:10.200, 0.13, 0.20, 9.81,  0.00,  0.00, 89.75
/// 2021-12-10 22:06:10.400, 0.16, 0.12, 9.80,  0.20,  0.10, 89.20
/// ...
/// ```
///
/// an object of this class can be built programmatically by
///
/// ```dart
/// final TransposedSensorData<Accelerometer, DateTime, double> data;
/// data = TransposedSensorData.sync(
///   <TransposedSensorValue<Accelerometer, DateTime, double>>[
///     TransposedSensorValue(
///       {
///         Metric.acceleration: Point3(
///           DateTime.parse("2021-12-10 22:06:10.200"),
///           x: 0.13,
///           y: 0.20,
///           z: 9.81,
///         ),
///         Metric.accelerometerAngle: Point3(
///           DateTime.parse("2021-12-10 22:06:10.200"),
///           x: 0.00,
///           y: 0.00,
///           z: 89.75,
///         ),
///       },
///       key: DateTime.parse("2021-12-10 22:06:10.200"),
///     ),
///     TransposedSensorValue(
///       {
///         Metric.acceleration: Point3(
///           DateTime.parse("2021-12-10 22:06:10.400"),
///           x: 0.16,
///           y: 0.12,
///           z: 9.80,
///         ),
///         Metric.accelerometerAngle: Point3(
///           DateTime.parse("2021-12-10 22:06:10.400"),
///           x: 0.20,
///           y: 0.10,
///           z: 89.20,
///         ),
///       },
///       key: DateTime.parse("2021-12-10 22:06:10.400"),
///     ),
///     // ...
///   ],
///   metrics: {Metric.acceleration, Metric.accelerometerAngle},
/// );
/// ```
///
/// This class has the following contracts, meaning that building an object
/// disrespecting any of these contracts will not throw any errors, but the
/// caller may face unexpected behaviour:
///
/// - the contracts provided by [TransposedSensorValue];
///
/// - the metrics passed as keys to the [TransposedSensorValue]'s parameter
///   **should** be compatible with the [metrics] attribute of this object. This
///   means that, for each [TransposedSensorValue] `value` passed either to the
///   list parameter of the [TransposedSensorData.sync] method or the stream
///   parameter of the [TransposedSensorData.async] method, its
///   [TransposedSensorValue.points] attribute's keys should be exactly equal to
///   the [metrics] attribute of this object.
///
/// To filter the data by metric, use the [metric] method.
abstract class TransposedSensorData<S extends Sensor, X, Y>
    extends Data3<Collection<Map<Metric<S>, Point2<X, Y>>>>
    implements Collector<TransposedSensorValue<S, X, Y>> {
  /// Creates a [SensorData] backed by a [stream].
  static AsyncTransposedSensorData<S, X, Y> async<S extends Sensor, X, Y>(
    Stream<TransposedSensorValue<S, X, Y>> stream, {
    required Set<Metric<S>> metrics,
  }) {
    return AsyncTransposedSensorData._value(stream, metrics: metrics);
  }

  /// Creates a [SensorData] backed by a [list].
  static SyncTransposedSensorData<S, X, Y> sync<S extends Sensor, X, Y>(
    List<TransposedSensorValue<S, X, Y>> list, {
    required Set<Metric<S>> metrics,
  }) {
    return SyncTransposedSensorData._value(list, metrics: metrics);
  }

  final Collection<TransposedSensorValue<S, X, Y>> _values;

  /// The metrics available by this data.
  final Set<Metric<S>> metrics;

  const TransposedSensorData._(
    this._values, {
    required this.metrics,
  });

  SensorData<S, X, Y> transpose() {
    return _onTransposedData(
      _values.map((point) => point.transpose()),
      metrics: metrics,
    );
  }

  SensorData<S, X, Y> _onTransposedData(
    Collection<SensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  });

  /// Filter this data by a given [metric].
  ///
  /// This will return the points provided by the given metric.
  MetricData<X, Y> metric(Metric<S> metric) => _onMetricData(
      _values.map((event) => event.points[metric]).whereType<Point3<X, Y>>());

  /// Utility method to avoid duplication when retrieving an axis-specific value.
  Collection<Map<Metric<S>, Point2<X, Y>>> _domain(
    Y Function(Point3<X, Y>) y,
  ) {
    return _values.map((value) => value.points.map((metric, point) {
          return MapEntry(metric, Point2(x: point.key, y: y(point)));
        }));
  }

  /// Return the metrics and their respective points from the x-axis of this data.
  @override
  Collection<Map<Metric<S>, Point2<X, Y>>> get x => _domain((point) => point.x);

  /// Return the metrics and their respective points from the y-axis of this data.
  @override
  Collection<Map<Metric<S>, Point2<X, Y>>> get y => _domain((point) => point.y);

  /// Return the metrics and their respective points from the z-axis of this data.
  @override
  Collection<Map<Metric<S>, Point2<X, Y>>> get z => _domain((point) => point.z);

  MetricData<X, Y> _onMetricData(Collection<Point3<X, Y>> collection);
}

/// Represents a [TransposedSensorData] backed by a list.
class AsyncTransposedSensorData<S extends Sensor, X, Y>
    extends TransposedSensorData<S, X, Y> {
  const AsyncTransposedSensorData._collection(
    AsyncCollection<TransposedSensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) : super._(values, metrics: metrics);

  AsyncTransposedSensorData._value(
    Stream<TransposedSensorValue<S, X, Y>> stream, {
    required Set<Metric<S>> metrics,
  }) : this._collection(AsyncCollection(stream), metrics: metrics);

  @override
  AsyncCollection<TransposedSensorValue<S, X, Y>> get _values =>
      super._values as AsyncCollection<TransposedSensorValue<S, X, Y>>;

  @override
  AsyncMetricData<X, Y> metric(Metric<S> metric) =>
      super.metric(metric) as AsyncMetricData<X, Y>;

  @override
  MetricData<X, Y> _onMetricData(Collection<Point3<X, Y>> collection) =>
      AsyncMetricData._(collection as AsyncCollection<Point3<X, Y>>);

  @override
  AsyncSensorData<S, X, Y> transpose() =>
      super.transpose() as AsyncSensorData<S, X, Y>;

  @override
  SensorData<S, X, Y> _onTransposedData(
    Collection<SensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) {
    return AsyncSensorData._(
      values as AsyncCollection<SensorValue<S, X, Y>>,
      metrics: metrics,
    );
  }

  @override
  AsyncCollection<TransposedSensorValue<S, X, Y>> collect() => _values;
}

/// Represents a [TransposedSensorData] backed by a stream.
class SyncTransposedSensorData<S extends Sensor, X, Y>
    extends TransposedSensorData<S, X, Y> {
  const SyncTransposedSensorData._(
    SyncCollection<TransposedSensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) : super._(values, metrics: metrics);

  SyncTransposedSensorData._value(
    List<TransposedSensorValue<S, X, Y>> list, {
    required Set<Metric<S>> metrics,
  }) : this._(SyncCollection(list), metrics: metrics);

  @override
  SyncCollection<TransposedSensorValue<S, X, Y>> get _values =>
      super._values as SyncCollection<TransposedSensorValue<S, X, Y>>;

  @override
  SyncMetricData<X, Y> metric(Metric<S> metric) =>
      super.metric(metric) as SyncMetricData<X, Y>;

  @override
  MetricData<X, Y> _onMetricData(Collection<Point3<X, Y>> collection) =>
      SyncMetricData._(collection as SyncCollection<Point3<X, Y>>);

  @override
  SyncSensorData<S, X, Y> transpose() =>
      super.transpose() as SyncSensorData<S, X, Y>;

  @override
  SensorData<S, X, Y> _onTransposedData(
    Collection<SensorValue<S, X, Y>> values, {
    required Set<Metric<S>> metrics,
  }) {
    return SyncSensorData._(
      values as SyncCollection<SensorValue<S, X, Y>>,
      metrics: metrics,
    );
  }

  @override
  SyncCollection<TransposedSensorValue<S, X, Y>> collect() => _values;
}
