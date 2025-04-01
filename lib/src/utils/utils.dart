typedef MapResult<T, R> = R Function(T key);

extension MapExt<T, R> on Map<T, R> {
  bool getBool(T key, {Function()? orElse}) {
    orElse ??= () => false;
    if (containsKeyAndNotNull(key) && this[key] is bool) {
      return this[key] as bool;
    } else {
      return orElse();
    }
  }

  String getString(T key, {Function()? orElse}) {
    orElse ??= () => "";
    if (containsKeyAndNotNull(key) && this[key] is String) {
      return this[key] as String;
    } else {
      return orElse();
    }
  }

  /// Checks if the map contains the key and the value is not null.
  /// A convenience function for `Map.containsKey(key) && Map[key] != null`
  bool containsKeyAndNotNull(T key) {
    return containsKey(key) && this[key] != null;
  }
}

extension DurationExtensions on Duration {
  static String formatDuration(Duration duration, {bool includeHours = true, bool includeHoursIfZero = false}) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = "";
    if (includeHours && (includeHoursIfZero || duration.inHours > 0)) {
      hours = "${twoDigits(duration.inHours)}:";
    }
    final minutes = twoDigits(duration.inMinutes % 60);
    final seconds = twoDigits(duration.inSeconds % 60);
    return "$hours$minutes:$seconds";
  }

  String format({bool includeHours = true, bool includeHoursIfZero = false}) {
    return formatDuration(this, includeHours: includeHours, includeHoursIfZero: includeHoursIfZero);
  }
}

extension StringExt on String {
  String replaceCharacters({List<String> chars = const [], String newChar = ""}) {
    if (isEmpty || chars.isEmpty) {
      return this;
    }
    final pattern = chars.map((e) => RegExp.escape(e)).join('|');
    return replaceAll(RegExp(pattern), '');
  }

  String sanitizeEnum() {
    return replaceCharacters(chars: ['-', '_', ' '], newChar: '').toLowerCase();
  }

  String capitalize() {
    if (length == 0) return this;
    if (length == 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test, {T? orElse}) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return orElse;
  }
}

extension DateTimeExt on DateTime {
  String format({bool seconds = true}) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final s = seconds ? ":${second.toString().padLeft(2, '0')}" : "";
    return "$h:$m$s";
  }

  String getTimeDifference(DateTime other) {
    return difference(other).format();
  }
}

class Pair<T, R> {
  final T first;
  final R second;

  const Pair(this.first, this.second);
}
