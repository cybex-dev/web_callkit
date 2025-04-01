enum CallKitCapability {
  /// Ability to place a call on hold after the call has started.
  hold,

  /// Ability to place a call on hold from the start of the call.
  supportHold,

  /// Ability to mute a call.
  mute,

  /// Ability to enable video.
  video,

  /// Ability to silence an incoming call.
  silence,
}
