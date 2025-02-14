import 'dart:async';

import 'package:web_callkit/src/models/ck_notification_action.dart';
import 'package:web_callkit/src/models/models.dart';

import '../../core/core.dart';

typedef CallProvider = CKCall? Function(String uuid);

class NotificationManagerOptions {
  final bool enableMuteAction;
  final bool enableHoldAction;

  const NotificationManagerOptions({
    this.enableMuteAction = false,
    this.enableHoldAction = false,
  });
}

abstract class NotificationManager {
  static const tag = 'notification_manager';

  // ignore: constant_identifier_names
  static const String CK_EXTRA_PERSIST = CALLKIT_PERSIST;

  Stream<CKCallResult> get actionStream;

  Stream<CKCallResult> get dismissStream;

  /// Notification tap interaction stream. Taps include clicking anywhere on the notification except the close, or
  /// [CKNotificationAction] buttons (except empty actions). Action buttons with an empty action will be treated as a tap.
  Stream<CKCallResult> get tapStream;

  /// Dispose of the notification manager, releasing resources & streams
  Future<void> dispose();

  /// Dismiss a notification by uuid
  Future<void> dismiss({required String uuid});

  /// Add a notification to the notification manager, overwriting existing an notification with the same [CKNotification.uuid]
  Future<void> add(CKNotification notification);

  /// Repost a notification by uuid
  Future<void> repost({required String uuid, bool silent = true});

  /// Create [CKNotification] from parameters and show an incoming call notification. A convenience wrapper
  /// for [NotificationManager.add].
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
    bool timer = true,
    CallState? timerStartOnState,
    CallProvider? onCallProvider,
  });

  Future<void> missedCall(
    String uuid, {
    required String callerId,
  });

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
    bool timer = true,
    CallState? timerStartOnState,
    CallProvider? onCallProvider,
  });

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
    bool timer = true,
    CallState? timerStartOnState,
    CallProvider? onCallProvider,
    CallState stateOverride = CallState.active,
  });

  Future<void> callEnded(
    String uuid, {
    required String callerId,
    CallType callType = CallType.audio,
    DateTime? startTime,
  });

  CKNotification? getNotification(String uuid);

  List<CKNotification> getAllNotifications();
}
