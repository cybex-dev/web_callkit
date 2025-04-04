import '../../core/enums/ck_call_attributes.dart';
import '../../core/enums/ck_capability.dart';

/// TODO: we want customized:
/// - custom ringing sound
/// - vibration
/// - custom icon for active/incoming call(s) and queued, held, etc. calls

class CallkitConfig {
  final String appName;
  final String incomingRingtone;
  final CallConfig callConfig;
  final NotificationConfig notificationConfig;

  final Set<CKCapability> capabilities;
  final Set<CKCallAttributes> attributes;

  CallkitConfig({
    required this.appName,
    required this.incomingRingtone,
    required this.callConfig,
    required this.notificationConfig,
    required this.capabilities,
    required this.attributes,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'incomingRingtone': incomingRingtone,
      'callConfig': callConfig.toMap(),
      'notificationConfig': notificationConfig.toMap(),
      'capabilities': capabilities.map((e) => e.name).toList(),
      'attributes': attributes.map((e) => e.name).toList(),
    };
  }
}

class CallConfig {
  final bool enableTimer;

  CallConfig({
    required this.enableTimer,
  });

  Map<String, dynamic> toMap() {
    return {
      'enableTimer': enableTimer,
    };
  }
}

class NotificationConfig {
  final String incomingCallTitle;
  final String incomingCallBody;
  final String missedCallTitle;
  final String missedCallBody;

  NotificationConfig({
    required this.incomingCallTitle,
    required this.incomingCallBody,
    required this.missedCallTitle,
    required this.missedCallBody,
  });

  Map<String, dynamic> toMap() {
    return {
      'incomingCallTitle': incomingCallTitle,
      'incomingCallBody': incomingCallBody,
      'missedCallTitle': missedCallTitle,
      'missedCallBody': missedCallBody,
    };
  }
}
