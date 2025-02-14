import 'package:js_notifications/core/core.dart';
import 'package:web_callkit/src/utils/utils.dart';

import '../core/core.dart';

class CKCallResult {
  final String uuid;
  final CKCallAction action;
  final Map<String, dynamic> data;

  const CKCallResult(
      {required this.uuid, required this.action, required this.data});

  factory CKCallResult.fromResult(NotificationActionResult result) {
    final action =
        CKCallAction.fromString(result.action ?? "") ?? CKCallAction.none;
    final tag = result.tag ?? "";
    final data = result.data ?? {};
    return CKCallResult(uuid: tag, action: action, data: data);
  }

  @override
  String toString() {
    return 'CKCallResult{uuid: $uuid, action: $action, data: $data}';
  }

  bool containsFlag(String flag, [bool? defaultValue]) {
    return data.getBool(flag, orElse: () => defaultValue ?? false);
  }
}
