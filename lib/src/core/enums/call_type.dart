enum CallType {
  audio,
  video,
  screenShare;

  static CallType fromString(String value) {
    switch (value) {
      case 'audio':
        return CallType.audio;
      case 'video':
        return CallType.video;
      case 'screenShare':
        return CallType.screenShare;
      default:
        throw ArgumentError('Invalid call type: $value');
    }
  }
}