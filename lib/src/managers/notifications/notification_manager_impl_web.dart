import 'dart:async';

import 'package:js_notifications/interop/interop.dart';
import 'package:js_notifications/platform_interface/js_notifications_platform_interface.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'notification_manager.dart';
import 'notification_manager_impl.dart';

class CKNotification {
  final JSNotification notification;
  final Map<String, dynamic> data;

  const CKNotification(this.notification, this.data);

  const CKNotification.simple(this.notification) : data = const {};
}

class NotificationManagerOptions {
  final bool enableMuteAction;
  final bool enableHoldAction;

  const NotificationManagerOptions({
    this.enableMuteAction = false,
    this.enableHoldAction = false,
  });
}

class NotificationManagerImplWeb extends NotificationManagerImpl {
  final Map<String, CKNotification> _notifications = {};

  final String CALLKIT_PERSIST = "ck_persist";

  final jsNotifications = JsNotificationsPlatform.instance;

  late final StreamSubscription<CKCallResult> _actionStreamSubscription;
  late final StreamSubscription<CKCallResult> _dismissStreamSubscription;

  static final NotificationManager _instance = NotificationManagerImplWeb._internal();

  @override
  NotificationManager get instance => _instance;

  // Private named constructor
  NotificationManagerImplWeb._internal() : super.protected() {
    _setupRefreshStream();
  }

  /// Stream to listen for action or dismiss stream events, reposts/refreshes notifications unless a dismiss/cancel action is received
  void _setupRefreshStream() {
    _actionStreamSubscription = actionStream.listen((event) {
      printDebug("Action Stream: ${event.action}");
      switch (event.action) {
        case CKCallAction.dismiss:
          dismiss(event.uuid);
          break;
        case CKCallAction.none:
        default:
          if (event.data.containsKey(CALLKIT_PERSIST) && event.data[CALLKIT_PERSIST] == true) {
            _getNotificationAndRepost(event.uuid);
          }
          break;
      }
    });

    _dismissStreamSubscription = dismissStream.listen((event) {
      printDebug("Dismissed notification: ${event.uuid}");
    });
  }

  factory NotificationManagerImplWeb() => NotificationManagerImplWeb._internal();

  @override
  Stream<CKCallResult> get actionStream => jsNotifications.actionStream.map(CKCallResult.fromResult);

  @override
  Stream<CKCallResult> get dismissStream => jsNotifications.dismissStream.map(CKCallResult.fromResult);

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
  }) {
    final ckData = {
      if (data != null) ...data,
      CALLKIT_PERSIST: true,
    };
    final options = JSNotificationOptions(
      tag: uuid,
      body: 'Incoming Call',
      requireInteraction: true,
      data: ckData,
      actions: [
        JSNotificationAction.fromAction('answer'),
        JSNotificationAction.fromAction('decline'),
        if (hasVideoCapability)
          if (callType == CallType.audio)
            const JSNotificationAction(title: "Switch to Video", action: "switch-video")
          else
            const JSNotificationAction(title: "Switch to Audio", action: "switch-audio"),
        if (enableMuteAction) JSNotificationAction.fromAction('mute'),
        if (enableHoldAction) JSNotificationAction.fromAction('hold'),
      ],
    );
    final jsNotification = JSNotification(handle, options);
    return _addNotification(uuid, jsNotification);
  }

  @override
  Future<void> missedCall(String uuid, String callerId) {
    final options = JSNotificationOptions(
      tag: uuid,
      body: "Missed Call",
      actions: [
        JSNotificationAction.fromAction('dismiss'),
        JSNotificationAction.fromAction('callback'),
      ],
    );
    final notification = JSNotification(callerId, options);
    return _addNotification(uuid, notification);
  }

  @override
  Future<void> outgoingCall(String uuid, String callerId, {
    Map<String, dynamic>? data,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
  }) {
    final options = JSNotificationOptions(
      tag: uuid,
      body: "Outgoing Call",
      actions: [
        const JSNotificationAction(title: 'Hang Up', action: 'hangup'),
        if (hasVideoCapability)
          if (callType == CallType.audio)
            const JSNotificationAction(title: "Switch to Video", action: "switch-video")
          else
            const JSNotificationAction(title: "Switch to Audio", action: "switch-audio"),
        if (enableMuteAction) JSNotificationAction.fromAction('mute'),
        if (enableHoldAction) JSNotificationAction.fromAction('hold'),
      ],
    );
    final notification = JSNotification(callerId, options);
    return _addNotification(uuid, notification);
  }

  @override
  Future<void> onGoingCall(String uuid, String callerId, {
    Map<String, dynamic>? data,
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    bool enableMuteAction = false,
    bool enableHoldAction = false,
    bool hasVideoCapability = false,
  }) {
    final options = JSNotificationOptions(
      tag: uuid,
      body: "On Call",
      actions: [
        const JSNotificationAction(title: 'Hang Up', action: 'hangup'),
        if (hasVideoCapability)
          if (callType == CallType.audio)
            const JSNotificationAction(title: "Switch to Video", action: "switch-video")
          else
            const JSNotificationAction(title: "Switch to Audio", action: "switch-audio"),
        if (enableMuteAction) JSNotificationAction.fromAction('mute'),
        if (enableHoldAction) JSNotificationAction.fromAction('hold'),
      ],
    );
    final notification = JSNotification(callerId, options);
    return _addNotification(uuid, notification);
  }

  @override
  Future<void> dismiss(String uuid) {
    final notification = _notifications.remove(uuid);
    if (notification == null) {
      printDebug("Notification with id $uuid not found");
    }
    return jsNotifications.dismissNotification(id: uuid);
  }

  void _getNotificationAndRepost(String uuid) {
    final notification = _notifications[uuid];
    if (notification != null) {
      printDebug("Reposting notification for $uuid");
      _addNotification(uuid, notification.notification);
    }
  }

  Future<void> _addNotification(String id, JSNotification notification) {
    _notifications[id] = CKNotification.simple(notification);
    return jsNotifications.addNotification(notification);
  }

  @override
  Future<void> dispose() async {
    final streams = [
      _actionStreamSubscription.cancel(),
      _dismissStreamSubscription.cancel(),
    ];
    await Future.wait(streams);
  }
}
