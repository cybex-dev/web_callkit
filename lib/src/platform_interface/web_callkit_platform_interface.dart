import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../core/core.dart';
import '../method_channel/web_callkit_method_channel.dart';
import '../models/models.dart';

typedef OnDisconnectListener = void Function(
    String uuid, DisconnectResponse response, ActionSource source);
typedef OnCallTypeChangeListener = void Function(
    CallEvent event, CallType callType, ActionSource source);
typedef OnCallEventListener = void Function(
    CallEvent event, ActionSource source);
typedef OnCallActionListener = void Function(
    String uuid, CKCallAction action, ActionSource source);
typedef OnDismissedListener = void Function(String uuid, ActionSource source);

abstract class WebCallkitPlatform extends PlatformInterface {
  static const defaultConfiguration = CKConfiguration(
    sounds: CKSounds(),
    capabilities: {
      CallKitCapability.supportHold,
      CallKitCapability.mute,
    },
    attributes: {},
    timer: CKTimer(),
  );

  WebCallkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebCallkitPlatform _instance = MethodChannelWebCallkit();

  // Getter for the singleton instance
  static WebCallkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WebCallkitPlatform] when
  /// they register themselves.
  static set instance(WebCallkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the callkit with the configuration.
  void setConfiguration(CKConfiguration configuration);

  void setOnDisconnectListener(OnDisconnectListener onDisconnectListener);

  void setOnCallEventListener(OnCallEventListener onCallEventListener);

  void setOnCallActionHandler(OnCallActionListener onCallActionListener);

  void setOnCallTypeChangeListener(
      OnCallTypeChangeListener onCallTypeChangeListener);

  void setOnDismissedListener(OnDismissedListener onDismissedListener);

  /// Register an incoming call with the kit. This adds a new call to the callkit UI and handles according to call lifecycle defined in [CallState].
  Future<CKCall> reportIncomingCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
    CallState? stateOverride,
  });

  /// Register a new call with the kit. This adds a new call to the callkit UI and handles according to call lifecycle defined in [CallState].
  Future<CKCall> reportOutgoingCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
  });

  /// Register an ongoing call with the kit. This adds a new call to the callkit UI and handles according to call lifecycle defined in [CallState].
  Future<CKCall> reportOngoingCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
    bool holding = false,
    CallType callType = CallType.audio,
  });

  /// Update the call status of a call in the callkit UI.
  Future<CKCall?> updateCallStatus(
    String uuid, {
    required CallState callStatus,
  });

  /// Update the call type of a call in the callkit UI.
  Future<CKCall?> updateCallType(
    String uuid, {
    required CallType callType,
  });

  /// Report that a call was disconnected with a response [DisconnectResponse].
  Future<void> reportCallDisconnected(
    String uuid, {
    required DisconnectResponse response,
  });

  /// Update the call attributes of a call in the callkit UI.
  Future<CKCall?> updateCallAttributes(
    String uuid, {
    required Set<CallAttributes> attributes,
  });

  /// Update the call capabilities of a call in the callkit UI.
  Future<CKCall?> updateCallCapabilities(
    String uuid, {
    required Set<CallKitCapability> capabilities,
  });

  /// Update the call data of a call in the callkit UI.
  Future<CKCall?> updateCallData(
    String uuid, {
    required Map<String, dynamic> data,
  });

  /// Update the call data of a call in the callkit UI.
  // Future<CKCall?> updateCallMetadata(
  Future<void> updateCallMetadata(
    String uuid, {
    required Map<String, dynamic> metadata,
  });

  Future<void> renotify(
    String uuid, {
    bool silent = false,
  });

  Stream<Iterable<CKCall>> get callStream;

  Stream<CallEvent> get eventStream;

  /// Get all calls currently in the callkit UI.
  Iterable<CKCall> getCalls();

  /// Get a call currently in the callkit UI.
  CKCall? getCall(String uuid);

  /// Get a call currently in the callkit UI.
  CKNotification? getNotification(String uuid);
}
