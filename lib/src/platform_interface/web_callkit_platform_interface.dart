import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../core/enums/ck_action_source.dart';
import '../core/enums/ck_call_action.dart';
import '../core/enums/ck_call_attributes.dart';
import '../core/enums/ck_call_state.dart';
import '../core/enums/ck_call_type.dart';
import '../core/enums/ck_capability.dart';
import '../core/enums/ck_disconnect_response.dart';
import '../method_channel/web_callkit_method_channel.dart';
import '../models/call/ck_call.dart';
import '../models/call/ck_call_event.dart';
import '../models/config/ck_configuration.dart';
import '../models/config/ck_sounds.dart';
import '../models/config/ck_timer.dart';
import '../models/notification/ck_notification.dart';

typedef OnDisconnectListener = void Function(String uuid, CKDisconnectResponse response, CKActionSource source);
typedef OnCallTypeChangeListener = void Function(CKCallEvent event, CKCallType callType, CKActionSource source);
typedef OnCallEventListener = void Function(CKCallEvent event, CKActionSource source);
typedef OnCallActionListener = void Function(String uuid, CKCallAction action, CKActionSource source);
typedef OnDismissedListener = void Function(String uuid, CKActionSource source);

abstract class WebCallkitPlatform extends PlatformInterface {
  static const tag = 'web_callkit';

  static const defaultConfiguration = CKConfiguration(
    sounds: CKSounds(),
    capabilities: {
      CKCapability.supportHold,
      CKCapability.mute,
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
    Set<CKCapability>? capabilities,
    Set<CKCallAttributes>? attributes,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CKCallType callType = CKCallType.audio,
    CKCallState? stateOverride,
  });

  /// Register a new call with the kit. This adds a new call to the callkit UI and handles according to call lifecycle defined in [CallState].
  Future<CKCall> reportOutgoingCall({
    required String uuid,
    required String handle,
    Set<CKCapability>? capabilities,
    Set<CKCallAttributes>? attributes,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    CKCallType callType = CKCallType.audio,
  });

  /// Register an ongoing call with the kit. This adds a new call to the callkit UI and handles according to call lifecycle defined in [CallState].
  Future<CKCall> reportOngoingCall({
    required String uuid,
    required String handle,
    Set<CKCapability>? capabilities,
    Set<CKCallAttributes>? attributes,
    Map<String, dynamic>? data,
    bool holding = false,
    CKCallType callType = CKCallType.audio,
    Map<String, dynamic>? metadata,
  });

  /// Update the call status of a call in the callkit UI.
  Future<CKCall?> updateCallStatus(
    String uuid, {
    required CKCallState callStatus,
  });

  /// Update the call type of a call in the callkit UI.
  Future<CKCall?> updateCallType(
    String uuid, {
    required CKCallType callType,
  });

  /// Report that a call was disconnected with a response [DisconnectResponse].
  Future<void> reportCallDisconnected(
    String uuid, {
    required CKDisconnectResponse response,
  });

  /// Update the call attributes of a call in the callkit UI.
  Future<CKCall?> updateCallAttributes(
    String uuid, {
    required Set<CKCallAttributes> attributes,
  });

  /// Update the call capabilities of a call in the callkit UI.
  Future<CKCall?> updateCallCapabilities(
    String uuid, {
    required Set<CKCapability> capabilities,
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

  Stream<CKCallEvent> get eventStream;

  /// Get all calls currently in the callkit UI.
  Iterable<CKCall> getCalls();

  /// Get a call currently in the callkit UI.
  CKCall? getCall(String uuid);

  /// Get a call currently in the callkit UI.
  CKNotification? getNotification(String uuid);

  /// Requests notification permissions from web browser
  Future<bool> requestPermissions();

  /// Check if the notification permissions are granted
  Future<bool> hasPermissions();
}
