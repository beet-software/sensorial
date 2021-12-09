import 'package:sensorial/src/models/axis.dart';
import 'package:sensorial/src/utils/sequential_getter.dart';

/// Represents a transformation on a given [Point3] passed to [onData].
///
/// This transformation does not affect the range of the point, only its domain.
abstract class DataTransformation {
  /// Creates a transformation that lefts the input data unchanged.
  ///
  /// On [[4, 7, 6, 1, 3]], this would return [[4, 7, 6, 1, 3]].
  static _NoOperation none() => const _NoOperation();

  /// Creates a transformation that subtracts consecutive elements of the
  /// input data, therefore returning its variation.
  ///
  /// The first call to [onData] of this transformation will return `null`.
  ///
  /// On [[4, 7, 6, 1, 3]], this would return [[null, 3, -1, -5, 2]].
  ///
  /// This transformation is applied to all axes of the given point.
  static _VariationOperation variation() => _VariationOperation();

  const DataTransformation._();

  /// Transforms a given input [data].
  ///
  /// If `null` is returned, this object might not have sufficient data to
  /// apply the transformation. For example, if this object's transformation
  /// requires two elements as input (say *f(x, y)*), the first call to this
  /// function should return `null` and the second call should return the result
  /// of the operation between the arguments provided in the first (*x*) and the
  /// second (*y*) calls.
  Point3<X, double>? onData<X>(Point3<X, double> data);
}

class _NoOperation extends DataTransformation {
  const _NoOperation() : super._();

  @override
  Point3<X, double>? onData<X>(Point3<X, double> data) {
    return data;
  }
}

class _VariationOperation extends DataTransformation {
  final PreviousValueGetter<Data3<double>> _getter =
      SequentialGetter.previous();

  _VariationOperation() : super._();

  @override
  Point3<X, double>? onData<X>(Point3<X, double> data) {
    final Data3<double>? previousData = _getter.accept(data);
    if (previousData == null) return null;

    return Point3<X, double>(
      data.key,
      x: data.x - previousData.x,
      y: data.y - previousData.y,
      z: data.z - previousData.z,
    );
  }
}
