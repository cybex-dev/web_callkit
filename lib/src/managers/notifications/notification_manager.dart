import 'dart:async';

import 'package:web_callkit/web_callkit.dart';

abstract class NotificationManager {
  static const tag = 'notification_manager';

  // ignore: constant_identifier_names
  static const String CK_EXTRA_PERSIST = CALLKIT_PERSIST;

  /// Obtain stream for notification click/actions i.e. [CKNotificationAction] button clicks. On tapping a notification, this is considered an action.
  /// These notifications are reposted immediately to ensure transparency of the call state. A notification can be reposted automatically with the [repostOnClick] property.
  /// TODO: Implement repostOnClick
  Stream<CKCallResult> get actionStream;

  /// Obtain stream for notification dismiss events. Dismiss events include clicking the close button on the notification.
  Stream<CKCallResult> get dismissStream;

  /// Notification tap interaction stream. Taps include clicking anywhere on the notification except the close, or
  /// [CKNotificationAction] buttons (except empty actions). Action buttons with an empty action will be treated as a tap.
  Stream<CKCallResult> get tapStream;

  /// Requests notification permissions from web browser
  Future<bool> requestPermissions();

  /// Check if the notification permissions are granted
  Future<bool> hasPermissions();

  /// Dispose of the notification manager, releasing resources & streams
  Future<void> dispose();

  /// Dismiss a notification by uuid
  Future<void> dismiss({required String uuid});

  /// Add a notification to the notification manager, overwriting existing an notification with the same [CKNotification.uuid]
  Future<void> add(CKNotification notification, {Map<String, bool>? flags});

  // /// Repost a notification by uuid, if the notification is not found, nothing is done.
  // /// If [silent] is true, the notification will update the [CKNotification] but override the [JSNotificationOptions.silent] with [silent].
  // Future<void> repost({required String uuid, bool silent = true});

  /// Get a notification by uuid
  CKNotification? getNotification(String uuid);

  /// Get all notifications currently visible.
  Iterable<CKNotification> getAllNotifications();

  /// Obtain stream describing changes to notifications
  Stream<CKNotification> get notificationChangeStream;

  /// Obtain stream of all notifications currently visible
  Stream<Iterable<CKNotification>> get notificationStream;
}
