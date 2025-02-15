enum CallEventType {
  add,
  update,
  remove;

  String get symbol {
    switch (this) {
      case CallEventType.add:
        return '+';
      case CallEventType.update:
        return '~';
      case CallEventType.remove:
        return '-';
      // default:
      //   return '?';
    }
  }
}
