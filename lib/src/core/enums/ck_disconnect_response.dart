enum CKDisconnectResponse {
  /// Disconnect response is unknown.
  unknown,

  /// Disconnect due to an error. Can be used at any state of the call.
  error,

  /// Disconnect due to a local end call request, can only be used once call is active.
  local,

  /// Disconnect due to a remote end call request or remote party failed to answer in time. Can be used at any state of the call.
  remote,

  /// Disconnect due to an outgoing call was cancelled. Can be used at any state of the call before it is connected.
  canceled,

  /// Disconnect due to a incoming call was not answered in time. Can be used at any state of the call before it is connected.
  missed,

  /// Disconnect due to an outgoing called was rejected by remote party. Can be used at any state of the call before it is connected.
  rejected,

  /// Disconnect due to incoming call was rejected. Can be used at any state of the call before it is connected.
  declined,

  /// Disconnect due to remote party being busy. Can be used at any state of the call before it is connected.
  busy;
}
