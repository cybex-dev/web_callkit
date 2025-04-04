import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:simple_print/simple_print.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums/ck_call_event_type.dart';
import '../../core/enums/ck_call_state.dart';
import '../../core/enums/ck_disconnect_response.dart';
import '../../models/call/ck_call.dart';
import '../../models/call/ck_call_event.dart';

typedef OnCallUpdate = void Function(String uuid, CKCall update, CKCall current);

class CKLogEntry {
  final String id;
  final String uuid;
  final DateTime date;
  final CKCallState state;

  const CKLogEntry._internal(this.id, this.uuid, this.date, this.state);

  factory CKLogEntry.create(String uuid, DateTime date, CKCallState state) {
    final id = const Uuid().v4();
    return CKLogEntry._internal(id, uuid, date, state);
  }

  factory CKLogEntry.fromCall(CKCall call) {
    final id = const Uuid().v4();
    return CKLogEntry._internal(id, call.uuid, call.dateUpdated, call.state);
  }

  @override
  String toString() {
    return 'CKLogEntry{id: $id, uuid: $uuid, date: $date, state: $state}';
  }
}

/// CallManager manages all calls and call events, in essence a call registry. It is responsible for adding,
/// updating, and removing calls and publishes call events and current call registry via [callStream] and [eventStream].
class CallManager {
  static const tag = 'call_manager';

  Map<String, CKCall> get activeCalls {
    return Map.fromEntries(_calls.entries.where((e) => e.value.active));
  }

  OnCallUpdate? _onCallUpdate;
  void setOnCallUpdate(OnCallUpdate value) {
    _onCallUpdate = value;
  }

  final Map<String, CKCall> _calls = {};
  Map<String, CKCall> get calls => _calls;

  final Map<String, List<CKLogEntry>> _logs = {};
  Map<String, List<CKLogEntry>> get logs => _logs;

  // internal call stream
  late StreamSubscription<CKCallEvent> _callEventSubscription;

  // call & event streams
  late StreamController<Iterable<CKCall>> _callStreamController;

  Stream<Iterable<CKCall>> get callStream => _callStreamController.stream;

  late StreamController<CKCallEvent> _eventStreamController;

  Stream<CKCallEvent> get eventStream => _eventStreamController.stream;

  // singleton
  static final CallManager _instance = CallManager._internal();

  factory CallManager() => _instance;

  //region Public
  CallManager._internal() {
    _callStreamController = StreamController<Iterable<CKCall>>.broadcast();
    _eventStreamController = StreamController<CKCallEvent>.broadcast();

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
    final event = CKCallEvent.add(call);
    _addEvent(event);
  }

  /// update call in call manager if call exists, triggers update event
  void updateCall(CKCall call) {
    final uuid = call.uuid;
    if (!_calls.containsKey(uuid)) {
      printDebug("Failed to update call with uuid: $uuid. Call not found.", tag: tag);
      return;
    }

    if (kDebugMode) {
      final current = _calls[uuid];
      final difference = current?.difference(call);
      printDebug(difference, tag: tag);
    }

    final event = CKCallEvent.update(call);
    _addEvent(event);
  }

  /// remove call from call manager if call exists, triggers update event
  void removeCall(String uuid, {required CKDisconnectResponse response}) {
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
        case CKCallEventType.add:
          _addCall(event.call);
          break;
        case CKCallEventType.update:
          _updateCall(event.uuid, event.call);
          break;
        case CKCallEventType.remove:
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
  void _addEvent(CKCallEvent event) {
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
    _addLogEntry(call);
  }

  /// Update call in internal call map
  void _updateCall(String uuid, CKCall call) {
    if (!_calls.containsKey(uuid)) {
      throw Exception("Call with uuid: $uuid not found.");
    }
    final current = _calls[uuid]!;
    final updated = current.update(call).copyWith(dateUpdated: DateTime.now());
    _calls[uuid] = updated;
    _addLogEntry(updated);
    _onCallUpdate?.call(uuid, updated, current);
  }

  /// Remove call from internal call map
  void _removeCall(String uuid) {
    if (!_calls.containsKey(uuid)) {
      throw Exception("Failed to remove call with uuid: $uuid. Call not found.");
      // return;
    }
    _calls.remove(uuid);
    _clearLogEntries(uuid);
  }

  /// Check if there are any active calls, as defined by "active" call states in [_definesActiveCalls].
  bool get hasActiveCalls {
    return calls.values.any((event) => event.active);
  }

  void _addLogEntry(CKCall call) {
    final log = CKLogEntry.fromCall(call);
    printDebug("$tag: $log", tag: "LOG:");
    _logs.putIfAbsent(call.uuid, () => []).add(log);
  }

  void _clearLogEntries(String uuid) {
    printDebug("$tag: Clearing log entries for call with uuid: $uuid", tag: "LOG:");
    if (_logs.containsKey(uuid)) {
      _logs.remove(uuid);
    }
  }

//endregion
}
