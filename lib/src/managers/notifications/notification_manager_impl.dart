import '../../core/core.dart';
import '../../models/models.dart';
import 'notification_manager.dart';

class NotificationManagerImpl implements NotificationManager {
  static final NotificationManager _instance = NotificationManagerImpl._internal();

  @override
  NotificationManager get instance => _instance;

  // Private named constructor
  NotificationManagerImpl._internal();

  factory NotificationManagerImpl() => NotificationManagerImpl._internal();

  // Protected internal constructor for subclasses to access
  NotificationManagerImpl.protected() : this._internal();

  @override
  Stream<CKCallResult> get actionStream => throw UnimplementedError();

  @override
  Stream<CKCallResult> get dismissStream => throw UnimplementedError();

  @override
  Stream<CKCallResult> get tapStream => throw UnimplementedError();

  @override
  Future<void> dismiss({required String uuid}) => throw UnimplementedError();

  @override
  Future<void> dispose() => throw UnimplementedError();

  @override
  Future<void> add(CKNotification notification) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> callEnded(String uuid, {required String callerId, CallType callType = CallType.audio, DateTime? startTime}) {
    // TODO: implement callEnded
    throw UnimplementedError();
  }

  @override
  List<CKNotification> getAllNotifications() {
    // TODO: implement getAllNotifications
    throw UnimplementedError();
  }

  @override
  CKNotification? getNotification(String uuid) {
    // TODO: implement getNotification
    throw UnimplementedError();
  }

  @override
  Future<void> incomingCall(
    String uuid, {
    required String callerId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
    bool requireInteraction = true,
    CallProvider? onCallProvider,
    bool timer = true,
    CallState? timerStartOnState,
  }) {
    // TODO: implement incomingCall
    throw UnimplementedError();
  }

  @override
  Future<void> missedCall(String uuid, {required String callerId}) {
    // TODO: implement missedCall
    throw UnimplementedError();
  }

  @override
  Future<void> onGoingCall(
    String uuid, {
    required String callerId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
    CallProvider? onCallProvider,
    CallState stateOverride = CallState.active,
    bool timer = true,
    CallState? timerStartOnState,
  }) {
    // TODO: implement onGoingCall
    throw UnimplementedError();
  }

  @override
  Future<void> outgoingCall(
    String uuid, {
    required String callerId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
    CallProvider? onCallProvider,
    bool timer = true,
    CallState? timerStartOnState,
  }) {
    // TODO: implement outgoingCall
    throw UnimplementedError();
  }

  @override
  Future<void> repost({required String uuid, bool silent = true}) {
    // TODO: implement repost
    throw UnimplementedError();
  }
}
