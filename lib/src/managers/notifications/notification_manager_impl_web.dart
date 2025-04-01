import 'dart:async';

import 'package:js_notifications/platform_interface/js_notifications_platform_interface.dart';
import 'package:simple_print/simple_print.dart';
import 'package:web_callkit/src/managers/managers.dart';
import 'package:web_callkit/src/models/ck_notification_action.dart';

import '../../models/models.dart';

/// Notification Manager implementation for Web
/// Obfuscates dependency on [JsNotificationsPlatform], specifically [JSNotification]
/// and [JSNotificationAction] in favour of [CKNotification] and [CKNotificationAction].
class NotificationManagerImplWeb extends NotificationManager {
  /// Internal notification registry
  final Map<String, CKNotification> _notifications = {};

  /// [JsNotificationsPlatform] action streams
  Stream<CKCallResult>? _actionStream;
  Stream<CKCallResult>? _dismissStream;
  Stream<CKCallResult>? _tapStream;

  late StreamController<List<CKNotification>> _notificationsController;
  late StreamController<CKNotification> _notificationChangeController;

  NotificationManagerImplWeb() {
    _notificationsController = StreamController<List<CKNotification>>.broadcast();
    _notificationChangeController = StreamController<CKNotification>.broadcast();
  }

  /// Get [JsNotificationsPlatform] instance
  JsNotificationsPlatform get _jsNotifications => JsNotificationsPlatform.instance;

  @override
  Stream<CKCallResult> get actionStream {
    _actionStream ??= _jsNotifications.actionStream.map(CKCallResult.fromResult).asBroadcastStream();
    return _actionStream!;
  }

  @override
  Stream<CKCallResult> get dismissStream {
    _dismissStream ??= _jsNotifications.dismissStream.map(CKCallResult.fromResult).asBroadcastStream();
    return _dismissStream!;
  }

  @override
  Stream<CKCallResult> get tapStream {
    _tapStream ??= _jsNotifications.tapStream.map(CKCallResult.fromResult).asBroadcastStream();
    return _tapStream!;
  }

  @override
  Future<void> add(CKNotification notification, {Map<String, bool>? flags}) async {
    CKNotification current;

    // get existing notification & update js notification and metadata
    final cur = _notifications[notification.uuid];
    final exists = cur != null;
    if (exists) {
      // printDebug("Notification with id ${notification.uuid} already exists, overwriting.", tag: NotificationManager.tag);
      current = cur.copyWithSelf(notification);
    } else {
      current = notification;
    }

    // update metadata with flags
    final ckMetadata = {...current.metadata, ...?flags};
    final updatedMetadata = {...ckMetadata, ...current.metadata};
    final updated = current.copyWith(metadata: updatedMetadata);

    // add notification to registry
    _notifications[notification.uuid] = updated;

    // post notification to platform
    await _jsNotifications.addNotification(updated.notification);

    if (exists) {
      _notificationChangeController.add(updated);
    }
    _notificationsController.add(_notifications.values.toList());
  }

  @override
  Future<void> dismiss({required String uuid}) {
    if (!_notifications.containsKey(uuid)) {
      printWarning("Notification with id $uuid not found", tag: NotificationManager.tag, debugOverride: true);
    }

    /// dismissing notifications via [JsNotificationsPlatform] will trigger an
    /// event update via the [dismissStream] where we will remove the notification
    /// from [_notifications]
    return _jsNotifications.dismissNotification(id: uuid);
  }

  @override
  Future<void> dispose() async {
    _notificationsController.close();
    _notificationChangeController.close();
  }

  @override
  Iterable<CKNotification> getAllNotifications() {
    return _notifications.values;
  }

  @override
  CKNotification? getNotification(String uuid) {
    return _notifications[uuid];
  }

  @override
  Stream<CKNotification> get notificationChangeStream => _notificationChangeController.stream;

  @override
  Stream<Iterable<CKNotification>> get notificationStream => _notificationsController.stream;

  @override
  Future<bool> hasPermissions() => Future.value(_jsNotifications.hasPermissions);

  @override
  Future<bool> requestPermissions() => _jsNotifications.requestPermissions();
}