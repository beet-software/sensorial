import 'dart:async';

/// Transforming operation that produces at least one value for each original value.
///
/// ```dart
/// class StringTransforming extends TransformingFunction<int, String> {
///   @override
///   Iterable<String> onValue(int value) sync* {
///     yield value.toString();
///   }
/// }
///
/// void main() async {
///   final Stream<int> stream = Stream
///     .fromIterable([1, 7, 2, 5])
///     .transform(StringTransforming());
///
///   final List<String> values = await stream.toList();
///   print(values);   // ["1", "7", "2", "5"]
/// }
/// ```
abstract class TransformingFunction<I, O> extends StreamTransformerBase<I, O> {
  StreamSubscription<I>? _subscription;
  Stream<I>? _stream;

  late final StreamController<O> _controller;

  TransformingFunction() {
    _controller = StreamController<O>.broadcast(
      onListen: () {
        final Stream<I>? stream = _stream;
        if (stream == null) return;
        _subscription = stream.listen(
          (data) => onValue(data).forEach(_controller.add),
          onError: _controller.addError,
          onDone: _controller.close,
          cancelOnError: true,
        );
      },
      onCancel: () {
        _subscription?.cancel();
        _subscription = null;
      },
    );
  }

  @override
  Stream<O> bind(Stream<I> stream) {
    _stream = stream;
    return _controller.stream;
  }

  Iterable<O> onValue(I value);
}

/// Transforming operation that produces at least one value as the same type as the original value.
///
/// ```dart
/// class PlusOneTransforming extends TransformingUnaryOperator<int> {
///   @override
///   Iterable<int> onValue(int value) sync* {
///     yield value;
///     yield value + 1;
///   }
/// }
///
/// void main() async {
///   final Stream<int> stream = Stream
///     .fromIterable([1, 7, 2, 5])
///     .transform(PlusOneTransforming());
///
///   final List<String> values = await stream.toList();
///   print(values);   // [1, 2, 7, 8, 2, 3, 5, 6]
/// }
/// ```
abstract class TransformingUnaryOperator<T> extends TransformingFunction<T, T> {
}

/// Transforming operation that produces the original value unchanged, executing
/// a given additional action.
///
/// ```dart
/// class PrintConsumer extends TransformingConsumer<int> {
///   @override
///   void onAction(int value) {
///     print("New value: ${value}");
///   }
/// }
///
/// void main() async {
///   final Stream<int> stream = Stream
///     .fromIterable([1, 7, 2, 5])
///     .transform(PrintConsumer());
///
///   final List<String> values = await stream.toList();
///   // New value: 1
///   // New value: 7
///   // New value: 2
///   // New value: 5
///   print(values);   // [1, 7, 2, 5]
/// }
/// ```
abstract class TransformingConsumer<T> extends TransformingUnaryOperator<T> {
  @override
  Iterable<T> onValue(T value) sync* {
    onAction(value);
    yield value;
  }

  void onAction(T value);
}
