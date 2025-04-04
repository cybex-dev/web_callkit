/// Describes the notification action source.
/// Distinguishes between actions triggered by the user by Notification Action click events and actions triggered by the API.
enum CKActionSource {
  /// from notification or user input
  notification,

  /// from API or internal
  api,
}
