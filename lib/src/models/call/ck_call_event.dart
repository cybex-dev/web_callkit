import '../../core/enums/ck_call_event_type.dart';
import '../../core/enums/ck_disconnect_response.dart';
import 'ck_call.dart';

class CKCallEvent {
  late final DateTime timestamp;
  final String uuid;
  final CKCallEventType type;
  final CKCall call;

  CKCallEvent(this.uuid, this.type, this.call) {
    timestamp = DateTime.now();
  }

  factory CKCallEvent.add(CKCall call) {
    return CKCallEvent(call.uuid, CKCallEventType.add, call);
  }

  factory CKCallEvent.update(CKCall call) {
    return CKCallEvent(call.uuid, CKCallEventType.update, call);
  }

  factory CKCallEvent.remove(CKCall call) {
    return CKCallEvent(call.uuid, CKCallEventType.remove, call);
  }

  @override
  String toString() {
    return '${type.symbol} CallEvent{uuid: $uuid, type: $type, call: $call, date: $timestamp}';
  }
}

class DisconnectCallEvent extends CKCallEvent {
  final CKDisconnectResponse response;

  DisconnectCallEvent(String uuid, CKCall call, {required this.response}): super(uuid, CKCallEventType.remove, call);

  factory DisconnectCallEvent.reason(CKCall call, {CKDisconnectResponse response = CKDisconnectResponse.local}) {
    return DisconnectCallEvent(call.uuid, call, response: response);
  }

  @override
  String toString() {
    return '${type.symbol} DisconnectCallEvent{uuid: $uuid, type: $type, call: $call, response: $response, date: $timestamp}';
  }
}
