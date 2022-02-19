library sensorial;

import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/models/controllers.dart';
import 'package:sensorial/src/models/data_transformation.dart';
import 'package:sensorial/src/models/metric.dart';
import 'package:sensorial/src/models/metric_data.dart';
import 'package:sensorial/src/models/sensor.dart';
import 'package:sensorial/src/models/sensor_filter.dart';
import 'package:sensorial/src/sensors/flutter_sensors.dart';

export 'src/models/axis.dart';
export 'src/models/controllers.dart';
export 'src/models/data_transformation.dart';
export 'src/models/metric.dart';
export 'src/models/metric_data.dart';
export 'src/models/sensor.dart';
export 'src/models/sensor_filter.dart';
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
          .map((event) {
        final List<double> data = event.data;
        return Point3<DateTime, double>(
          DateTime.fromMillisecondsSinceEpoch(event.timestamp),
          x: data[0],
          y: data[1],
          z: data[2],
        );
      });
    } else {
      return Stream.periodic(_interval, source);
    }
  }

  _InteractiveBuilder interval(Duration duration) {
    _interval = duration;
    return this;
  }

  _InteractiveBuilder source(PointProvider<DateTime, double> source) {
    _source = source;
    return this;
  }

  _SensorStreamBuilder<S> sensor<S extends Sensor>(SensorFilter<S> filter) {
    return _SensorStreamBuilder._(_sourceStream(sensorId: filter.sensor.id));
  }
}

class _SensorStreamBuilder<S extends Sensor> {
  final Stream<Point3<Duration, double>> _stream;

  DataTransformation _operation = DataTransformation.none();
  final Set<Metric<S>> _metrics = {};
  InteractiveController? _controller;

  _SensorStreamBuilder._(this._stream);

  _SensorStreamBuilder<S> operation(DataTransformation operation) {
    _operation = operation;
    return this;
  }

  _SensorStreamBuilder<S> metric(Metric<S> metric) {
    _metrics.add(metric);
    return this;
  }

  _SensorStreamBuilder<S> controller(InteractiveController controller) {
    _controller = controller;
    return this;
  }

  AsyncSensorData<S, Duration, double> build() {
    return SensorData.async(
      _stream
          .map((point) => _operation.onData<DateTime>(point))
          .where((point) => point != null)
          .cast<Point3<DateTime, double>>()
          .where((point) {
        final InteractiveController? controller = _controller;
        if (controller == null) return true;
        return controller.isRunning;
      }).map((point) {
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
