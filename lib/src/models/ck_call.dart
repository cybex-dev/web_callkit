import 'dart:convert';

import '../core/core.dart';

class CKCall {
  final String uuid;
  final String localizedName;
  final DateTime dateStarted;
  final DateTime dateUpdated;
  final Set<CallAttributes> attributes;
  final CallType callType;
  final CallState state;
  final Map<String, dynamic>? data;
  final Set<CallKitCapability> capabilities;

  CKCall._internal({
    required this.uuid,
    required this.localizedName,
    required this.dateStarted,
    required this.dateUpdated,
    required this.attributes,
    required this.callType,
    required this.state,
    required this.data,
    required this.capabilities,
  });

  factory CKCall.init({
    required String uuid,
    required String localizedName,
    Set<CallAttributes> attributes = const {},
    Set<CallKitCapability> capabilities = const {},
    CallType callType = CallType.audio,
    Map<String, dynamic>? data,
  }) {
    return CKCall._internal(
      uuid: uuid,
      localizedName: localizedName,
      dateStarted: DateTime.now(),
      dateUpdated: DateTime.now(),
      attributes: attributes,
      callType: callType,
      state: CallState.initiated,
      data: data,
      capabilities: capabilities,
    );
  }

  CKCall update(CKCall call) {
    return copyWith(
      uuid: call.uuid,
      localizedName: call.localizedName,
      dateStarted: call.dateStarted,
      dateUpdated: call.dateUpdated,
      attributes: call.attributes,
      callType: call.callType,
      state: call.state,
      data: call.data,
      capabilities: call.capabilities,
    );
  }

  CKCall copyWith({
    String? uuid,
    String? localizedName,
    DateTime? dateStarted,
    DateTime? dateUpdated,
    Set<CallAttributes>? attributes,
    Set<CallKitCapability>? capabilities,
    CallType? callType,
    CallState? state,
    Map<String, dynamic>? data,
  }) {
    return CKCall._internal(
      uuid: uuid ?? this.uuid,
      localizedName: localizedName ?? this.localizedName,
      dateStarted: dateStarted ?? this.dateStarted,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      attributes: attributes ?? this.attributes,
      callType: callType ?? this.callType,
      state: state ?? this.state,
      data: data ?? this.data,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'localizedName': localizedName,
      'dateStarted': dateStarted.toIso8601String(),
      'dateUpdated': dateUpdated.toIso8601String(),
      'attributes': attributes.map((e) => e.name),
      'callType': callType.name,
      'state': state.name,
      'data': jsonEncode(data ?? {}),
      'capabilities': capabilities.map((e) => e.name),
    };
  }

  @override
  String toString() {
    return 'CKCall{uuid: $uuid, localizedName: $localizedName, dateStarted: $dateStarted, dateUpdated: $dateUpdated, attributes: $attributes, callType: $callType, state: $state, data: $data, capabilities: $capabilities}';
  }

  String? difference(CKCall call) {
    if (this == call) {
      return null;
    }
    final List<String> changes = [];
    if (uuid != call.uuid) changes.add('uuid: $uuid -> ${call.uuid}');
    if (localizedName != call.localizedName)
      changes.add('localizedName: $localizedName -> ${call.localizedName}');
    if (dateStarted != call.dateStarted)
      changes.add('dateStarted: $dateStarted -> ${call.dateStarted}');
    if (dateUpdated != call.dateUpdated)
      changes.add('dateUpdated: $dateUpdated -> ${call.dateUpdated}');
    if (attributes != call.attributes)
      changes.add('attributes: $attributes -> ${call.attributes}');
    if (callType != call.callType)
      changes.add('callType: $callType -> ${call.callType}');
    if (state != call.state) changes.add('state: $state -> ${call.state}');
    if (data != call.data) changes.add('data: $data -> ${call.data}');
    if (capabilities != call.capabilities)
      changes.add('capabilities: $capabilities -> ${call.capabilities}');
    return changes.join(',\n');
  }

  bool get isHolding => attributes.contains(CallAttributes.hold);

  bool get isMuted => attributes.contains(CallAttributes.mute);

  bool get isAudioOnly => callType == CallType.audio;

  bool get isVideoCall => callType == CallType.video;

  bool get hasData => data != null && data!.isNotEmpty;

  bool get hasCapabilities => capabilities.isNotEmpty;

  bool get hasCapabilitySupportsHold =>
      capabilities.contains(CallKitCapability.supportHold);

  bool get hasCapabilityHold => capabilities.contains(CallKitCapability.hold);

  bool get hasCapabilityMute => capabilities.contains(CallKitCapability.mute);

  bool get hasCapabilityVideo => capabilities.contains(CallKitCapability.video);
}
