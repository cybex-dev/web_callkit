extension SetExtensions<T> on Set<T> {
  Set<T> removeWith(T value) {
    return Set<T>.from(this)..remove(value);
  }

  Set<T> addWith(T value) {
    return Set<T>.from(this)..add(value);
  }
}