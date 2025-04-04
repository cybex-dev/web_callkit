enum CKCallType {
  audio,
  video,
  screenShare;

  static CKCallType fromString(String value) {
    switch (value) {
      case 'audio':
        return CKCallType.audio;
      case 'video':
        return CKCallType.video;
      case 'screenShare':
        return CKCallType.screenShare;
      default:
        throw ArgumentError('Invalid call type: $value');
    }
  }
}
