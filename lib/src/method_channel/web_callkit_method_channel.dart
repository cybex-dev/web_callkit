import 'dart:async';

import '../core/enums/ck_call_type.dart';
import '../core/enums/ck_capability.dart';
import '../models/call/ck_call.dart';
import '../models/call/ck_call_event.dart';
import '../models/config/ck_configuration.dart';
import '../models/notification/ck_notification.dart';
import '../platform_interface/web_callkit_platform_interface.dart';

/// An implementation of [WebCallkitPlatform] that uses method channels.
class MethodChannelWebCallkit extends WebCallkitPlatform {
  @override
  // TODO: implement callStream
  Stream<Iterable<CKCall>> get callStream => throw UnimplementedError();

  @override
  // TODO: implement eventStream
  Stream<CKCallEvent> get eventStream => throw UnimplementedError();

  @override
  CKCall? getCall(String uuid) {
    // TODO: implement getCall
    throw UnimplementedError();
  }

  @override
  Iterable<CKCall> getCalls() {
    // TODO: implement getCalls
    throw UnimplementedError();
  }

  @override
  CKNotification? getNotification(String uuid) {
    // TODO: implement getNotification
    throw UnimplementedError();
  }

  @override
  Future<bool> hasPermissions() {
    // TODO: implement hasPermissions
    throw UnimplementedError();
  }

  @override
  Future<void> renotify(String uuid, {bool silent = false}) {
    // TODO: implement renotify
    throw UnimplementedError();
  }

  @override
  Future<void> reportCallDisconnected(String uuid, {required response}) {
    // TODO: implement reportCallDisconnected
    throw UnimplementedError();
  }

  @override
  Future<CKCall> reportIncomingCall({required String uuid, required String handle, Set<CKCapability>? capabilities, Set<dynamic>? attributes, Map<String, dynamic>? data, Map<String, dynamic>? metadata, callType = CKCallType.audio, stateOverride}) {
    // TODO: implement reportIncomingCall
    throw UnimplementedError();
  }

  @override
  Future<CKCall> reportOngoingCall({required String uuid, required String handle, Set<CKCapability>? capabilities, Set<dynamic>? attributes, Map<String, dynamic>? data, bool holding = false, callType = CKCallType.audio, Map<String, dynamic>? metadata}) {
    // TODO: implement reportOngoingCall
    throw UnimplementedError();
  }

  @override
  Future<CKCall> reportOutgoingCall({required String uuid, required String handle, Set<CKCapability>? capabilities, Set<dynamic>? attributes, Map<String, dynamic>? data, Map<String, dynamic>? metadata, callType = CKCallType.audio}) {
    // TODO: implement reportOutgoingCall
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPermissions() {
    // TODO: implement requestPermissions
    throw UnimplementedError();
  }

  @override
  void setConfiguration(CKConfiguration configuration) {
    // TODO: implement setConfiguration
  }

  @override
  void setOnCallActionHandler(OnCallActionListener onCallActionListener) {
    // TODO: implement setOnCallActionHandler
  }

  @override
  void setOnCallEventListener(OnCallEventListener onCallEventListener) {
    // TODO: implement setOnCallEventListener
  }

  @override
  void setOnCallTypeChangeListener(OnCallTypeChangeListener onCallTypeChangeListener) {
    // TODO: implement setOnCallTypeChangeListener
  }

  @override
  void setOnDisconnectListener(OnDisconnectListener onDisconnectListener) {
    // TODO: implement setOnDisconnectListener
  }

  @override
  void setOnDismissedListener(OnDismissedListener onDismissedListener) {
    // TODO: implement setOnDismissedListener
  }

  @override
  Future<CKCall?> updateCallAttributes(String uuid, {required Set<dynamic> attributes}) {
    // TODO: implement updateCallAttributes
    throw UnimplementedError();
  }

  @override
  Future<CKCall?> updateCallCapabilities(String uuid, {required Set<CKCapability> capabilities}) {
    // TODO: implement updateCallCapabilities
    throw UnimplementedError();
  }

  @override
  Future<CKCall?> updateCallData(String uuid, {required Map<String, dynamic> data}) {
    // TODO: implement updateCallData
    throw UnimplementedError();
  }

  @override
  Future<void> updateCallMetadata(String uuid, {required Map<String, dynamic> metadata}) {
    // TODO: implement updateCallMetadata
    throw UnimplementedError();
  }

  @override
  Future<CKCall?> updateCallStatus(String uuid, {required callStatus}) {
    // TODO: implement updateCallStatus
    throw UnimplementedError();
  }

  @override
  Future<CKCall?> updateCallType(String uuid, {required callType}) {
    // TODO: implement updateCallType
    throw UnimplementedError();
  }
}
