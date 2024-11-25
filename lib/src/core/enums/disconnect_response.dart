enum DisconnectResponse {
  /// Disconnect response is unknown.
  unknown,

  /// Disconnect due to an error.
  error,

  /// Disconnect due to a local end call request
  local,

  /// Disconnect due to a remote end call request or remote party failed to answer in time.
  remote,

  /// Disconnect due to a call was cancelled.
  canceled,

  /// Disconnect due to a incoming call was not answered in time.
  missed,

  /// Disconnect due to incoming call was rejected.
  rejected,

  /// Disconnect due to remote party being busy
  busy,
}