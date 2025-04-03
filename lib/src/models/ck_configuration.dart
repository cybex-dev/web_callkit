import 'package:web_callkit/src/core/core.dart';
import 'package:web_callkit/src/models/models.dart';

class CKConfiguration {
  final CKSounds sounds;
  final Set<CallKitCapability> capabilities;
  final Set<CallAttributes> attributes;
  final CKTimer timer;
  final bool notifyOnCallEnd;
  final Map<CKCallAction, String> icons;
  // final bool repostOnClick;

  const CKConfiguration({
    this.sounds = const CKSounds(),
    this.capabilities = const {},
    this.attributes = const {},
    this.timer = const CKTimer(),
    this.notifyOnCallEnd = true,
    this.icons = const {},
    // this.repostOnClick = true,
  });

  @override
  String toString() {
    // return 'CKConfiguration{sounds: $sounds, capabilities: $capabilities, attributes: $attributes, timer: $timer, notifyOnCallEnd: $notifyOnCallEnd, repostOnClick: $repostOnClick}';
    return 'CKConfiguration{sounds: $sounds, capabilities: $capabilities, attributes: $attributes, timer: $timer, notifyOnCallEnd: $notifyOnCallEnd, icons: $icons}';
  }
}

class CKTimer {
  final bool enabled;
  final CallState startOnState;

  const CKTimer({
    this.enabled = true,
    this.startOnState = CallState.active,
  });

  @override
  String toString() {
    return 'CKTimer{enabled: $enabled, startOnState: $startOnState}';
  }
}
