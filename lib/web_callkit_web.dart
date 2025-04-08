// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:simple_print/simple_print.dart';
import 'package:web_callkit/src/lib/call_timer.dart';
import 'package:web_callkit/src/models/call/ck_call_event.dart';
import 'package:web_callkit/src/models/notification/ck_notification.dart';
import 'package:web_callkit/src/models/notification/ck_notification_action.dart';

import 'src/core/const.dart';
import 'src/core/enums/ck_action_source.dart';
import 'src/core/enums/ck_call_action.dart';
import 'src/core/enums/ck_call_attributes.dart';
import 'src/core/enums/ck_call_event_type.dart';
import 'src/core/enums/ck_call_state.dart';
import 'src/core/enums/ck_call_type.dart';
import 'src/core/enums/ck_capability.dart';
import 'src/core/enums/ck_disconnect_response.dart';
import 'src/managers/calls/call_manager.dart';
import 'src/managers/notifications/notification_manager.dart';
import 'src/managers/notifications/notification_manager_impl_web.dart';
import 'src/models/call/ck_call.dart';
import 'src/models/call/ck_call_result.dart';
import 'src/models/config/ck_configuration.dart';
import 'src/platform_interface/web_callkit_platform_interface.dart';
import 'src/utils/utils.dart';

export 'src/src.dart';

/// A web implementation of the WebCallkitPlatform of the WebCallkit plugin.
class WebCallkitWeb extends WebCallkitPlatform {
  static const tag = 'web_callkit';

  static final WebCallkitWeb _instance = WebCallkitWeb._internal();

  static WebCallkitWeb get instance => _instance;

  static void registerWith(Registrar registrar) {
    WebCallkitPlatform.instance = _instance;
  }

  final Map<String, CallTimer> _timers = {};

  // late final AudioManager _audioManager;
  late final CallManager _callManager;
  late final NotificationManager _notificationManager;

  StreamSubscription<CKCallResult>? _tapStreamSubscription;
  StreamSubscription<CKCallResult>? _actionStreamSubscription;
  StreamSubscription<CKCallResult>? _dismissStreamSubscription;
  StreamSubscription<CKCallEvent>? _callManagerStreamSubscription;

  OnCallActionListener? _onCallActionListener;
  OnCallEventListener? _onCallEventListener;
  OnDisconnectListener? _onDisconnectListener;
  OnCallTypeChangeListener? _onCallTypeChangeListener;
  OnDismissedListener? _onDismissedListener;

  late CKConfiguration _configuration;
  final Map<String, bool> _defaultFlags = {
    NotificationManager.CK_EXTRA_PERSIST: true,
  };

  /// The method channel used to interact with the native platform.
  // @visibleForTesting
  // final methodChannel = const MethodChannel('web_callkit');
  factory WebCallkitWeb() {
    return _instance;
  }

  WebCallkitWeb._internal() {
    _callManager = CallManager();
    _notificationManager = NotificationManagerImplWeb();
    _configuration = WebCallkitPlatform.defaultConfiguration;

    _setupNotificationEventListeners();
    _callManager.setOnCallUpdate(_onCallUpdated);
  }

  void _onCallUpdated(String uuid, CKCall update, CKCall current) {
    if (current.state != update.state) {
      _onCallStatusChanged(uuid, update, current);
    }
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
    _onCallAction(result, CKActionSource.notification);
  }

  void _onDismissListener(CKCallResult result) {
    printDebug("Dismissed notification: ${result.uuid}", tag: NotificationManager.tag);
    final persist = result.containsFlag(NotificationManager.CK_EXTRA_PERSIST);
    if (result.uuid != null) {
      final uuid = result.uuid!;
      if (!persist) {
        _dismissNotification(uuid);
      } else {
        _onDismissedListener?.call(uuid, CKActionSource.notification);
      }
    } else {
      // case when uuid is null, e.g. group display
    }
  }

  void _onTapListener(CKCallResult result) {
    printDebug("Tapped notification: ${result.uuid}", tag: tag);
    _onCallAction(result, CKActionSource.notification);
  }

  @override
  Future<CKCall> reportIncomingCall({
    required String uuid,
    required String handle,
    Set<CKCapability>? capabilities,
    Set<CKCallAttributes>? attributes,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CKCallType callType = CKCallType.audio,
    CKCallState? stateOverride,
  }) async {
    final ckAttributes = attributes ?? _configuration.attributes;
    final ckCapabilities = capabilities ?? _configuration.capabilities;
    CKCall call = CKCall.init(
      uuid: uuid,
      localizedName: handle,
      attributes: ckAttributes,
      capabilities: ckCapabilities,
      callType: callType,
      data: data,
    ).copyWith(state: stateOverride ?? CKCallState.ringing);
    _callManager.addCall(call);

    final notification = _generateNotification(call: call, capabilities: capabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);
    return call;
  }

  @override
  Future<CKCall> reportOutgoingCall({
    required String uuid,
    required String handle,
    Set<CKCapability>? capabilities,
    Set<CKCallAttributes>? attributes,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CKCallType callType = CKCallType.audio,
  }) async {
    final ckAttributes = attributes ?? _configuration.attributes;
    final ckCapabilities = capabilities ?? _configuration.capabilities;
    CKCall call = CKCall.init(
      uuid: uuid,
      localizedName: handle,
      attributes: ckAttributes,
      capabilities: ckCapabilities,
      callType: callType,
      data: data,
    );
    _callManager.addCall(call);

    final notification = _generateNotification(call: call, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);
    return call;
  }

  @override
  Future<CKCall> reportOngoingCall({
    required String uuid,
    required String handle,
    Set<CKCapability>? capabilities,
    Set<CKCallAttributes>? attributes,
    Map<String, dynamic>? data,
    bool holding = false,
    CKCallType callType = CKCallType.audio,
    Map<String, dynamic>? metadata,
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

    final notification = _generateNotification(call: call, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);
    return call;
  }

  @override
  Future<void> reportCallDisconnected(
    String uuid, {
    required CKDisconnectResponse response,
  }) async {
    // state check for response
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call with uuid: $uuid not found.", tag: tag);
      return;
    }
    if (_configuration.strictMode) {
      final validResponses = validCallStateDisconnectResponses[call.state] ?? CKDisconnectResponse.values;
      if (!validResponses.contains(response)) {
        printWarning("Invalid response for call state: ${call.state}", tag: tag);
        return;
      }
    } else {
      printDebug("Strict mode disabled. Ignoring valid disconnect call state check.", tag: tag);
    }
    _callManager.removeCall(uuid, response: response);
  }

  @override
  Future<CKCall?> updateCallAttributes(
    String uuid, {
    required Set<CKCallAttributes> attributes,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call with uuid: $uuid not found.", tag: tag);
      return null;
    }

    // Moderate attributes based on call state and capabilities.
    Set<CKCallAttributes> moderatedAttributes = {};
    for (var value in attributes) {
      switch (value) {
        case CKCallAttributes.mute:
          final hasCapability = call.capabilities.contains(CKCapability.mute);
          if (!hasCapability) {
            printDebug("Mute attribute not supported. Please enable it with CKCapability.mute.", tag: tag);
          } else {
            moderatedAttributes.add(value);
          }
        case CKCallAttributes.hold:
          final hasCapabilityHold = call.capabilities.contains(CKCapability.hold);
          final hasCapabilitySupportHold = call.capabilities.contains(CKCapability.supportHold);
          // if call state is initiated or dialing, we can hold with support hold capability.
          // if call is active, we can hold with hold attribute.

          if (!hasCapabilityHold && !hasCapabilitySupportHold) {
            printDebug("Hold attribute not supported. Please enable it with CKCapability.supportHold or CKCapability.hold.", tag: tag);
          } else {
            switch (call.state) {
              case CKCallState.initiated:
              case CKCallState.dialing:
                if (hasCapabilitySupportHold) {
                  moderatedAttributes.add(value);
                } else {
                  printDebug("Hold attribute not supported in current state: ${call.state}", tag: tag);
                }
                break;
              case CKCallState.active:
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
    final ckCapabilities = update.capabilities;

    final notification = _generateNotification(call: update, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);

    return update;
  }

  @override
  Future<CKCall?> updateCallCapabilities(
    String uuid, {
    required Set<CKCapability> capabilities,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call with uuid: $uuid not found.", tag: tag);
      return Future.value();
    }

    final update = call.copyWith(capabilities: capabilities);
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;
    final ckCapabilities = update.capabilities;

    final notification = _generateNotification(call: update, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);

    return update;
  }

  @override
  Future<CKCall?> updateCallData(
    String uuid, {
    required Map<String, dynamic> data,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call with uuid: $uuid not found.", tag: tag);
      return null;
    }

    final update = call.copyWith(data: data);
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;
    final ckCapabilities = update.capabilities;

    final notification = _generateNotification(call: update, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);

    return update;
  }

  @override
  Future<CKCall?> updateCallStatus(
    String uuid, {
    required CKCallState callStatus,
  }) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call with uuid: $uuid not found.", tag: tag);
      return null;
    }

    // final oldStatus = call.state;
    // if (callStatus == CKCKCallState.hold) {
    //   if (oldStatus == CKCKCallState.initiated) {
    //     return call;
    //   } else if (oldStatus == CKCKCallState.dialing) {
    //     if (!call.hasCapabilitySupportsHold) {
    //       printDebug("Hold not supported in dialing state. Please enable it with CKCapability.supportHold.", tag: tag);
    //     }
    //   } else if (oldStatus == CKCKCallState.ringing) {
    //     printDebug("Cannot hold incoming call.", tag: tag);
    //   } else if (oldStatus == CKCKCallState.disconnecting) {
    //     printDebug("Cannot hold call in disconnecting state.", tag: tag);
    //     return call;
    //   }
    //
    //   switch (oldStatus) {
    //     case CKCKCallState.initiated:
    //       // TODO: Handle this case.
    //       break;
    //     case CKCKCallState.ringing:
    //       printDebug("Cannot hold incoming call.", tag: tag);
    //       break;
    //     case CKCKCallState.dialing:
    //       if (!call.hasCapabilitySupportsHold) {
    //         printDebug("Hold not supported in dialing state. Please enable it with CKCapability.supportHold.", tag: tag);
    //       }
    //       break;
    //     case CKCKCallState.active:
    //       // TODO: Handle this case.
    //       break;
    //     case CKCKCallState.hold:
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
    final ckCapabilities = update.capabilities;

    final notification = _generateNotification(call: update, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);

    return update;
  }

  @override
  Future<CKCall?> updateCallType(String uuid, {required CKCallType callType}) async {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      printDebug("Call with uuid: $uuid not found.", tag: tag);
      return null;
    }

    if (callType == CKCallType.video) {
      if (!call.hasCapabilityVideo) {
        printWarning("Video call not supported. Please enable it with CKCapability.video.", tag: tag, debugOverride: true);
        // _notificationManager.repost(uuid: call.uuid);
        return call;
      }
    }

    final update = call.copyWith(callType: callType);
    _callManager.updateCall(update);
    final metadata = _notificationManager.getNotification(uuid)?.metadata;
    final ckCapabilities = update.capabilities;

    final notification = _generateNotification(call: update, capabilities: ckCapabilities, metadata: metadata);
    await _notificationManager.add(notification, flags: _defaultFlags);

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
  Stream<CKCallEvent> get eventStream {
    return _callManager.eventStream;
  }

  @override
  CKCall? getCall(String uuid) {
    return _callManager.calls[uuid];
  }

  Future<void> _onCallAction(CKCallResult result, CKActionSource source) async {
    if (result.uuid != null) {
      final uuid = result.uuid!;
      final call = _callManager.getCall(uuid);
      final callState = call?.state;
      switch (result.action) {
        case CKCallAction.none:
          printDebug("Call Action: none: $uuid", tag: tag);
          // do nothing
          break;

        case CKCallAction.answer:
          printDebug("Call Action: answered: $uuid", tag: tag);
          if (callState != CKCallState.ringing) {
            printDebug("Call not in ringing state. Ignoring answer action.", tag: tag);
            return;
          }
          printDebug("Call answered: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, CKCallAction.answer, source);
          break;

        case CKCallAction.decline:
          printDebug("Call Action: declined: $uuid", tag: tag);
          if (callState != CKCallState.ringing) {
            printDebug("Call not in ringing state. Ignoring decline action.", tag: tag);
            return;
          }
          printDebug("Call declined: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, CKCallAction.decline, source);
          break;

        case CKCallAction.hangUp:
          printDebug("Call Action: hangup: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, CKCallAction.hangUp, source);

          // notify Disconnect Listener
          switch (call?.state) {
            case CKCallState.initiated:
            case CKCallState.dialing:
              _onDisconnectListener?.call(uuid, CKDisconnectResponse.canceled, source);
              break;
            case CKCallState.active:
            case CKCallState.reconnecting:
              _onDisconnectListener?.call(uuid, CKDisconnectResponse.local, source);
              break;
            case CKCallState.disconnecting:
              _onDisconnectListener?.call(uuid, CKDisconnectResponse.local, source);
              break;
            case CKCallState.disconnected:
            default:
              printDebug("Call not in valid state. Ignoring hangup action. State: $callState", tag: tag);
              break;
          }
          break;

        case CKCallAction.callback:
          printDebug("Call Action: callback: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, CKCallAction.callback, source);
          break;

        case CKCallAction.switchVideo:
          printDebug("Call Action: switch video: $uuid", tag: tag);
          _onCallTypeChange(result, callType: CKCallType.video, source: source);
          break;

        case CKCallAction.switchAudio:
          printDebug("Call Action: switch audio: $uuid", tag: tag);
          _onCallTypeChange(result, callType: CKCallType.audio, source: source);
          break;

        case CKCallAction.switchScreenShare:
          printDebug("Call Action: switch screen share: $uuid", tag: tag);
          _onCallTypeChange(result, callType: CKCallType.screenShare, source: source);
          break;

        case CKCallAction.mute:
          printDebug("Call Action: mute: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, result.action, source);
          break;

        case CKCallAction.unmute:
          printDebug("Call Action: unmute: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, result.action, source);
          break;

        case CKCallAction.hold:
          printDebug("Call Action; hold: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, result.action, source);
          break;

        case CKCallAction.unhold:
          printDebug("Call Action: unhold: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, result.action, source);
          break;

        case CKCallAction.dismiss:
          printDebug("Call Action: dismiss: $uuid", tag: tag);
          _dismissNotification(uuid);
          break;

        case CKCallAction.silence:
          printDebug("Call Action: silence: $uuid", tag: tag);
          if (callState != CKCallState.ringing) {
            printDebug("Call not in ringing state. Ignoring silence action.", tag: tag);
            return;
          }
          renotify(uuid, silent: true);
          _onCallActionListener?.call(uuid, CKCallAction.silence, source);
          break;

        case CKCallAction.disableVideo:
          printDebug("Call Action: disable video: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, CKCallAction.disableVideo, source);
          break;

        case CKCallAction.enableVideo:
          printDebug("Call Action: enable video: $uuid", tag: tag);
          _onCallActionListener?.call(uuid, CKCallAction.enableVideo, source);
          break;
      }
    } else {
      printDebug("Call Action: uuid is null", tag: tag);
    }
  }

  Future<void> _onCallEvent(CKCallEvent event) async {
    printDebug("Call Event: ${event.type}", tag: tag);
    final call = event.call;
    // ignore: unused_local_variable
    final id = call.uuid;

    switch (event.type) {
      case CKCallEventType.add:
        printDebug("Call Event: add: ${event.uuid}", tag: tag);

        // ignore: unused_local_variable
        final call = event.call;

        break;

      case CKCallEventType.update:
        printDebug("Call Event: update: ${event.uuid}", tag: tag);

        // ignore: unused_local_variable
        final call = event.call;
        break;

      case CKCallEventType.remove:
        printDebug("Call Event: remove: ${event.uuid}", tag: tag);
        // dismiss/remove notification
        // ignore: unused_local_variable
        final call = event.call;
        _notificationManager.dismiss(uuid: event.uuid);
        if (event is DisconnectCallEvent) {
          _onDisconnectListener?.call(event.uuid, event.response, CKActionSource.api);
        }
        _stopCallTimer(id);
        break;
    }

    _onCallEventListener?.call(event, CKActionSource.notification);

    // final sound = _configuration.sounds.enabled ? _configuration.sounds.sounds[call.state] : null;
    // switch (call.state) {
    //   case CKCKCallState.initiated:
    //   // Do nothing
    //     break;
    //   case CKCKCallState.ringing:
    //     final hasOngoingCall = _callManager.calls.values.any((element) => element.cal,);
    //     if (!_callManager.hasActiveCalls) {
    //       // TODO - play incoming call notification sound instead of ringtone
    //     } else {
    //       _audioManager.play(sound ?? AudioPlayer.defaultIncomingUrl);
    //     }
    //     break;
    //   case CKCKCallState.dialing:
    //   // AudioManager play dialing sound
    //     _audioManager.play(sound ?? AudioPlayer.defaultDialingUrl);
    //     break;
    //   case CKCKCallState.active:
    //   // Do nothing
    //     break;
    //   case CKCKCallState.hold:
    //   // AudioManager play holding sound
    //     if (!_callManager.hasActiveCalls) {
    //       // TODO - play incoming call notification sound instead of ringtone
    //       _audioManager.play(url)
    //     } else {
    //       _audioManager.play(sound ?? AudioPlayer.defaultHoldUrl);
    //     }
    //     break;
    //   case CKCKCallState.disconnecting:
    //     _audioManager.play(sound ?? AudioPlayer.defaultHoldUrl);
    //     break;
    //   case CKCKCallState.disconnected:
    //   // AudioManager play call ended sound
    //     break;
    // }
  }

  void _onCallStatusChanged(String uuid, CKCall update, CKCall current) {
    if (current.active && !update.active) {
      _stopCallTimer(uuid);
      return;
    }

    if (!current.active && update.active) {
      if (!_configuration.timer.enabled) {
        return;
      }
      if (_configuration.timer.startOnState != update.state) {
        return;
      }
      _startCallTimer(uuid);
    }
  }

  void _startCallTimer(String uuid) {
    final timer = CallTimer(
      onTimerTick: (tick) => _onTimerUpdate(uuid, tick),
    );
    timer.start();
    _timers[uuid] = timer;
  }

  void _stopCallTimer(String uuid) {
    final timer = _timers.remove(uuid);
    if (timer != null) {
      timer.stop();
    }
  }

  void _onTimerUpdate(String uuid, int duration) {
    final call = _callManager.getCall(uuid);
    if (call == null) {
      return;
    }
    final n = _notificationManager.getNotification(uuid);
    if (n == null) {
      return;
    }
    final update = _generateNotification(call: call, capabilities: call.capabilities, metadata: n.metadata);
    _notificationManager.add(update, flags: _defaultFlags);
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

  CKNotification _generateNotification({
    required CKCall call,
    Set<CKCapability>? capabilities,
    Map<String, dynamic>? metadata,
    //ignore: unused_element
    Duration? offset,
    bool? silent,
  }) {
    final title = _getTitle(call);
    final body = _getDescription(call);
    final actions = _getActions(call);
    final icon = _getIcon(call);

    final currentTime = DateTime.now();
    final notification = CKNotification.builder(
      uuid: call.uuid,
      title: title,
      body: body,
      actions: actions,
      icon: icon,
      silent: silent,
      requireInteraction: true,
      renotify: true,
      data: call.data,
      timestamp: currentTime.millisecondsSinceEpoch,
      metadata: metadata,
    );
    return notification;
  }

  String _getTitle(CKCall call) {
    return call.localizedName;
  }

  String _getDescription(CKCall call) {
    final type = call.callType;
    final state = call.state;

    String base = switch (type) {
      CKCallType.screenShare => type.name.capitalize(),
      _ => "${type.name.capitalize()} Call",
    };
    String description = "";

    switch (state) {
      case CKCallState.initiated:
        description = "Calling $base";
        break;
      case CKCallState.ringing:
        description = "Incoming $base";
        break;
      case CKCallState.dialing:
        description = "Dialing $base";
        break;
      case CKCallState.active:
        description = "Ongoing $base";
        final timestamp = _callManager.logs[call.uuid]?.firstWhereOrNull((element) => element.state == CKCallState.active)?.date;
        if (timestamp != null) {
          final elapsed = DateTime.now().getTimeDifference(timestamp);
          description += " ($elapsed)";
        }
        if (call.isHolding) {
          description = "$description (On Hold)";
        }
        if (call.isMuted) {
          description = "$description (Muted)";
        }
        break;
      case CKCallState.reconnecting:
        description = "$base (Reconnecting)";
        break;
      case CKCallState.disconnecting:
        description = "$base Ending...";
        break;
      case CKCallState.disconnected:
        description = "$base Ended";
        break;
    }

    return description;
  }

  List<CKNotificationAction> _getActions(CKCall call) {
    switch (call.state) {
      case CKCallState.initiated:
        return [
          _generateNotificationAction(CKCallAction.hangUp),
          if (call.hasCapabilityMute) _generateNotificationAction(CKCallAction.mute),
          if (call.isAudioOnly) ...[
            if (call.hasCapabilitySupportsHold) _generateNotificationAction(CKCallAction.hold),
          ] else ...[
            _generateNotificationAction(CKCallAction.switchAudio),
          ],
        ];
      case CKCallState.ringing:
        return [
          _generateNotificationAction(CKCallAction.answer),
          CKNotificationAction.fromNotificationAction(CKCallAction.decline),
          if (call.hasCapabilitySilence) _generateNotificationAction(CKCallAction.silence),
        ];
      case CKCallState.dialing:
        return [
          _generateNotificationAction(CKCallAction.hangUp),
          if (call.hasCapabilityMute) _generateNotificationAction(CKCallAction.mute),
          if (call.isAudioOnly) ...[
            if (call.hasCapabilitySupportsHold) _generateNotificationAction(CKCallAction.hold),
          ] else ...[
            _generateNotificationAction(CKCallAction.switchAudio),
          ],
        ];
      case CKCallState.active:
        return [
          _generateNotificationAction(CKCallAction.hangUp),
        ];
      case CKCallState.reconnecting:
        return [
          _generateNotificationAction(CKCallAction.hangUp),
        ];
      case CKCallState.disconnecting:
        return [
          _generateNotificationAction(CKCallAction.hangUp),
        ];
      case CKCallState.disconnected:
        return [
          _generateNotificationAction(CKCallAction.callback),
          _generateNotificationAction(CKCallAction.dismiss),
        ];
    }
  }

  CKNotificationAction _generateNotificationAction(CKCallAction action) {
    final icon = _configuration.icons[action];
    return CKNotificationAction.fromNotificationAction(action, icon: icon);
  }

  String? _getIcon(CKCall call) {
    return null;
  }

  void _onCallTypeChange(
    CKCallResult result, {
    required CKCallType callType,
    CKActionSource source = CKActionSource.notification,
  }) {
    if (result.uuid != null) {
      final uuid = result.uuid!;
      printDebug("Call type changed: ${result.uuid}", tag: tag);
      // TODO - check all call states
      final call = _callManager.getCall(uuid);
      if (call != null) {
        final event = CKCallEvent.update(call);
        _onCallTypeChangeListener?.call(event, callType, source);
      } else {
        printDebug("_onCallTypeChange: Call not found: $uuid}", tag: tag);
      }
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
    return _notificationManager.add(notification, flags: _defaultFlags);
  }

  @override
  Future<void> renotify(String uuid, {bool silent = false}) async {
    printDebug("Renotify: $uuid", tag: tag);
    final n = _notificationManager.getNotification(uuid);
    if (n == null) {
      printDebug("Notification not found: $uuid", tag: tag);
      return;
    }
    final jsNotification = n.notification;
    final jsOptions = jsNotification.options?.copyWith(silent: silent, requireInteraction: false);
    final update = n.copyWith(notification: jsNotification.copyWith(options: jsOptions));
    return _notificationManager.add(update);
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

  @override
  Future<bool> hasPermissions() => _notificationManager.hasPermissions();

  @override
  Future<bool> requestPermissions() => _notificationManager.requestPermissions();
}
