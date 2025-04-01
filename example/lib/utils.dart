import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension SetExtensions<T> on Set<T> {
  Set<T> removeWith(T value) {
    return Set<T>.from(this)..remove(value);
  }

  Set<T> addWith(T value) {
    return Set<T>.from(this)..add(value);
  }

  Set<T> toggleWith(T value) {
    if (contains(value)) {
      return removeWith(value);
    } else {
      return addWith(value);
    }
  }

  bool equals(Set<T> other) {
    if (length != other.length) {
      return false;
    }
    for (var element in this) {
      if (!other.contains(element)) {
        return false;
      }
    }
    return true;
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

extension ListExtensions<T> on List<T> {
  List<T> sortWith([int Function(T a, T b)? compare]) {
    return List<T>.from(this)..sort(compare);
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }

    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> removeWith(K key) {
    return Map<K, V>.from(this)..remove(key);
  }

  Map<K, V> addWith(K key, V value) {
    return Map<K, V>.from(this)..[key] = value;
  }

  Map<K, V> where(bool Function(K key, V value) test) {
    return Map<K, V>.fromEntries(
        entries.where((entry) => test(entry.key, entry.value)));
  }

  Map<String, String> toStringMap() {
    final items = entries.map((entry) => MapEntry(entry.key.toString(), entry.value.toString()));
    if(items.length != length) {
      throw Exception("Failed to convert all items to string map");
    }
    return Map<String, String>.fromEntries(items);
  }
}

extension DateTimeExt on DateTime {
  String toTime({bool seconds = true}) {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}${seconds ? ":${second.toString().padLeft(2, '0')}" : ""}";
  }

  String getTimeDifference(DateTime other) {
    final difference = this.difference(other);
    // format hh:mm:ss
    return "${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}

void printDebug(dynamic message) {
  if (kDebugMode) {
    print(message);
  }
}

void pushPage(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
}
