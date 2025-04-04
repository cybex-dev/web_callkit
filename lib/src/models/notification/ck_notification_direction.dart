import 'package:js_notifications/interop/interop.dart';

enum CKNotificationDirection {
  auto,
  ltr,
  rtl;

  static JSNotificationDirection? toJS(CKNotificationDirection dir) {
    switch (dir) {
      case CKNotificationDirection.auto:
        return JSNotificationDirection.auto;
      case CKNotificationDirection.ltr:
        return JSNotificationDirection.ltr;
      case CKNotificationDirection.rtl:
        return JSNotificationDirection.rtl;
    }
  }

  static fromJs(JSNotificationDirection dir) {
    switch (dir) {
      case JSNotificationDirection.auto:
        return CKNotificationDirection.auto;
      case JSNotificationDirection.ltr:
        return CKNotificationDirection.ltr;
      case JSNotificationDirection.rtl:
        return CKNotificationDirection.rtl;
    }
  }

  JSNotificationDirection get js => CKNotificationDirection.toJS(this)!;
}
