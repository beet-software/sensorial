part of 'metric_data.dart';

abstract class SensorData<S extends Sensor, X, Y>
    extends Data3<Collection<Map<Metric<S>, Point2<X, Y>>>> {
  static AsyncSensorData<S, X, Y> async<S extends Sensor, X, Y>(
          Stream<Map<Metric<S>, Point3<X, Y>>> stream) =>
      AsyncSensorData._(stream);

  static SyncSensorData<S, X, Y> sync<S extends Sensor, X, Y>(
          List<Map<Metric<S>, Point3<X, Y>>> list) =>
      SyncSensorData._(list);

  final Collection<Map<Metric<S>, Point3<X, Y>>> _values;

  const SensorData._(this._values);

  MetricData<X, Y> metric(Metric<S> metric) => _onMetricData(
      _values.map((event) => event[metric]).whereType<Point3<X, Y>>());

  Collection<Map<Metric<S>, Point2<X, Y>>> _domain(
    Y Function(Point3<X, Y>) y,
  ) =>
      _values.map((points) => points.map((metric, point) =>
          MapEntry(metric, Point2(x: point.key, y: y(point)))));

  @override
  Collection<Map<Metric<S>, Point2<X, Y>>> get x => _domain((point) => point.x);

  @override
  Collection<Map<Metric<S>, Point2<X, Y>>> get y => _domain((point) => point.y);

  @override
  Collection<Map<Metric<S>, Point2<X, Y>>> get z => _domain((point) => point.z);

  MetricData<X, Y> _onMetricData(Collection<Point3<X, Y>> collection);

  Collection<Map<Metric<S>, Point3<X, Y>>> get();
}

class AsyncSensorData<S extends Sensor, X, Y> extends SensorData<S, X, Y> {
  AsyncSensorData._(Stream<Map<Metric<S>, Point3<X, Y>>> stream)
      : super._(AsyncCollection(stream));

  @override
  AsyncMetricData<X, Y> metric(Metric<S> metric) =>
      super.metric(metric) as AsyncMetricData<X, Y>;

  @override
  MetricData<X, Y> _onMetricData(Collection<Point3<X, Y>> collection) {
    return AsyncMetricData._(collection as AsyncCollection<Point3<X, Y>>);
  }

  @override
  AsyncCollection<Map<Metric<S>, Point3<X, Y>>> get() =>
      _values as AsyncCollection<Map<Metric<S>, Point3<X, Y>>>;
}

class SyncSensorData<S extends Sensor, X, Y> extends SensorData<S, X, Y> {
  SyncSensorData._(List<Map<Metric<S>, Point3<X, Y>>> list)
      : super._(SyncCollection(list));

  @override
  SyncMetricData<X, Y> metric(Metric<S> metric) =>
      super.metric(metric) as SyncMetricData<X, Y>;

  @override
  MetricData<X, Y> _onMetricData(Collection<Point3<X, Y>> collection) {
    return SyncMetricData._(collection as SyncCollection<Point3<X, Y>>);
  }

  @override
  SyncCollection<Map<Metric<S>, Point3<X, Y>>> get() =>
      _values as SyncCollection<Map<Metric<S>, Point3<X, Y>>>;
}
