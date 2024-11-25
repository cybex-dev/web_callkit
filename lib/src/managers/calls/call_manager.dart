import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web_callkit/src/utils/utils.dart';

import '../../models/models.dart';

class CallManager {

  late StreamController<Iterable<CKCall>> _callStreamController;
  late StreamController<CallEvent> _eventStreamController;

  // singleton
  static final CallManager _instance = CallManager._internal();

  CallManager._internal() {
    _callStreamController = StreamController<Iterable<CKCall>>.broadcast();
    _eventStreamController = StreamController<CallEvent>.broadcast();
  }

  factory CallManager() => _instance;

  final Map<String, CKCall> _calls = {};

  Map<String, CKCall> get calls => _calls; // Get active call

  Stream<Iterable<CKCall>> get callStream => _callStreamController.stream;

  Stream<CallEvent> get eventStream => _eventStreamController.stream;

  CKCall? getCall(String uuid) {
    if(!_calls.containsKey(uuid)) {
      printDebug("Failed to get call with uuid: $uuid. Call not found.");
      return null;
    }

    return _calls[uuid];
  }

  CKCall updateCall(String uuid, CKCall data) {
    if(!_calls.containsKey(uuid)) {
      throw Exception("Call with uuid: $uuid not found.");
    }

    if(data.uuid != uuid) {
      throw Exception("Call uuid does not match provided uuid, uuid: $uuid.");
    }

    if(kDebugMode) {
      final difference = _calls[uuid]?.difference(data);
      printDebug(difference);
    }

    final update = _calls[uuid]!.update(data);
    _calls[uuid] = update;
    _addEvent(CallEvent.update(update));
    _updateStream();
    return update;
  }

  // Add call to call manager. If call already exists, it is updated.
  void addCall(CKCall call) {
    final uuid = call.uuid;
    if(_calls.containsKey(uuid)) {
      printDebug("Call with uuid: $uuid already exists. Updating call.");
      final update = _calls[uuid]!.update(call);
      _calls[uuid] = update;
      _addEvent(CallEvent.update(update));
    } else {
      printDebug("Adding call with uuid: $uuid.");
      _calls[uuid] = call;
      _addEvent(CallEvent.add(call));
    }

    _updateStream();
  }

  // Remove call from call manager
  void removeCall(String uuid) {
    if(!_calls.containsKey(uuid)) {
      return;
    }

    final call = _calls.remove(uuid);
    if(call != null) {
      _addEvent(CallEvent.remove(call));
    }
    _updateStream();
  }

  // Clear all calls
  void clearCalls() {
    _calls.clear();
    _updateStream();
  }

  void _updateStream() {
    _callStreamController.add(_calls.values);
  }

  void _addEvent(CallEvent event) {
    _eventStreamController.add(event);
  }
}
