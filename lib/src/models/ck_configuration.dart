import 'package:web_callkit/src/managers/managers.dart';
import 'package:web_callkit/src/models/models.dart';
import 'package:web_callkit/src/core/core.dart';

class CKConfiguration {
  final CKSounds sounds;
  final Set<CallKitCapability> capabilities;
  final Set<CallAttributes> attributes;
  final CKTimer timer;
  final bool notifyOnCallEnd;

  const CKConfiguration({
    this.sounds = const CKSounds(),
    this.capabilities = const {},
    this.attributes = const {},
    this.timer = const CKTimer(),
    this.notifyOnCallEnd = true,
  });
}

class CKTimer {
  final bool enabled;
  final CallState startOnState;

  const CKTimer({
    this.enabled = true,
    this.startOnState = CallState.active,
  });
}
