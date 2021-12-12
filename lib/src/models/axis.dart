/// Represents three-dimensional axes.
enum Axis3 { x, y, z }

/// Represents a point in a 2D system.
///
/// In this system, [X] is the range and [Y] is the domain.
class Point2<X, Y> {
  final X x;
  final Y y;

  const Point2({required this.x, required this.y});
}

/// Represents data in a 3D system.
///
/// In this system, the x-, y- and z-axis contains values of type [T].
abstract class Data3<T> extends Iterable<Point2<Axis3, T>> {
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
  Iterator<Point2<Axis3, T>> get iterator =>
      Axis3.values.map((axis) => Point2(x: axis, y: this[axis])).iterator;
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
class Series3<X, Y> extends Data3<List<Point2<X, Y>>> {
  final List<Point3<X, Y>> _data;

  /// Creates a series from a list of 3D points.
  const Series3(this._data);

  /// Return the points from the x-axis of this series.
  @override
  List<Point2<X, Y>> get x =>
      _data.map((point) => Point2(x: point.key, y: point.x)).toList();

  /// Return the points from the y-axis of this series.
  @override
  List<Point2<X, Y>> get y =>
      _data.map((point) => Point2(x: point.key, y: point.y)).toList();

  /// Return the points from the z-axis of this series.
  @override
  List<Point2<X, Y>> get z =>
      _data.map((point) => Point2(x: point.key, y: point.z)).toList();
}

/// Represents a group of doubles in a 3D system.
class DoubleSeries<X> extends Series3<X, double> {
  const DoubleSeries(List<Point3<X, double>> data) : super(data);
}

/// Represents a group of time-to-doubles points in a 3D system.
///
/// Useful to represent a time series.
class TimeSeries extends DoubleSeries<DateTime> {
  const TimeSeries(List<Point3<DateTime, double>> data) : super(data);
}

/// Represents a group of Hz-to-doubles points in a 3D system.
///
/// Useful to represent a frequency-domain series (such as the result of a
/// Fourier Transform).
class FrequencySeries extends DoubleSeries<double> {
  const FrequencySeries(List<Point3<double, double>> data) : super(data);
}
