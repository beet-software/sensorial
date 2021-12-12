import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/models/metric.dart';
import 'package:sensorial/src/models/sensor.dart';
import 'package:sensorial/src/utils/collection.dart';

part 'sensor_data.dart';

abstract class MetricData<X, Y> extends Data3<Collection<Point2<X, Y>>>
    implements Collector<Point3<X, Y>> {
  final Collection<Point3<X, Y>> _values;

  const MetricData._(this._values);

  Collection<Point2<X, Y>> _domain(Y Function(Point3<X, Y>) y) =>
      _values.map((point) => Point2(x: point.key, y: y(point)));

  @override
  Collection<Point2<X, Y>> get x => _domain((point) => point.x);

  @override
  Collection<Point2<X, Y>> get y => _domain((point) => point.y);

  @override
  Collection<Point2<X, Y>> get z => _domain((point) => point.z);
}

class AsyncMetricData<X, Y> extends MetricData<X, Y> {
  const AsyncMetricData._(
    AsyncCollection<Point3<X, Y>> collection,
  ) : super._(collection);

  AsyncMetricData(
    Stream<Point3<X, Y>> stream,
  ) : this._(AsyncCollection(stream));

  @override
  AsyncCollection<Point3<X, Y>> get _values =>
      super._values as AsyncCollection<Point3<X, Y>>;

  @override
  AsyncCollection<Point3<X, Y>> collect() => _values;
}

class SyncMetricData<X, Y> extends MetricData<X, Y> {
  const SyncMetricData._(
    SyncCollection<Point3<X, Y>> collection,
  ) : super._(collection);

  SyncMetricData(
    List<Point3<X, Y>> stream,
  ) : this._(SyncCollection(stream));

  @override
  SyncCollection<Point3<X, Y>> get _values =>
      super._values as SyncCollection<Point3<X, Y>>;

  @override
  SyncCollection<Point3<X, Y>> collect() => _values;
}
