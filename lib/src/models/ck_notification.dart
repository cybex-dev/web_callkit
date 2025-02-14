import 'package:js_notifications/js_notifications_web.dart';

/// Wrapper for [JSNotification], with additional metadata and uuid requirement.
class CKNotification {
  /// Unique notification Id
  final String uuid;

  /// JS notification
  final JSNotification notification;

  /// callkit metadata
  final Map<String, dynamic> metadata;

  const CKNotification(this.uuid, this.notification, this.metadata);

  const CKNotification.simple(this.uuid, this.notification)
      : metadata = const {};

  CKNotification copyWith(
      {JSNotification? notification, Map<String, dynamic>? metadata}) {
    return CKNotification(
      uuid,
      notification ?? this.notification,
      metadata ?? this.metadata,
    );
  }
}
