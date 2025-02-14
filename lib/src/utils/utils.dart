typedef MapResult<T, R> = R Function(T key);

extension MapExt<T, R> on Map<T, R> {
  bool getBool(T key, {Function()? orElse}) {
    orElse ??= () => false;
    if (containsKey(key) && this[key] != null && this[key] is bool) {
      return this[key] as bool;
    } else {
      return orElse();
    }
  }

  String getString(T key, {Function()? orElse}) {
    orElse ??= () => "";
    if (containsKey(key) && this[key] != null && this[key] is String) {
      return this[key] as String;
    } else {
      return orElse();
    }
  }
}

extension DurationExtensions on Duration {
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

extension StringExt on String {
  String replaceCharacters(
      {List<String> chars = const [], String newChar = ""}) {
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
  R? firstWhereOrNull<R>(MapResult<T, R> mapper, {R? orElse}) {
    for (var element in this) {
      final result = mapper(element);
      if (result != null) {
        return result;
      }
    }
    return orElse;
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

class Pair<T, R> {
  final T first;
  final R second;

  const Pair(this.first, this.second);
}
