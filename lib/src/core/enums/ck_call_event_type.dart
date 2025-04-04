enum CKCallEventType {
  add,
  update,
  remove;

  String get symbol {
    switch (this) {
      case CKCallEventType.add:
        return '+';
      case CKCallEventType.update:
        return '~';
      case CKCallEventType.remove:
        return '-';
      // default:
      //   return '?';
    }
  }
}
