/// Represents a utility for getting attributes of a sequential context.
///
/// A sequential means that more than one value is involved (e.g. fetching data
/// sequentially from a sensor). To be able to extract attributes from
/// sequential data, this utility provides an [accept] method, which can be
/// called multiple times. Every time [accept] is called, an attribute can be
/// extracted (e.g. the first value passed as argument, the last value passed as
/// argument, how many values were passed as argument overall).
abstract class SequentialGetter<T, R> {
  /// {@macro first_value_getter_docs}
  static FirstValueGetter<T> first<T>() => FirstValueGetter._();

  /// {@macro previous_value_getter_docs}
  static PreviousValueGetter<T> previous<T>() => PreviousValueGetter._();

  R accept(T value);
}

/// {@template first_value_getter_docs}
/// Evaluates the first value passed to the [accept] method of this object.
/// <br><br>
/// ```dart
/// final FirstValueGetter<int> getter = SequentialGetter.first();
/// print(getter.accept(1));   // 1
/// print(getter.accept(7));   // 1
/// print(getter.accept(2));   // 1
/// print(getter.accept(5));   // 1
/// ```
/// {@endtemplate}
class FirstValueGetter<T> extends SequentialGetter<T, T> {
  FirstValueGetter._();

  T? _first;

  @override
  T accept(T value) {
    final T? first = _first;
    if (first == null) {
      _first = value;
      return value;
    }
    return first;
  }
}

/// {@template previous_value_getter_docs}
/// Evaluates the previous value passed to the [accept] method of this object,
/// returning `null` in the first call.
/// <br><br>
/// ```dart
/// final PreviousValueGetter<int> getter = SequentialGetter.previous();
/// print(getter.accept(1));   // null
/// print(getter.accept(7));   // 1
/// print(getter.accept(2));   // 7
/// print(getter.accept(5));   // 2
/// ```
/// {@endtemplate}
class PreviousValueGetter<T> extends SequentialGetter<T, T?> {
  PreviousValueGetter._();

  T? _previous;

  @override
  T? accept(T value) {
    final T? previous = _previous;
    _previous = value;
    return previous;
  }
}
