import 'package:web_callkit/src/core/enums/ck_call_attributes.dart';

import '../../core/enums/ck_call_action.dart';
import '../../core/enums/ck_capability.dart';
import 'ck_sounds.dart';
import 'ck_timer.dart';

class CKConfiguration {
  final CKSounds sounds;
  final Set<CKCapability> capabilities;
  final Set<CKCallAttributes> attributes;
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
