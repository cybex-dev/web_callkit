import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:js_notifications/utils/utils.dart';

import '../core/core.dart';
import '../managers/managers.dart';
import '../models/models.dart';
import '../platform_interface/web_callkit_platform_interface.dart';

/// An implementation of [WebCallkitPlatform] that uses method channels.
class MethodChannelWebCallkit extends WebCallkitPlatform {
  final _defaultConfiguration = const CKConfiguration(
    sounds: CKCustomSounds(),
    capabilities: {
      CallKitCapability.supportHold,
      CallKitCapability.mute,
    },
    attributes: {},
  );

  late AudioManager _audioManager;
  late CallManager _callManager;
  late NotificationManager _notificationManager;

  late final StreamSubscription<CKCallResult> _notificationActionStream;
  late final StreamSubscription<CKCallResult> _dismissActionStream;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('web_callkit');

  late CKConfiguration _configuration;

  @override
  set configuration(CKConfiguration value) {
    _configuration = value;
  }

  MethodChannelWebCallkit({
    AudioManager? audioManager,
    CallManager? callManager,
    NotificationManager? notificationManager,
    CKConfiguration? configuration,
  }) {
    _configuration = configuration ?? _defaultConfiguration;
    _audioManager = audioManager ?? AudioManager();
    _callManager = callManager ?? CallManager();
    _notificationManager = notificationManager ?? NotificationManagerImpl();

    _notificationActionStream = _notificationManager.actionStream.listen((event) {
      printDebug("Action Stream: ${event.action}");
    });
    _dismissActionStream = _notificationManager.dismissStream.listen((event) {
      printDebug("Dismiss Stream: ${event.action}");
    });
  }

  @override
  Future<CKCall> reportNewCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
  }) async {
    final attr = attributes ?? _configuration.attributes;
    CKCall call = CKCall.init(uuid: uuid, localizedName: handle, attributes: attr, callType: CallType.audio, data: data);
    _callManager.addCall(call);

    final capabilities = _configuration.capabilities;
    await _notificationManager.incomingCall(uuid, handle,
        callType: call.callType,
        holding: call.isHolding,
        muted: call.isMuted,
        enableHoldAction: capabilities.contains(CallKitCapability.supportHold),
        enableMuteAction: capabilities.contains(CallKitCapability.mute),
        hasVideoCapability: true,
        data: data);
    return call;
  }

  @override
  Future<void> reportCallDisconnected(
    String uuid, {
    required DisconnectResponse response,
  }) async {
    _callManager.removeCall(uuid);
    _notificationManager.dismiss(uuid);
  }

  @override
  Future<CKCall?> updateCallAttributes(
    String uuid, {
    required Set<CallAttributes> attributes,
    Map<String, dynamic>? data,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return null;
    }

    final update = call.copyWith(attributes: attributes);
    _callManager.updateCall(uuid, update);

    final capabilities = _configuration.capabilities;
    await _notificationManager.incomingCall(
      uuid,
      call.localizedName,
      callType: call.callType,
      holding: call.isHolding,
      muted: call.isMuted,
      enableHoldAction: capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: data,
    );

    return update;
  }

  @override
  Future<CKCall?> updateCallCapabilities(
    String uuid, {
    required Set<CallKitCapability> capabilities,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      throw Exception("Call with uuid: $uuid not found.");
    }

    final update = call.copyWith(capabilities: capabilities);
    return _callManager.updateCall(uuid, update);
  }

  @override
  Future<CKCall?> updateCallData(
    String uuid, {
    required Map<String, dynamic> data,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return null;
    }

    final update = call.copyWith(data: data);
    return _callManager.updateCall(uuid, update);
  }

  @override
  Future<CKCall?> updateCallStatus(
    String uuid, {
    required CallState callStatus,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return null;
    }

    final update = call.copyWith(state: callStatus);
    return _callManager.updateCall(uuid, update);
  }

  @override
  Future<CKCall?> updateCallType(String uuid, {required CallType callType}) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return null;
    }

    final update = call.copyWith(callType: callType);
    return _callManager.updateCall(uuid, update);
  }

  @override
  Future<Iterable<CKCall>> getCalls() async {
    return _callManager.calls.values;
  }

  @override
  Stream<Iterable<CKCall>> get callStream {
    return _callManager.callStream;
  }

  @override
  Stream<CallEvent> get eventStream {
    return _callManager.eventStream;
  }

  @override
  Future<CKCall?> getCall(String uuid) async {
    return _callManager.calls[uuid];
  }

  @override
  Future<void> onCallAction(CKCallResult result) {
    switch (result.action) {
      case CKCallAction.answer:
        // do nothing
        break;
      case CKCallAction.hangUp:
        // do nothing
        break;
      case CKCallAction.decline:
        // do nothing
        break;
      case CKCallAction.callback:
        break;
      case CKCallAction.dismiss:
        break;
      case CKCallAction.none:
        break;
    }

    return Future.value();
  }

  @override
  Future<void> onStateChange(CKCall call) async {
    switch (call.state) {
      case CallState.initiated:
        // AudioManager play outgoing call sound
        break;
      case CallState.ringing:
        // AudioManager play remote ringing sound
        _audioManager.play(AudioManager.defautRingtoneUrl);
        break;
      case CallState.dialing:
        // AudioManager play dialing sound
        _audioManager.play(AudioManager.defautDialingUrl);
        break;
      case CallState.active:
        // Do nothing
        break;
      case CallState.hold:
        // AudioManager play holding sound
        _audioManager.play(AudioManager.defautHoldUrl);
        break;
      case CallState.disconnecting:
        // Do nothing
        break;
      case CallState.disconnected:
        // AudioManager play call ended sound
        break;
    }
  }
}
