import 'dart:async';

import 'package:simple_print/simple_print.dart';

typedef OnTimerTick = void Function(int tick);

class CallTimer {
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  StopwatchState _state = StopwatchState.stopped;
  OnTimerTick? _onTick;
  static const secondDuration = Duration(seconds: 1);

  CallTimer({Duration elapsed = Duration.zero, OnTimerTick? onTimerTick})
      : _elapsed = elapsed,
        _onTick = onTimerTick;

  /// Start the stopwatch if it is stopped.
  void start() {
    if (_state == StopwatchState.running) {
      printDebug("Stopwatch is already running.");
      return;
    }
    _state = StopwatchState.running;
    _startTimer();
    // Notify the initial elapsed time
    _onTick?.call(0);
  }

  /// Stop the stopwatch and reset the elapsed time.
  void stop() {
    if (_state == StopwatchState.stopped) {
      printDebug("Stopwatch is already stopped.");
      return;
    }
    _state = StopwatchState.stopped;
    _elapsed = Duration.zero;
    _stopTimer();
  }

  /// Pause the stopwatch if it is running.
  void pause() {
    if (_state == StopwatchState.paused) {
      printDebug("Stopwatch is already paused.");
      return;
    }
    if (_state == StopwatchState.running) {
      _stopTimer();
      _state = StopwatchState.paused;
    } else {
      printDebug("Stopwatch is not running.");
    }
  }

  /// Resume the stopwatch if it is paused.
  void resume() {
    if (_state == StopwatchState.paused) {
      _state = StopwatchState.running;
      _startTimer();
    } else {
      printDebug("Stopwatch is not paused.");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(secondDuration, _tick);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Get the current state of the stopwatch.
  StopwatchState get state => _state;

  /// Get the elapsed time.
  Duration get elapsed => _elapsed;

  /// Describe the elapsed time in the format HH:MM:SS.
  String describe() {
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  void _tick(Timer timer) {
    _elapsed += const Duration(seconds: 1);
    _onTick?.call(_elapsed.inSeconds);
  }

  void setOnTick(OnTimerTick? value) {
    _onTick = value;
  }
}

enum StopwatchState {
  stopped,
  running,
  paused,
}
