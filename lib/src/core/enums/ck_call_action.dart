import 'package:simple_print/simple_print.dart';
import 'package:web_callkit/src/utils/utils.dart';

enum CKCallAction {
  none,
  answer,
  hangUp,
  dismiss,
  callback,
  decline,
  switchVideo,
  switchAudio,
  switchScreenShare,
  mute,
  unmute,
  hold,
  unhold;

  static CKCallAction? fromString(String action) {
    final lower = action.sanitizeEnum();
    return values.firstWhere((element) => element.name.sanitizeEnum() == lower, orElse: () {
      printDebug("CKCallAction not found for '$action' (sanitized to '$lower')");
      printDebug("Returning CKCallAction.none");
      return CKCallAction.none;
    });
  }

  String get action {
    switch (this) {
      case CKCallAction.none:
        return "none";
      case CKCallAction.answer:
        return "answer";
      case CKCallAction.hangUp:
        return "hang-up";
      case CKCallAction.dismiss:
        return "dismiss";
      case CKCallAction.callback:
        return "callback";
      case CKCallAction.decline:
        return "decline";
      case CKCallAction.switchVideo:
        return "switch-video";
      case CKCallAction.switchAudio:
        return "switch-audio";
      case CKCallAction.switchScreenShare:
        return "switch-screenshare";
      case CKCallAction.mute:
        return "mute";
      case CKCallAction.unmute:
        return "unmute";
      case CKCallAction.hold:
        return "hold";
      case CKCallAction.unhold:
        return "unhold";
    }
  }

  String get label {
    switch (this) {
      case CKCallAction.none:
        return "None";
      case CKCallAction.answer:
        return "Answer";
      case CKCallAction.hangUp:
        return "Hang Up";
      case CKCallAction.dismiss:
        return "Dismiss";
      case CKCallAction.callback:
        return "Callback";
      case CKCallAction.decline:
        return "Decline";
      case CKCallAction.switchVideo:
        return "Switch Video";
      case CKCallAction.switchAudio:
        return "Switch Audio";
      case CKCallAction.switchScreenShare:
        return "Switch Screen-Share";
      case CKCallAction.mute:
        return "Mute";
      case CKCallAction.unmute:
        return "Unmute";
      case CKCallAction.hold:
        return "Hold";
      case CKCallAction.unhold:
        return "Unhold";
    }
  }
}