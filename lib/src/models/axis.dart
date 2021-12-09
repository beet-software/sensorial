/// Represents three-dimensional axes.
enum Axis3 { x, y, z }

/// Represents a [value] in a particular [axis] direction in a 3D system.
class AxisValue<T> {
  final Axis3 axis;
  final T value;

  const AxisValue({required this.axis, required this.value});
}

/// Represents a point in a 2D system.
///
/// In this system, [X] is the range and [Y] is the domain.
class Point2<X, Y> {
  final X x;
  final Y y;

  const Point2({required this.x, required this.y});
}

/// Represents data in a 3D system.
abstract class Data3<T> extends Iterable<AxisValue<T>> {
  const Data3();

  /// Represents a value in the X-axis.
  T get x;

  /// Represents a value in the Y-axis.
  T get y;

  /// Represents a value in the Z-axis.
  T get z;

  /// Access a value in a given [axis].
  T operator [](Axis3 axis) {
    switch (axis) {
      case Axis3.x:
        return x;
      case Axis3.y:
        return y;
      case Axis3.z:
        return z;
    }
  }

  /// Creates an iterator that goes over the values in each direction of this
  /// system, in the order X, Y and Z.
  @override
  Iterator<AxisValue<T>> get iterator => Axis3.values
      .map((axis) => AxisValue(axis: axis, value: this[axis]))
      .iterator;
}

/// Represents a point in a 3D system.
class Point3<X, Y> extends Data3<Y> {
  final X key;

  @override
  final Y x;

  @override
  final Y y;

  @override
  final Y z;

  const Point3(this.key, {required this.x, required this.y, required this.z});
}

/// Represents a group of points in a 3D system.
class Series<X, Y> extends Data3<List<Point2<X, Y>>> {
  final List<Point3<X, Y>> _data;

  const Series(this._data);

  @override
  List<Point2<X, Y>> get x =>
      _data.map((point) => Point2(x: point.key, y: point.x)).toList();

  @override
  List<Point2<X, Y>> get y =>
      _data.map((point) => Point2(x: point.key, y: point.y)).toList();

  @override
  List<Point2<X, Y>> get z =>
      _data.map((point) => Point2(x: point.key, y: point.z)).toList();
}

class DoubleSeries<X> extends Series<X, double> {
  const DoubleSeries(List<Point3<X, double>> data) : super(data);
}

class TimeSeries extends DoubleSeries<DateTime> {
  const TimeSeries(List<Point3<DateTime, double>> data) : super(data);
}

class FrequencySeries extends DoubleSeries<double> {
  const FrequencySeries(List<Point3<double, double>> data) : super(data);
}
