import '../core/core.dart';

class CKCustomSounds {
  final bool enabled;
  final Map<CallState, String> sounds;

  const CKCustomSounds({this.enabled = true, this.sounds = const {}});
}

class CKConfiguration {
  final CKCustomSounds sounds;
  final Set<CallKitCapability> capabilities;
  final Set<CallAttributes> attributes;

  const CKConfiguration({this.sounds = const CKCustomSounds(), this.capabilities = const {}, this.attributes = const {}});
}