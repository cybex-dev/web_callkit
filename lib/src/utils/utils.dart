import 'package:flutter/foundation.dart';

void printDebug(dynamic message, [String? tag]) {
  if (kDebugMode) {
    String m = (tag != null) ? '[$tag] $message' : message;
    print(m);
  }
}

class Pair<T, R> {
  final T first;
  final R second;

  const Pair(this.first, this.second);
}