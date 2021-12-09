library sensorial;

import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/models/controllers.dart';
import 'package:sensorial/src/models/data_transformation.dart';
import 'package:sensorial/src/models/metric.dart';
import 'package:sensorial/src/models/metric_data.dart';
import 'package:sensorial/src/models/sensor.dart';
import 'package:sensorial/src/models/sensor_filter.dart';
import 'package:sensorial/src/sensors/flutter_sensors.dart';

class Sensorial {
  const Sensorial._();

  Map<Metric<S>, TimeSeries> parse<S extends Sensor>(
      SyncSensorData<S, DateTime, double> data) {
    final Set<Metric> metrics = {...data.get().list.expand((e) => e.keys)};
    return Map.fromIterable(metrics, value: (key) {
      final Metric<S> metric = key as Metric<S>;
      final SyncMetricData<DateTime, double> metricData =
          data.metric(metric) as SyncMetricData<DateTime, double>;
      return TimeSeries(metricData.get().list);
    });
  }

  _InteractiveBuilder interactive() => _InteractiveBuilder();
}

typedef SensorStreamListener = void Function(
    Map<Metric, Point3<DateTime, double>>);

typedef PointProvider<X, Y> = Point3<X, Y> Function(int);

class _InteractiveBuilder {
  _InteractiveBuilder();

  PointProvider<DateTime, double>? _source;

  Duration _interval = const Duration(milliseconds: 30);

  Stream<Point3<DateTime, double>> _sourceStream({
    required int sensorId,
  }) {
    final Point3<DateTime, double> Function(int)? source = _source;
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
  final Stream<Point3<DateTime, double>> stream;

  DataTransformation _operation = DataTransformation.none();
  final Set<Metric> _metrics = {};
  final Set<SensorStreamListener> _listeners = {};
  InteractiveController? _controller;

  _SensorStreamBuilder._(this.stream);

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

  _SensorStreamBuilder<S> listener(SensorStreamListener listener) {
    _listeners.add(listener);
    return this;
  }

  AsyncSensorData<S, DateTime, double> get() {
    return SensorData.async(stream
        .map((point) => _operation.onData<DateTime>(point))
        .where((point) => point != null)
        .cast<Point3<DateTime, double>>()
        .map((point) {
          final InteractiveController? controller = _controller;
          if (controller == null) return point;
          return controller.isRunning ? point : null;
        })
        .where((point) => point != null)
        .cast<Point3<DateTime, double>>()
        .map((point) {
          return Map<Metric<S>, Point3<DateTime, double>>.fromIterable(
            _metrics,
            value: (metric) => (metric as Metric<S>).transform(point),
          );
        })
        .map((point) {
          for (SensorStreamListener listener in _listeners) {
            listener(point);
          }
          return point;
        }));
  }
}

const Sensorial sensorial = Sensorial._();
