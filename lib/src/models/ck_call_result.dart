import 'package:js_notifications/core/core.dart';

import '../core/core.dart';

class CKCallResult {
  final String uuid;
  final CKCallAction action;
  final Map<String, dynamic> data;

  const CKCallResult({required this.uuid, required this.action, required this.data});

  factory CKCallResult.fromResult(NotificationActionResult result) {
    final action = result.action != null ? CKCallAction.fromString(result.action!) : CKCallAction.none;
    final tag = result.tag ?? "";
    final data = result.data ?? {};
    return CKCallResult(uuid: tag, action: action, data: data);
  }

  @override
  String toString() {
    return 'CKCallResult{uuid: $uuid, action: $action, data: $data}';
  }
}