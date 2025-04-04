import 'package:js_notifications/interop/interop.dart';

import '../../core/enums/ck_call_action.dart';

/// Wrapper for [JSNotificationAction]
class CKNotificationAction extends JSNotificationAction {
  const CKNotificationAction({
    required super.action,
    required super.title,
    super.icon,
  });

  factory CKNotificationAction.fromNotificationAction(
    CKCallAction value, {
    String? icon,
  }) {
    return CKNotificationAction(
      action: value.action,
      title: value.label,
      icon: icon,
    );
  }

  factory CKNotificationAction.fromAction(
    String action, {
    String? icon,
  }) {
    final value = CKCallAction.fromString(action);
    return CKNotificationAction.fromNotificationAction(value!, icon: icon);
  }
}
