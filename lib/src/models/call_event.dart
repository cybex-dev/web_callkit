import './models.dart';
import '../core/core.dart';

class CallEvent {
  final String uuid;
  final CallEventType type;
  final CKCall call;

  CallEvent(this.uuid, this.type, this.call);

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
    return 'CallEvent{uuid: $uuid, type: $type, call: $call}';
  }
}