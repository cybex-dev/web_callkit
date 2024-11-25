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
  Future<void> incomingCall(
    String uuid,
    String handle, {
    Map<String, dynamic>? data,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> missedCall(String uuid, String callerId) => throw UnimplementedError();

  @override
  Future<void> outgoingCall(String uuid, String callerId, {
    Map<String, dynamic>? data,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
  }) => throw UnimplementedError();

  @override
  Future<void> onGoingCall(String uuid, String callerId, {
    Map<String, dynamic>? data,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
  }) => throw UnimplementedError();

  @override
  Future<void> dismiss(String uuid) => throw UnimplementedError();

  @override
  Future<void> dispose() => throw UnimplementedError();
}
