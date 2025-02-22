import '../core/core.dart';
import './models.dart';

class CallEvent {
  late final DateTime timestamp;
  final String uuid;
  final CallEventType type;
  final CKCall call;

  CallEvent(this.uuid, this.type, this.call) {
    timestamp = DateTime.now();
  }

  factory CallEvent.add(CKCall call) {
    return CallEvent(call.uuid, CallEventType.add, call);
  }

  factory CallEvent.update(CKCall call) {
    return CallEvent(call.uuid, CallEventType.update, call);
  }

  factory CallEvent.remove(CKCall call) {
    return CallEvent(call.uuid, CallEventType.remove, call);
  }

  @override
  String toString() {
    return '${type.symbol} CallEvent{uuid: $uuid, type: $type, call: $call, date: $timestamp}';
  }
}

class DisconnectCallEvent extends CallEvent {
  final DisconnectResponse response;

  DisconnectCallEvent(String uuid, CKCall call, {required this.response}): super(uuid, CallEventType.remove, call);

  factory DisconnectCallEvent.reason(CKCall call, {DisconnectResponse response = DisconnectResponse.local}) {
    return DisconnectCallEvent(call.uuid, call, response: response);
  }

  @override
  String toString() {
    return '${type.symbol} DisconnectCallEvent{uuid: $uuid, type: $type, call: $call, response: $response, date: $timestamp}';
  }
}
