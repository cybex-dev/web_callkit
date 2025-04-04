enum CKCallState {
  /// For new but not yet connected calls
  initiated,

  /// For incoming calls, when the user is being alerted with vibration and sound if allowed
  ringing,

  /// For outgoing calls
  dialing,

  /// Active connection, while both users can actively communicate
  active,

  /// Call is reconnecting
  reconnecting,

  /// Call is disconnecting (locally)
  disconnecting,

  /// Call is disconnected either locally or remotely
  disconnected,
}
