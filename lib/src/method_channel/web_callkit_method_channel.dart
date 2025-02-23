import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_print/simple_print.dart';

import '../core/core.dart';
import '../managers/managers.dart';
import '../models/models.dart';
import '../platform_interface/web_callkit_platform_interface.dart';

typedef OnNotificationDismissed = void Function(CKCall call);

/// An implementation of [WebCallkitPlatform] that uses method channels.
class MethodChannelWebCallkit extends WebCallkitPlatform {
  static const tag = 'web_callkit';

  // ignore: unused_field
  late final AudioManager _audioManager;
  late final CallManager _callManager;
  late final NotificationManager _notificationManager;

  StreamSubscription<CKCallResult>? _tapStreamSubscription;
  StreamSubscription<CKCallResult>? _actionStreamSubscription;
  StreamSubscription<CKCallResult>? _dismissStreamSubscription;
  StreamSubscription<CallEvent>? _callManagerStreamSubscription;

  // ignore: unused_field
  OnNotificationDismissed? _onNotificationDismissed;

  OnCallActionListener? _onCallActionListener;
  OnCallEventListener? _onCallEventListener;
  OnDisconnectListener? _onDisconnectListener;
  OnCallTypeChangeListener? _onCallTypeChangeListener;
  OnDismissedListener? _onDismissedListener;

  late CKConfiguration _configuration;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('web_callkit');

  final Map<CallState, List<DisconnectResponse>> validCallStateDisconnectResponses = {
    CallState.initiated: [
      DisconnectResponse.unknown,
      DisconnectResponse.error,
      DisconnectResponse.local,
      DisconnectResponse.remote,
      DisconnectResponse.canceled,
      DisconnectResponse.rejected,
      DisconnectResponse.busy
    ],
    CallState.ringing: [
      DisconnectResponse.unknown,
      DisconnectResponse.error,
      DisconnectResponse.remote,
      DisconnectResponse.missed,
      DisconnectResponse.rejected,
      DisconnectResponse.busy
    ],
    CallState.dialing: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.rejected, DisconnectResponse.busy],
    CallState.active: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
    CallState.reconnecting: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
    CallState.disconnecting: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
    CallState.disconnected: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
  };

  MethodChannelWebCallkit({
    AudioManager? audioManager,
    CallManager? callManager,
    NotificationManager? notificationManager,
    CKConfiguration? configuration,
  })  : _audioManager = audioManager ?? AudioManager(),
        _callManager = callManager ?? CallManager(),
        _notificationManager = notificationManager ?? NotificationManagerImpl(),
        _configuration = configuration ?? WebCallkitPlatform.defaultConfiguration,
        super() {
    _setupNotificationEventListeners();
  }

  void _setupNotificationEventListeners() {
    /// Listen for action stream events
    _actionStreamSubscription = _notificationManager.actionStream.listen(_onActionListener);

    /// Listen for dismiss stream events
    _dismissStreamSubscription = _notificationManager.dismissStream.listen(_onDismissListener);

    /// Listen for tap stream events
    _tapStreamSubscription = _notificationManager.tapStream.listen(_onTapListener);

    /// Listen to call events, respond via notification & audio managers
    _callManagerStreamSubscription = _callManager.eventStream.listen(_onCallEvent);
  }

  void _onActionListener(CKCallResult result) {
    printDebug("Action Stream: ${result.action}", tag: tag);
    _onCallAction(result, ActionSource.notification);
  }

  void _onDismissListener(CKCallResult result) {
    printDebug("Dismissed notification: ${result.uuid}", tag: NotificationManager.tag);
    final persist = result.containsFlag(NotificationManager.CK_EXTRA_PERSIST);
    if (!persist) {
      _dismissNotification(result.uuid);
    } else {
      _onDismissedListener?.call(result.uuid, ActionSource.notification);
    }
  }

  void _onTapListener(CKCallResult result) {
    printDebug("Tapped notification: ${result.uuid}", tag: tag);
  }

  CKCall _getCall(String uuid) {
    return _callManager.getCall(uuid)!;
  }

  @override
  Future<CKCall> reportIncomingCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CallState? stateOverride,
  }) async {
    final attr = attributes ?? _configuration.attributes;
    CKCall call = CKCall.init(
      uuid: uuid,
      localizedName: handle,
      attributes: attr,
      callType: CallType.audio,
      data: data,
    ).copyWith(state: stateOverride ?? CallState.ringing);
    _callManager.addCall(call);

    final capabilities = _configuration.capabilities;
    await _notificationManager.incomingCall(
      call.uuid,
      callerId: call.localizedName,
      callType: call.callType,
      holding: call.isHolding,
      muted: call.isMuted,
      enableHoldAction: capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: call.data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      metadata: metadata,
    );

    return call;
  }

  @override
  Future<CKCall> reportOutgoingCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
  }) async {
    final attr = attributes ?? _configuration.attributes;
    CKCall call = CKCall.init(
      uuid: uuid,
      localizedName: handle,
      attributes: attr,
      callType: CallType.audio,
      data: data,
    );
    _callManager.addCall(call);

    final capabilities = _configuration.capabilities;
    await _notificationManager.outgoingCall(
      call.uuid,
      callerId: call.localizedName,
      callType: call.callType,
      holding: call.isHolding,
      muted: call.isMuted,
      enableHoldAction: capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: call.data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      metadata: metadata,
    );

    return call;
  }

  @override
  Future<CKCall> reportOngoingCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
    bool holding = false,
    CallType callType = CallType.audio,
  }) async {
    final ckAttributes = attributes ?? _configuration.attributes;
    final ckCapabilities = capabilities ?? _configuration.capabilities;
    CKCall call = CKCall.init(
      uuid: uuid,
      localizedName: handle,
      attributes: ckAttributes,
      callType: callType,
      capabilities: ckCapabilities,
      data: data,
    );
    _callManager.addCall(call);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;

    await _notificationManager.onGoingCall(
      uuid,
      callerId: handle,
      callType: call.callType,
      holding: call.isHolding,
      muted: call.isMuted,
      enableHoldAction: call.hasCapabilitySupportsHold || call.hasCapabilityHold,
      enableMuteAction: call.hasCapabilityMute,
      hasVideoCapability: call.hasCapabilityVideo,
      data: data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      metadata: metadata,
    );
    return call;
  }

  @override
  Future<void> reportCallDisconnected(
    String uuid, {
    required DisconnectResponse response,
  }) async {
    // state check for response
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call not found: $uuid", tag: tag);
      return;
    }
    final validResponses = validCallStateDisconnectResponses[call.state] ?? DisconnectResponse.values;
    if (!validResponses.contains(response)) {
      printWarning("Invalid response for call state: ${call.state}", tag: tag);
      return;
    }
    _callManager.removeCall(uuid, response: response);
  }

  @override
  Future<CKCall?> updateCallAttributes(
    String uuid, {
    required Set<CallAttributes> attributes,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return null;
    }

    // Moderate attributes based on call state and capabilities.
    Set<CallAttributes> moderatedAttributes = {};
    for (var value in attributes) {
      switch (value) {
        case CallAttributes.mute:
          final hasCapability = call.capabilities.contains(CallKitCapability.mute);
          if (!hasCapability) {
            printDebug("Mute attribute not supported. Please enable it with CallKitCapability.mute.", tag: tag);
          } else {
            moderatedAttributes.add(value);
          }
        case CallAttributes.hold:
          final hasCapabilityHold = call.capabilities.contains(CallKitCapability.hold);
          final hasCapabilitySupportHold = call.capabilities.contains(CallKitCapability.supportHold);
          // if call state is initiated or dialing, we can hold with support hold capability.
          // if call is active, we can hold with hold attribute.

          if (!hasCapabilityHold && !hasCapabilitySupportHold) {
            printDebug("Hold attribute not supported. Please enable it with CallKitCapability.supportHold or CallKitCapability.hold.", tag: tag);
          } else {
            switch (call.state) {
              case CallState.initiated:
              case CallState.dialing:
                if (hasCapabilitySupportHold) {
                  moderatedAttributes.add(value);
                } else {
                  printDebug("Hold attribute not supported in current state: ${call.state}", tag: tag);
                }
                break;
              case CallState.active:
                if (hasCapabilityHold || hasCapabilitySupportHold) {
                  moderatedAttributes.add(value);
                }
                break;
              default:
                printDebug("Hold attribute not supported in current state: ${call.state}", tag: tag);
                break;
            }
          }
      }
    }

    final update = call.copyWith(attributes: moderatedAttributes);
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;

    await _notificationManager.onGoingCall(
      uuid,
      callerId: update.localizedName,
      callType: update.callType,
      holding: update.isHolding,
      muted: update.isMuted,
      enableHoldAction: update.hasCapabilitySupportsHold || update.hasCapabilityHold,
      enableMuteAction: update.hasCapabilityMute,
      hasVideoCapability: true,
      data: update.data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      metadata: metadata,
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
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;

    await _notificationManager.onGoingCall(
      uuid,
      callerId: update.localizedName,
      callType: update.callType,
      holding: update.isHolding,
      muted: update.isMuted,
      enableHoldAction: capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: update.data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      metadata: metadata,
    );

    return update;
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
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;

    await _notificationManager.onGoingCall(
      uuid,
      callerId: update.localizedName,
      callType: update.callType,
      holding: update.isHolding,
      muted: update.isMuted,
      enableHoldAction: update.capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: update.capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: update.data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      metadata: metadata,
    );

    return update;
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

    // final oldStatus = call.state;
    // if (callStatus == CallState.hold) {
    //   if (oldStatus == CallState.initiated) {
    //     return call;
    //   } else if (oldStatus == CallState.dialing) {
    //     if (!call.hasCapabilitySupportsHold) {
    //       printDebug("Hold not supported in dialing state. Please enable it with CallKitCapability.supportHold.", tag: tag);
    //     }
    //   } else if (oldStatus == CallState.ringing) {
    //     printDebug("Cannot hold incoming call.", tag: tag);
    //   } else if (oldStatus == CallState.disconnecting) {
    //     printDebug("Cannot hold call in disconnecting state.", tag: tag);
    //     return call;
    //   }
    //
    //   switch (oldStatus) {
    //     case CallState.initiated:
    //       // TODO: Handle this case.
    //       break;
    //     case CallState.ringing:
    //       printDebug("Cannot hold incoming call.", tag: tag);
    //       break;
    //     case CallState.dialing:
    //       if (!call.hasCapabilitySupportsHold) {
    //         printDebug("Hold not supported in dialing state. Please enable it with CallKitCapability.supportHold.", tag: tag);
    //       }
    //       break;
    //     case CallState.active:
    //       // TODO: Handle this case.
    //       break;
    //     case CallState.hold:
    //       // TODO: Handle this case.
    //       break;
    //     default:
    //       printDebug("Cannot hold call in ${oldStatus.name} state.", tag: tag);
    //       return call;
    //   }
    // }

    final update = call.copyWith(state: callStatus);
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;

    await _notificationManager.onGoingCall(
      uuid,
      callerId: update.localizedName,
      callType: update.callType,
      holding: update.isHolding,
      muted: update.isMuted,
      enableHoldAction: update.capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: update.capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: update.data,
      onCallProvider: _getCall,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      stateOverride: callStatus,
      metadata: metadata,
    );

    return update;
  }

  @override
  Future<CKCall?> updateCallType(String uuid, {required CallType callType}) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return null;
    }

    if (callType == CallType.video) {
      if (!call.hasCapabilityVideo) {
        printWarning("Video call not supported. Please enable it with CallKitCapability.video.", tag: tag, debugOverride: true);
        _notificationManager.repost(uuid: call.uuid);
        return call;
      }
    }

    final update = call.copyWith(callType: callType);
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;

    await _notificationManager.onGoingCall(
      uuid,
      callerId: update.localizedName,
      callType: callType,
      holding: update.isHolding,
      muted: update.isMuted,
      enableHoldAction: update.capabilities.contains(CallKitCapability.supportHold),
      enableMuteAction: update.capabilities.contains(CallKitCapability.mute),
      hasVideoCapability: true,
      data: update.data,
      timer: _configuration.timer.enabled,
      timerStartOnState: _configuration.timer.startOnState,
      onCallProvider: _getCall,
      metadata: metadata,
    );

    return update;
  }

  @override
  Iterable<CKCall> getCalls() {
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
  CKCall? getCall(String uuid) {
    return _callManager.calls[uuid];
  }

  Future<void> _onCallAction(CKCallResult result, ActionSource source) async {
    final call = _callManager.getCall(result.uuid);
    final callState = call?.state;
    switch (result.action) {
      case CKCallAction.none:
        // do nothing
        break;

      case CKCallAction.answer:
        if (callState != CallState.ringing) {
          printDebug("Call not in ringing state. Ignoring answer action.", tag: tag);
          return;
        }
        printDebug("Call answered: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, CKCallAction.answer, source);
        break;

      case CKCallAction.decline:
        if (callState != CallState.ringing) {
          printDebug("Call not in ringing state. Ignoring decline action.", tag: tag);
          return;
        }
        printDebug("Call declined: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, CKCallAction.decline, source);
        break;

      case CKCallAction.hangUp:
        switch (call?.state) {
          case CallState.initiated:
          case CallState.dialing:
            _onDisconnectListener?.call(result.uuid, DisconnectResponse.canceled, source);
            break;
          case CallState.active:
          case CallState.reconnecting:
            _onDisconnectListener?.call(result.uuid, DisconnectResponse.local, source);
            break;
          case CallState.disconnecting:
            _onDisconnectListener?.call(result.uuid, DisconnectResponse.local, source);
            break;
          case CallState.disconnected:
          default:
            printDebug("Call not in valid state. Ignoring hangup action. State: $callState", tag: tag);
            break;
        }
        break;

      case CKCallAction.callback:
        printDebug("Call callback: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, CKCallAction.callback, source);
        break;

      case CKCallAction.switchVideo:
        _onCallTypeChange(result, callType: CallType.video, source: source);
        break;

      case CKCallAction.switchAudio:
        _onCallTypeChange(result, callType: CallType.audio, source: source);
        break;

      case CKCallAction.switchScreenShare:
        _onCallTypeChange(result, callType: CallType.screenShare, source: source);
        break;

      case CKCallAction.mute:
        printDebug("Call mute state: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, result.action, source);
        break;

      case CKCallAction.unmute:
        printDebug("Call unmute state: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, result.action, source);
        break;

      case CKCallAction.hold:
        printDebug("Call hold state: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, result.action, source);
        break;

      case CKCallAction.unhold:
        printDebug("Call unhold state: ${result.uuid}", tag: tag);
        _onCallActionListener?.call(result.uuid, result.action, source);
        break;

      case CKCallAction.dismiss:
        _dismissNotification(result.uuid);
        break;

      // default:
      //   printDebug("Unknown action: ${result.action}", tag: tag);
      //   break;
    }
  }

  Future<void> _onCallEvent(CallEvent event) async {
    final call = event.call;
    // ignore: unused_local_variable
    final id = call.uuid;
    printDebug(event);

    switch (event.type) {
      case CallEventType.add:
        // report new call

        // ignore: unused_local_variable
        final call = event.call;

        break;

      case CallEventType.update:
        // report call update

        // ignore: unused_local_variable
        final call = event.call;
        break;

      case CallEventType.remove:
        // dismiss/remove notification
        // ignore: unused_local_variable
        final call = event.call;
        _notificationManager.dismiss(uuid: event.uuid);
        if (event is DisconnectCallEvent) {
          _onDisconnectListener?.call(event.uuid, event.response, ActionSource.api);
        }
        break;
    }

    _onCallEventListener?.call(event, ActionSource.notification);

    // final sound = _configuration.sounds.enabled ? _configuration.sounds.sounds[call.state] : null;
    // switch (call.state) {
    //   case CallState.initiated:
    //   // Do nothing
    //     break;
    //   case CallState.ringing:
    //     final hasOngoingCall = _callManager.calls.values.any((element) => element.cal,);
    //     if (!_callManager.hasActiveCalls) {
    //       // TODO - play incoming call notification sound instead of ringtone
    //     } else {
    //       _audioManager.play(sound ?? AudioPlayer.defaultIncomingUrl);
    //     }
    //     break;
    //   case CallState.dialing:
    //   // AudioManager play dialing sound
    //     _audioManager.play(sound ?? AudioPlayer.defaultDialingUrl);
    //     break;
    //   case CallState.active:
    //   // Do nothing
    //     break;
    //   case CallState.hold:
    //   // AudioManager play holding sound
    //     if (!_callManager.hasActiveCalls) {
    //       // TODO - play incoming call notification sound instead of ringtone
    //       _audioManager.play(url)
    //     } else {
    //       _audioManager.play(sound ?? AudioPlayer.defaultHoldUrl);
    //     }
    //     break;
    //   case CallState.disconnecting:
    //     _audioManager.play(sound ?? AudioPlayer.defaultHoldUrl);
    //     break;
    //   case CallState.disconnected:
    //   // AudioManager play call ended sound
    //     break;
    // }
  }

  Future<void> dispose() {
    final futures = [
      _tapStreamSubscription?.cancel(),
      _actionStreamSubscription?.cancel(),
      _dismissStreamSubscription?.cancel(),
      _callManagerStreamSubscription?.cancel(),
    ].whereType<Future<void>>();
    return Future.wait(futures);
  }

  void _onCallTypeChange(
    CKCallResult result, {
    required CallType callType,
    ActionSource source = ActionSource.notification,
  }) {
    printDebug("Call type changed: ${result.uuid}", tag: tag);
    // TODO - check all call states
    final call = _callManager.getCall(result.uuid);
    if (call != null) {
      final event = CallEvent.update(call);
      _onCallTypeChangeListener?.call(event, callType, source);
    } else {
      printDebug("_onCallTypeChange: Call not found: ${result.uuid}", tag: tag);
    }
  }

  void _dismissNotification(String tag) {
    printDebug("Dismissing notification: $tag", tag: tag);
    _notificationManager.dismiss(uuid: tag);
  }

  @override
  Future<void> updateCallMetadata(String uuid, {required Map<String, dynamic> metadata}) async {
    final n = _notificationManager.getNotification(uuid);
    if (n == null) {
      printDebug("Notification not found: $uuid", tag: tag);
      return;
    }

    final notification = n.copyWith(metadata: metadata);
    return _notificationManager.add(notification);
  }

  @override
  Future<void> renotify(String uuid, {bool silent = false}) {
    return _notificationManager.repost(uuid: uuid);
  }

  @override
  void setConfiguration(CKConfiguration configuration) {
    _configuration = configuration;
  }

  @override
  void setOnCallActionHandler(OnCallActionListener onCallActionListener) {
    _onCallActionListener = onCallActionListener;
  }

  @override
  void setOnCallEventListener(OnCallEventListener onCallEventListener) {
    _onCallEventListener = onCallEventListener;
  }

  @override
  void setOnDisconnectListener(OnDisconnectListener onDisconnectListener) {
    _onDisconnectListener = onDisconnectListener;
  }

  @override
  void setOnCallTypeChangeListener(OnCallTypeChangeListener onCallTypeChangeListener) {
    _onCallTypeChangeListener = onCallTypeChangeListener;
  }

  @override
  void setOnDismissedListener(OnDismissedListener onDismissedListener) {
    _onDismissedListener = onDismissedListener;
  }

  @override
  CKNotification? getNotification(String uuid) {
    return _notificationManager.getNotification(uuid);
  }
}
