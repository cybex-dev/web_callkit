import 'package:js_notifications/js_notifications_web.dart';
import 'package:web/web.dart';

import 'ck_notification_action.dart';
import 'ck_notification_direction.dart';

/// Wrapper for [JSNotification], with additional metadata and uuid requirement.
class CKNotification {
  /// Unique notification Id
  final String uuid;

  /// JS notification
  final JSNotification notification;

  /// Callkit metadata, stores Callkit specific data, flags, etc.
  final Map<String, dynamic> metadata;

  const CKNotification._internal(this.uuid, this.notification, {this.metadata = const {}});

  factory CKNotification(String uuid, JSNotification notification, Map<String, dynamic>? metadata) {
    return CKNotification._internal(
      uuid,
      notification,
      metadata: Map<String, dynamic>.of(metadata ?? const {}),
    );
  }

  factory CKNotification.simple(String uuid, JSNotification notification) => CKNotification._internal(uuid, notification);

  /// Create a CKNotification using a factory builder, allows constructing a JsNotification via
  /// individual properties. Allows providing a list of [actions] and [metadata] using within the
  /// CallKit plugin.
  factory CKNotification.builder({
    required String uuid,
    required String title,
    String? icon,
    String? body,
    int? badge,
    CKNotificationDirection? dir,
    bool? renotify,
    bool? requireInteraction,
    bool? silent,
    String? image,
    String? lang,
    VibratePattern? vibrate,
    int? timestamp,
    List<CKNotificationAction> actions = const [],
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
  }) {
    final options = JSNotificationOptions(
      icon: icon,
      data: data,
      body: body,
      renotify: renotify,
      requireInteraction: requireInteraction,
      tag: uuid,
      silent: silent,
      actions: actions,
      badge: badge,
      dir: dir?.js,
      image: image,
      lang: lang,
      vibrate: vibrate,
      timestamp: timestamp,
    );
    final notification = JSNotification(title, options);
    return CKNotification(uuid, notification, metadata ?? const {});
  }

  /// Returns a new CKNotification with updated metadata or notification.
  CKNotification copyWith({
    JSNotification? notification,
    Map<String, dynamic>? metadata,
  }) {
    return CKNotification(
      uuid,
      notification ?? this.notification,
      metadata ?? this.metadata,
    );
  }

  /// Returns a new CKNotification with updated metadata or notification.
  CKNotification copyWithSelf(CKNotification other) {
    return copyWith(
      notification: other.notification,
      metadata: other.metadata,
    );
  }
}
