/// Represents a [Collection] wrapper.
abstract class Collector<E> {
  /// Returns the collection wrapped by this object.
  Collection<E> collect();
}

/// Represents a common interface between a stream and a list.
abstract class Collection<E> {
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
  final Stream<E> stream;

  const AsyncCollection(this.stream);

  @override
  Collection<R> cast<R>() => AsyncCollection(stream.cast<R>());

  @override
  Collection<R> expand<R>(Iterable<R> Function(E element) toElements) =>
      AsyncCollection(stream.expand(toElements));

  @override
  Collection<R> map<R>(R Function(E e) toElement) =>
      AsyncCollection(stream.map(toElement));

  @override
  Collection<E> skip(int count) => AsyncCollection(stream.skip(count));

  @override
  Collection<E> skipWhile(bool Function(E value) test) =>
      AsyncCollection(stream.skipWhile(test));

  @override
  Collection<E> take(int count) => AsyncCollection(stream.take(count));

  @override
  Collection<E> takeWhile(bool Function(E value) test) =>
      AsyncCollection(stream.takeWhile(test));

  @override
  Collection<E> where(bool Function(E element) test) =>
      AsyncCollection(stream.where(test));

  @override
  Collection<R> whereType<R>() =>
      AsyncCollection(stream.where((event) => event is R).cast<R>());
}

/// Represents a collection backed by a list.
class SyncCollection<E> extends Collection<E> {
  final List<E> list;

  const SyncCollection(this.list);

  @override
  Collection<R> cast<R>() => SyncCollection(list.cast<R>());

  @override
  Collection<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      SyncCollection(list.expand(toElements).toList());

  @override
  Collection<T> map<T>(T Function(E e) toElement) =>
      SyncCollection(list.map(toElement).toList());

  @override
  Collection<E> skip(int count) => SyncCollection(list.skip(count).toList());

  @override
  Collection<E> skipWhile(bool Function(E value) test) =>
      SyncCollection(list.skipWhile(test).toList());

  @override
  Collection<E> take(int count) => SyncCollection(list.take(count).toList());

  @override
  Collection<E> takeWhile(bool Function(E value) test) =>
      SyncCollection(list.takeWhile(test).toList());

  @override
  Collection<E> where(bool Function(E element) test) =>
      SyncCollection(list.where(test).toList());

  @override
  Collection<T> whereType<T>() => SyncCollection(list.whereType<T>().toList());
}
