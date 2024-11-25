import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:web_callkit/src/managers/managers.dart';

import '../core/core.dart';
import '../models/models.dart';
import '../method_channel/web_callkit_method_channel.dart';

abstract class WebCallkitPlatform extends PlatformInterface {
  /// Constructs a WebCallkitPlatform.
  WebCallkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebCallkitPlatform _instance = MethodChannelWebCallkit();

  set configuration(CKConfiguration value);

  /// The default instance of [WebCallkitPlatform] to use.
  ///
  /// Defaults to [MethodChannelWebCallkit].
  static WebCallkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WebCallkitPlatform] when
  /// they register themselves.
  static set instance(WebCallkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Register a new call with the kit. This adds a new call to the callkit UI and handles according to call lifecycle defined in [CallState].
  Future<CKCall> reportNewCall({
    required String uuid,
    required String handle,
    Set<CallKitCapability>? capabilities,
    Set<CallAttributes>? attributes,
    Map<String, dynamic>? data,
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
  Future<void> reportCallDisconnected(String uuid, {required DisconnectResponse response});

  /// Update the call attributes of a call in the callkit UI.
  /// If data is provided, it will be merged with the existing data and overwrite any existing keys.
  Future<CKCall?> updateCallAttributes(
    String uuid, {
    required Set<CallAttributes> attributes,
    Map<String, dynamic>? data,
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

  Stream<Iterable<CKCall>> get callStream;

  Stream<CallEvent> get eventStream;

  /// Get all calls currently in the callkit UI.
  Future<Iterable<CKCall>> getCalls();

  /// Get a call currently in the callkit UI.
  Future<CKCall?> getCall(String uuid);

  Future<void> onCallAction(CKCallResult result);

  Future<void> onStateChange(CKCall call);
}
