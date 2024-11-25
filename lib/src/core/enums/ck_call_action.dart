enum CKCallAction {
  none,
  answer,
  hangUp,
  dismiss,
  callback,
  decline;

  static CKCallAction fromString(String action) {
    return values.firstWhere((element) => element.name == action, orElse: () => none);
  }
}