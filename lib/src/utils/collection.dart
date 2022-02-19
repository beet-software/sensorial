/// Represents a [Collection] wrapper.
abstract class Collector<E> {
  /// Returns the collection wrapped by this object.
  Collection<E> collect();
}

/// Represents a common interface between a stream and a list.
abstract class Collection<E> {
  Object get value;

  const Collection();

  Collection<R> cast<R>();

  Collection<T> expand<T>(Iterable<T> Function(E element) toElements);

  Collection<T> map<T>(T Function(E e) toElement);

  Collection<E> skip(int count);

  Collection<E> skipWhile(bool Function(E value) test);

  Collection<E> take(int count);

  Collection<E> takeWhile(bool Function(E value) test);

  Collection<E> where(bool Function(E element) test);

  Collection<T> whereType<T>();
}

/// Represents a collection backed by a stream.
class AsyncCollection<E> extends Collection<E> {
  @override
  final Stream<E> value;

  const AsyncCollection(this.value);

  @override
  Collection<R> cast<R>() => AsyncCollection(value.cast<R>());

  @override
  Collection<R> expand<R>(Iterable<R> Function(E element) toElements) =>
      AsyncCollection(value.expand(toElements));

  @override
  Collection<R> map<R>(R Function(E e) toElement) =>
      AsyncCollection(value.map(toElement));

  @override
  Collection<E> skip(int count) => AsyncCollection(value.skip(count));

  @override
  Collection<E> skipWhile(bool Function(E value) test) =>
      AsyncCollection(value.skipWhile(test));

  @override
  Collection<E> take(int count) => AsyncCollection(value.take(count));

  @override
  Collection<E> takeWhile(bool Function(E value) test) =>
      AsyncCollection(value.takeWhile(test));

  @override
  Collection<E> where(bool Function(E element) test) =>
      AsyncCollection(value.where(test));

  @override
  Collection<R> whereType<R>() =>
      AsyncCollection(value.where((event) => event is R).cast<R>());
}

/// Represents a collection backed by a list.
class SyncCollection<E> extends Collection<E> {
  @override
  final List<E> value;

  const SyncCollection(this.value);

  @override
  Collection<R> cast<R>() => SyncCollection(value.cast<R>());

  @override
  Collection<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      SyncCollection(value.expand(toElements).toList());

  @override
  Collection<T> map<T>(T Function(E e) toElement) =>
      SyncCollection(value.map(toElement).toList());

  @override
  Collection<E> skip(int count) => SyncCollection(value.skip(count).toList());

  @override
  Collection<E> skipWhile(bool Function(E value) test) =>
      SyncCollection(value.skipWhile(test).toList());

  @override
  Collection<E> take(int count) => SyncCollection(value.take(count).toList());

  @override
  Collection<E> takeWhile(bool Function(E value) test) =>
      SyncCollection(value.takeWhile(test).toList());

  @override
  Collection<E> where(bool Function(E element) test) =>
      SyncCollection(value.where(test).toList());

  @override
  Collection<T> whereType<T>() => SyncCollection(value.whereType<T>().toList());
}
