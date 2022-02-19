library sensorial;

import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/models/controllers.dart';
import 'package:sensorial/src/models/data_transformation.dart';
import 'package:sensorial/src/models/metric.dart';
import 'package:sensorial/src/models/sensor.dart';
import 'package:sensorial/src/models/sensor_data.dart';
import 'package:sensorial/src/sensors/flutter_sensors.dart';
import 'package:sensorial/src/utils/sequential_getter.dart';
import 'package:sensorial/src/utils/streaming.dart';

export 'src/models/axis.dart';
export 'src/models/controllers.dart';
export 'src/models/data_transformation.dart';
export 'src/models/metric.dart';
export 'src/models/sensor.dart';
export 'src/models/sensor_data.dart';
export 'src/utils/collection.dart';
export 'src/utils/sequential_getter.dart';
export 'src/utils/streaming.dart';

class Sensorial {
  const Sensorial._();

  Map<Metric<S>, TimeSeries> parseData<S extends Sensor>(
    SyncTransposedSensorData<S, Duration, double> data,
  ) {
    return Map.fromIterable(data.metrics, value: (key) {
      final Metric<S> metric = key as Metric<S>;
      final SyncMetricData<Duration, double> metricData = data.metric(metric);
      return TimeSeries(metricData.collect().value);
    });
  }

  _InteractiveBuilder interactive() => _InteractiveBuilder();
}

typedef SensorStreamListener = void Function(
    Map<Metric, Point3<Duration, double>>);

typedef PointProvider<X, Y> = Point3<X, Y> Function(int);

class _SensorEventTransforming
    extends TransformingFunction<SensorEvent, Point3<Duration, double>> {
  final FirstValueGetter<Duration> _getter = SequentialGetter.first();

  @override
  Iterable<Point3<Duration, double>> onValue(SensorEvent event) sync* {
    final Duration currentDuration = Duration(milliseconds: event.timestamp);
    final Duration firstDuration = _getter.accept(currentDuration);
    final Duration duration = currentDuration - firstDuration;

    final List<double> data = event.data;
    yield Point3<Duration, double>(
      duration,
      x: data[0],
      y: data[1],
      z: data[2],
    );
  }
}

class _InteractiveBuilder {
  _InteractiveBuilder();

  PointProvider<Duration, double>? _source;

  Duration _interval = const Duration(milliseconds: 30);

  Stream<Point3<Duration, double>> _sourceStream({
    required int sensorId,
  }) {
    final Point3<Duration, double> Function(int)? source = _source;
    if (source == null) {
      return SensorManager()
          .sensorUpdates(sensorId: sensorId, interval: _interval)
          .transform(_SensorEventTransforming());
    } else {
      return Stream.periodic(_interval, source);
    }
  }

  _InteractiveBuilder interval(Duration duration) {
    _interval = duration;
    return this;
  }

  _InteractiveBuilder source(PointProvider<Duration, double> source) {
    _source = source;
    return this;
  }

  _SensorStreamBuilder<S> sensor<S extends Sensor>(S sensor) {
    return _SensorStreamBuilder._(_sourceStream(sensorId: sensor.id));
  }
}

class _SensorStreamBuilder<S extends Sensor> {
  final Stream<Point3<Duration, double>> _stream;

  DataTransformation _operation = DataTransformation.none();
  final Set<Metric<S>> _metrics = {};

  _SensorStreamBuilder._(this._stream);

  _SensorStreamBuilder<S> operation(DataTransformation operation) {
    _operation = operation;
    return this;
  }

  _SensorStreamBuilder<S> metric(Metric<S> metric) {
    _metrics.add(metric);
    return this;
  }

  AsyncSensorData<S, Duration, double> build() {
    Iterable<Point3<Duration, double>> _onTransform(
      Point3<Duration, double> point,
    ) sync* {
      final Point3<Duration, double>? transformed =
          _operation.onData<Duration>(point);
      if (transformed == null) return;
      yield transformed;
    }

    return SensorData.async(
      _stream
          .transform(TransformingUnaryOperator.parameter(_onTransform))
          .map((point) {
        final Map<Metric<S>, Data3<double>> transforms = Map.fromIterable(
          _metrics,
          value: (metric) => (metric as Metric<S>).transform(point),
        );

        return SensorValue(
          Point3(
            point.key,
            x: transforms.map((metric, data) => MapEntry(metric, data.x)),
            y: transforms.map((metric, data) => MapEntry(metric, data.y)),
            z: transforms.map((metric, data) => MapEntry(metric, data.z)),
          ),
          metrics: _metrics,
        );
      }),
      metrics: _metrics,
    );
  }
}

const Sensorial sensorial = Sensorial._();
