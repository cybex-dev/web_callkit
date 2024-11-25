import 'dart:async';
import 'package:web_callkit/src/core/core.dart';
import 'package:web_callkit/src/models/models.dart';

abstract class NotificationManager {

  Stream<CKCallResult> get actionStream;

  Stream<CKCallResult> get dismissStream;

  NotificationManager get instance;

  Future<void> incomingCall(String uuid, String handle, {CallType callType = CallType.audio, bool holding = false, bool muted = false, bool enableMuteAction = false, bool enableHoldAction = false, bool hasVideoCapability = false, Map<String, dynamic>? data});

  Future<void> missedCall(String uuid, String callerId);

  Future<void> outgoingCall(String uuid, String callerId, {CallType callType = CallType.audio, bool holding = false, bool muted = false, bool enableMuteAction = false, bool enableHoldAction = false, bool hasVideoCapability = false, Map<String, dynamic>? data});

  Future<void> onGoingCall(String uuid, String callerId, {CallType callType = CallType.audio, bool holding = false, bool muted = false, bool enableMuteAction = false, bool enableHoldAction = false, bool hasVideoCapability = false, Map<String, dynamic>? data});

  Future<void> dismiss(String uuid);

  Future<void> dispose();
}
