import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:simple_print/simple_print.dart';

import '../../core/core.dart';
import '../../models/models.dart';

/// CallManager manages all calls and call events, in essence a call registry. It is responsible for adding,
/// updating, and removing calls and publishes call events and current call registry via [callStream] and [eventStream].
class CallManager {
  static const tag = 'call_manager';

  /// List of call states that are considered active.
  final _definesActiveCalls = [
    CallState.initiated,
    CallState.ringing,
    CallState.dialing,
    CallState.active,
    CallState.reconnecting,
    CallState.disconnecting,
    CallState.disconnected,
  ];

  // internal call map
  final Map<String, CKCall> _calls = {};

  Map<String, CKCall> get calls => _calls;

  // internal call stream
  late StreamSubscription<CallEvent> _callEventSubscription;

  // call & event streams
  late StreamController<Iterable<CKCall>> _callStreamController;

  Stream<Iterable<CKCall>> get callStream => _callStreamController.stream;

  late StreamController<CallEvent> _eventStreamController;

  Stream<CallEvent> get eventStream => _eventStreamController.stream;

  // singleton
  static final CallManager _instance = CallManager._internal();

  factory CallManager() => _instance;

  //region Public
  CallManager._internal() {
    _callStreamController = StreamController<Iterable<CKCall>>.broadcast();
    _eventStreamController = StreamController<CallEvent>.broadcast();

    _setupStreamListeners();
  }

  /// get call by uuid
  CKCall? getCall(String uuid) {
    if (!_calls.containsKey(uuid)) {
      printDebug("Failed to get call with uuid: $uuid. Call not found.",
          tag: tag);
      return null;
    }

    return _calls[uuid];
  }

  /// Add call to call manager, triggers add event
  void addCall(CKCall call) {
    final event = CallEvent.add(call);
    _addEvent(event);
  }

  /// update call in call manager if call exists, triggers update event
  void updateCall(CKCall call) {
    final uuid = call.uuid;
    if (!_calls.containsKey(uuid)) {
      throw Exception("Call with uuid: $uuid not found.");
    }

    if (kDebugMode) {
      final current = _calls[uuid];
      final difference = current?.difference(call);
      printDebug(difference, tag: tag);
    }

    final event = CallEvent.update(call);
    _addEvent(event);
  }

  /// remove call from call manager if call exists, triggers update event
  void removeCall(String uuid, {required DisconnectResponse response}) {
    final call = _calls.remove(uuid);
    if (call == null) {
      printDebug("Failed to remove call with uuid: $uuid. Call not found.",
          tag: tag);
      return;
    }

    final event = DisconnectCallEvent.reason(call, response: response);
    _addEvent(event);
  }

  /// clear all calls and update stream
  void clearCalls() {
    _calls.clear();
    _updateStream();
  }

  /// dispose call manager
  void dispose() {
    _callEventSubscription.cancel();
  }

  //endregion

  //region Private
  void _setupStreamListeners() {
    /// listen to call events, update internal call map and current call stream accordingly.
    _callEventSubscription = eventStream.listen((event) {
      // handle call events and update internal call map
      switch (event.type) {
        case CallEventType.add:
          _addCall(event.call);
          break;
        case CallEventType.update:
          _updateCall(event.uuid, event.call);
          break;
        case CallEventType.remove:
          _removeCall(event.uuid);
          break;
      }

      // Update call stream
      _updateStream();
    });
  }

  /// update call stream with current call map
  void _updateStream() {
    _callStreamController.add(_calls.values);
  }

  /// add call event to event stream
  void _addEvent(CallEvent event) {
    _eventStreamController.add(event);
  }

  /// Add call to internal call map
  void _addCall(CKCall call) {
    if (_calls.containsKey(call.uuid)) {
      final existing = _calls[call.uuid];
      if (existing != null) {
        printDebug(
            "Call with uuid: ${call.uuid} already exists. Updating call instead.",
            tag: tag);
        updateCall(call);
        return;
      } else {
        printDebug(
            "Call with uuid: ${call.uuid} already exists but existing call is null.",
            tag: tag);
      }
    }
    _calls[call.uuid] = call;
  }

  /// Update call in internal call map
  void _updateCall(String uuid, CKCall call) {
    if (!_calls.containsKey(uuid)) {
      throw Exception("Call with uuid: $uuid not found.");
    }
    final current = _calls[uuid]!;
    final updated = current.update(call).copyWith(dateUpdated: DateTime.now());
    _calls[uuid] = updated;
  }

  /// Remove call from internal call map
  void _removeCall(String uuid) {
    if (!_calls.containsKey(uuid)) {
      printDebug("Failed to remove call with uuid: $uuid. Call not found.",
          tag: tag);
      // return;
    }
    _calls.remove(uuid);
  }

  /// Check if there are any active calls, as defined by "active" call states in [_definesActiveCalls].
  bool get hasActiveCalls {
    return calls.values
        .map((event) => event.state)
        .any((event) => _definesActiveCalls.contains(event));
  }

//endregion
}
