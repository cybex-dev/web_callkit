import 'package:simple_print/simple_print.dart';
import 'package:web_callkit/src/utils/utils.dart';

enum CKCallAction {
  /// No action
  none,

  /// Action to notify of answer & accept call intent.
  answer,

  /// Action to notify of declining call intent.
  decline,

  /// Action to notify of ending a call regardless of state (see README for more info).
  hangUp,

  /// Dismiss a notification (see README for more info).
  /// TODO(cybex-dev): This may be in conflict with the persist flag.
  dismiss,

  /// Action to notify of callback intent.
  callback,

  /// Action to notify of switching to video call intent subject to [CallKitCapability.switchVideo] capability (see README for more info).
  switchVideo,

  /// Action to notify of switching to audio call intent, opposite of [switchVideo] and [switchScreenShare] (see README for more info).
  switchAudio,

  /// Action to notify of switching to screen-share call intent, adjacent to [switchVideo] subject to [CallKitCapability.screenShare] capability (see README for more info).
  switchScreenShare,

  /// Action to notify of muting a call intent subject to [CallKitCapability.mute] capability.
  mute,

  /// Action to notify of unmuting a call intent, opposite of [mute] (see README for more info).
  unmute,

  /// Action to notify of holding a call intent subject to [CallKitCapability.supportHold] or [CallKitCapability.hold] capability.
  hold,

  /// Action to notify of unholding a call intent, opposite of [hold] (see README for more info).
  unhold,

  /// Action to notify of silencing an incoming call intent
  silence,

  /// Action to notify of disabling video (on a call with video/screen share) intent (see README for more info)
  disableVideo,

  /// Action to notify of enabling video (on a call with video/screen share) intent (see README for more info)
  enableVideo;

  /// Returns the enum value from a json string
  static CKCallAction? fromString(String action) {
    final lower = action.sanitizeEnum();
    return values.firstWhere((element) => element.name.sanitizeEnum() == lower,
        orElse: () {
      printDebug(
          "CKCallAction not found for '$action' (sanitized to '$lower')");
      printDebug("Returning CKCallAction.none");
      return CKCallAction.none;
    });
  }

  /// Returns the json string of the enum value
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
      case CKCallAction.silence:
        return "silence";
      case CKCallAction.disableVideo:
        return "disable-video";
      case CKCallAction.enableVideo:
        return "enable-video";
    }
  }

  /// Returns the human-readable name of the enum value
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
      case CKCallAction.silence:
        return "Silence";
      case CKCallAction.disableVideo:
        return "Disable Video";
      case CKCallAction.enableVideo:
        return "Enable Video";
    }
  }
}
