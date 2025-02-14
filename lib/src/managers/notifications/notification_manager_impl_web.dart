import 'dart:async';

import 'package:js_notifications/interop/interop.dart';
import 'package:js_notifications/platform_interface/js_notifications_platform_interface.dart';
import 'package:simple_print/simple_print.dart';
import 'package:web_callkit/src/managers/managers.dart';
import 'package:web_callkit/src/models/ck_notification_action.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../call_timer.dart';

class NotificationManagerImplWeb extends NotificationManagerImpl {
  /// Internal notification registry
  final Map<String, CKNotification> _notifications = {};

  // [JsNotificationsPlatform] action streams
  Stream<CKCallResult>? _actionStream;
  Stream<CKCallResult>? _dismissStream;
  Stream<CKCallResult>? _tapStream;

  /// Internal notification timers
  final Map<String, CallTimer> _notificationTimers = {};

  static final NotificationManager _instance =
      NotificationManagerImplWeb._internal();

  @override
  NotificationManager get instance => _instance;

  // Private named constructor
  NotificationManagerImplWeb._internal() : super.protected() {
    _setupRefreshStream();
  }

  factory NotificationManagerImplWeb() =>
      NotificationManagerImplWeb._internal();

  @override
  Stream<CKCallResult> get actionStream {
    _actionStream ??= jsNotifications.actionStream
        .map(CKCallResult.fromResult)
        .asBroadcastStream();
    return _actionStream!;
  }

  @override
  Stream<CKCallResult> get dismissStream {
    _dismissStream ??= jsNotifications.dismissStream
        .map(CKCallResult.fromResult)
        .asBroadcastStream();
    return _dismissStream!;
  }

  @override
  Stream<CKCallResult> get tapStream {
    _tapStream ??= jsNotifications.tapStream
        .map(CKCallResult.fromResult)
        .asBroadcastStream();
    return _tapStream!;
  }

  final jsNotifications = JsNotificationsPlatform.instance;

  StreamSubscription<CKCallResult>? _tapStreamSubscription;
  StreamSubscription<CKCallResult>? _actionStreamSubscription;
  StreamSubscription<CKCallResult>? _dismissStreamSubscription;

  /// Dismiss stream override, handle
  // late final StreamController<CKCallResult> _dismissStreamController;

  /// Stream to listen for action or dismiss stream events, reposts/refreshes notifications unless a dismiss/cancel action is received
  void _setupRefreshStream() {
    _actionStreamSubscription = actionStream.listen((event) {
      printDebug("Action Stream: ${event.action}",
          tag: NotificationManager.tag);
      switch (event.action) {
        case CKCallAction.dismiss:
          // dismiss(uuid: event.uuid);
          break;
        default:
          final persist =
              event.containsFlag(NotificationManager.CK_EXTRA_PERSIST, false);
          printDebug("Unhandled action: ${event.action}, persist: $persist");
          // if (persist) {
          //   switch (event.action) {
          //     case CKCallAction.answer:
          //     case CKCallAction.decline:
          //     case CKCallAction.hangUp:
          //       break;
          //     default:
          //       print("Unknown call action: ${event.action}");
          //       // dismiss(uuid: event.uuid);
          //       break;
          //   }
          // }
          break;
      }
    });

    // _dismissStreamSubscription = dismissStream.listen((event) {
    //   printDebug("Dismissed notification: ${event.uuid}", NotificationManager.tag);
    //   final persist = event.data.getBool(NotificationManager.CK_EXTRA_PERSIST, orElse: () => false);
    //   if (persist) {
    //     _getNotificationAndRepost(event.uuid);
    //   } else {
    //     _notifications.remove(event.uuid);
    //   }
    // });

    _tapStreamSubscription = tapStream.listen((event) {
      printDebug("Tapped notification: ${event.uuid}",
          tag: NotificationManager.tag);
    });
  }

  void _onTimerTick(String uuid, int tick, CallProvider callProvider,
      {CallState? startOn}) {
    CKNotification? ckNotification = _notifications[uuid];
    if (ckNotification == null) {
      return;
    }

    final call = callProvider(uuid);
    if (call == null) {
      return;
    }

    if (call.state != (startOn ?? CallState.active)) {
      return;
    }

    final state = call.state;
    final muted = call.isMuted;
    final holding = call.isHolding;
    final desc = _getCallDescription(state,
        callType: call.callType,
        timestamp: call.dateStarted,
        muted: muted,
        holding: holding);

    final current = ckNotification.notification;
    final updated = current.copyWith(
      options: current.options?.copyWith(
        body: desc,
      ),
    );

    _updateNotification(ckNotification.copyWith(notification: updated));
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
    bool timer = true,
    CallState? timerStartOnState,
    CallProvider? onCallProvider,
  }) async {
    final ckData = {
      if (data != null) ...data,
      NotificationManager.CK_EXTRA_PERSIST: true,
    };

    // TODO - refactor hardcoded CallState here
    final options = JSNotificationOptions(
      tag: uuid,
      body: _getCallDescription(CallState.ringing, callType: callType),
      requireInteraction: requireInteraction,
      data: ckData,
      actions: [
        JSNotificationAction.fromAction('answer'),
        JSNotificationAction.fromAction('decline'),
        if (hasVideoCapability)
          if (callType == CallType.audio)
            const JSNotificationAction(
                title: "Switch to Video", action: "switch-video")
          else
            const JSNotificationAction(
                title: "Switch to Audio", action: "switch-audio"),
        if (enableMuteAction) JSNotificationAction.fromAction('mute'),
        if (enableHoldAction) JSNotificationAction.fromAction('hold'),
      ],
    );
    final jsNotification = JSNotification(callerId, options);
    await _addNotification(uuid, jsNotification, metadata: metadata);

    if (onCallProvider != null && timer) {
      _addAndStartCallTimer(
        uuid: uuid,
        onTimerTick: (tick) => _onTimerTick(uuid, tick, onCallProvider,
            startOn: timerStartOnState),
      );
    }
  }

  @override
  Future<void> missedCall(String uuid, {required String callerId}) async {
    // TODO missed call - get call type
    final options = JSNotificationOptions(
      tag: uuid,
      body: "Missed Call",
      actions: [
        JSNotificationAction.fromAction('dismiss'),
        JSNotificationAction.fromAction('callback'),
      ],
    );
    final notification = JSNotification(callerId, options);
    await _addNotification(uuid, notification);
  }

  void _addAndStartCallTimer({
    required String uuid,
    required OnTimerTick onTimerTick,
    DateTime? startTime,
  }) {
    Duration elapsed = Duration.zero;
    if (startTime != null && startTime.isBefore(DateTime.now())) {
      elapsed = DateTime.now().difference(startTime);
    }
    if (_notificationTimers.containsKey(uuid) &&
        _notificationTimers[uuid] != null) {
      final timer = _notificationTimers[uuid]!;
      timer.setOnTick(onTimerTick);
      timer.start();
    } else {
      _notificationTimers[uuid] =
          CallTimer(elapsed: elapsed, onTimerTick: onTimerTick)..start();
    }
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
    bool timer = true,
    CallState? timerStartOnState,
    DateTime? startTime,
    CallProvider? onCallProvider,
  }) async {
    final ckData = {
      if (data != null) ...data,
      NotificationManager.CK_EXTRA_PERSIST: true,
    };
    final options = JSNotificationOptions(
      tag: uuid,
      body: _getCallDescription(CallState.initiated, callType: callType),
      requireInteraction: true,
      data: ckData,
      actions: [
        const JSNotificationAction(title: 'Hang Up', action: 'hangup'),
        if (hasVideoCapability)
          if (callType == CallType.audio)
            const JSNotificationAction(
                title: "Switch to Video", action: "switch-video")
          else
            const JSNotificationAction(
                title: "Switch to Audio", action: "switch-audio"),
        if (enableMuteAction) JSNotificationAction.fromAction('mute'),
        if (enableHoldAction) JSNotificationAction.fromAction('hold'),
      ],
    );
    final notification = JSNotification(callerId, options);
    await _addNotification(uuid, notification);

    if (onCallProvider != null && timer) {
      _addAndStartCallTimer(
        uuid: uuid,
        onTimerTick: (tick) => _onTimerTick(uuid, tick, onCallProvider,
            startOn: timerStartOnState),
      );
    }
  }

  @override
  Future<void> dismiss({required String uuid}) {
    final notification = _notifications.remove(uuid);
    if (notification == null) {
      printDebug("Notification with id $uuid not found",
          tag: NotificationManager.tag);
    }
    return jsNotifications.dismissNotification(id: uuid);
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
    bool timer = true,
    CallState? timerStartOnState,
    CallProvider? onCallProvider,
    CallState stateOverride = CallState.active,
  }) async {
    final ckData = {
      if (data != null) ...data,
      CALLKIT_PERSIST: true,
    };

    final current = _notifications[uuid];
    final options = JSNotificationOptions(
      tag: uuid,
      body: _getCallDescription(stateOverride,
          callType: callType, holding: holding, muted: muted),
      requireInteraction: true,
      data: ckData,
      actions: [
        CKNotificationAction.fromNotificationAction(CKCallAction.hangUp),
        if (hasVideoCapability)
          if (callType == CallType.audio)
            CKNotificationAction.fromNotificationAction(
                CKCallAction.switchVideo)
          else
            CKNotificationAction.fromNotificationAction(
                CKCallAction.switchAudio),
        if (enableMuteAction)
          CKNotificationAction.fromNotificationAction(CKCallAction.mute),
        if (enableHoldAction)
          CKNotificationAction.fromNotificationAction(CKCallAction.hold),
      ],
    );

    JSNotification notification = current != null
        ? current.notification.copyWith(options: options)
        : JSNotification(callerId, options);
    await _addNotification(uuid, notification, metadata: metadata);

    if (onCallProvider != null && timer) {
      _addAndStartCallTimer(
        uuid: uuid,
        onTimerTick: (tick) => _onTimerTick(uuid, tick, onCallProvider,
            startOn: timerStartOnState),
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _actionStreamSubscription?.cancel();
    await _dismissStreamSubscription?.cancel();
    await _tapStreamSubscription?.cancel();
  }

  @override
  Future<void> callEnded(
    String uuid, {
    required String callerId,
    CallType callType = CallType.audio,
    DateTime? startTime,
  }) {
    final options = JSNotificationOptions(
      tag: uuid,
      body: _getCallDescription(CallState.disconnected, callType: callType),
      actions: [
        CKNotificationAction.fromNotificationAction(CKCallAction.dismiss),
      ],
    );

    JSNotification notification = JSNotification(callerId, options);
    return _addNotification(uuid, notification);
  }

  // ignore: unused_element
  void _getNotificationAndRepost(String uuid) {
    final notification = _notifications[uuid];
    if (notification != null) {
      printDebug("Reposting notification for $uuid",
          tag: NotificationManager.tag);
      _addNotification(uuid, notification.notification);
    }
  }

  Future<CKNotification> _addNotification(
      String id, JSNotification notification,
      {Map<String, dynamic>? metadata}) async {
    final n =
        CKNotification.simple(id, notification).copyWith(metadata: metadata);
    _notifications[id] = n;
    await jsNotifications.addNotification(notification);
    return n;
  }

  Future<void> _updateNotification(CKNotification notification) {
    _notifications[notification.uuid] = notification;
    return jsNotifications.addNotification(notification.notification);
  }

  String _getCallDescription(
    CallState state, {
    CallType callType = CallType.audio,
    bool holding = false,
    bool muted = false,
    DateTime? timestamp,
  }) {
    String base = "${callType.name.capitalize()} Call";
    String description = "";

    switch (state) {
      case CallState.initiated:
        description = "Making $base";
        break;
      case CallState.ringing:
        description = "Incoming $base";
        break;
      case CallState.dialing:
        description = "Dialing $base";
        break;
      case CallState.active:
        description = "Ongoing $base";
        if (timestamp != null) {
          final elapsed = DateTime.now().getTimeDifference(timestamp);
          description += " ($elapsed)";
        }
        if (holding) {
          description = "$description (On Hold)";
        }
        if (muted) {
          description = "$description (Muted)";
        }
        break;
      case CallState.reconnecting:
        description = "$base (Reconnecting)";
        break;
      case CallState.disconnecting:
        description = "Hanging up";
        break;
      case CallState.disconnected:
        description = "Call Ended";
        break;
    }

    return description;
  }

  @override
  Future<void> repost({required String uuid, bool silent = true}) {
    final notification = _notifications[uuid];
    if (notification == null) {
      return Future.value();
    }

    final n = notification.notification;
    final o = n.options?.copyWith(
      requireInteraction: false,
      silent: true,
    );
    final updated = n.copyWith(options: o);
    return jsNotifications.addNotification(updated);
  }

  @override
  CKNotification? getNotification(String uuid) {
    return _notifications[uuid];
  }

  @override
  List<CKNotification> getAllNotifications() {
    return _notifications.values.toList();
  }

  @override
  Future<void> add(CKNotification notification) async {
    _notifications[notification.uuid] = notification;
  }
}
