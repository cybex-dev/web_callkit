import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_callkit/src/core/enums/enums.dart';
import 'package:web_callkit/src/method_channel/web_callkit_method_channel.dart';
import 'package:web_callkit/src/models/ck_call.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelWebCallkit platform = MethodChannelWebCallkit();
  const MethodChannel channel = MethodChannel('web_callkit');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group("CKCall", () {
    test('CKCall init', () async {
      const id = "123";
      const name = "call name";
      final call = CKCall.init(uuid: id, localizedName: name);
      expect(call.uuid, id, reason: 'Call uuid should be $id');
      expect(call.localizedName, name, reason: 'Call name should be $name');
      expect(call.dateStarted, isNotNull,
          reason: 'Call dateStarted should not be null');
      expect(call.dateUpdated, isNotNull,
          reason: 'Call dateUpdated should not be null');
      expect(call.attributes, isNotNull,
          reason: 'Call attributes should not be null');
      expect(call.callType, CallType.audio,
          reason: 'Call callType should be audio');
      expect(call.state, CallState.initiated,
          reason: 'Call state should be initiated');
    });

    test('CKCall update uuid', () async {
      const id = "123";
      const newId = "456";
      final call = CKCall.init(uuid: id, localizedName: 'handle');
      final call2 = CKCall.init(uuid: newId, localizedName: 'handle');
      final updatedCall = call.update(call2);
      expect(updatedCall.uuid, newId, reason: 'Call uuid should be 123');
    });

    test('CKCall copyWith localizedName', () async {
      const id = "123";
      const oldName = "call name";
      const newName = "new call name";
      final call = CKCall.init(uuid: id, localizedName: oldName);
      final copyWith = call.copyWith(localizedName: newName);
      expect(copyWith.localizedName, newName,
          reason: 'Copied call localizedName should be $newName');
    });

    test('CKCall copyWith dateStarted', () async {
      const id = "123";
      final call = CKCall.init(uuid: id, localizedName: 'handle');
      final dateStarted = call.dateStarted;
      final copyWith = call.copyWith(dateStarted: DateTime.now());
      final newDateStarted = copyWith.dateStarted;
      expect(dateStarted, isNot(newDateStarted),
          reason: 'Call dateStarted should not be equal to new dateStarted');
    });

    test('CKCall copyWith dateUpdated', () async {
      const id = "123";
      final call = CKCall.init(uuid: id, localizedName: 'handle');
      final updated = call.dateUpdated.add(const Duration(seconds: 10));
      final copyWith = call.copyWith(dateUpdated: updated);
      expect(call.dateStarted, call.dateUpdated,
          reason: 'Call dateStarted should be equal to dateUpdated');
      expect(copyWith.dateUpdated, updated,
          reason: 'Copied call dateUpdated should be updated');
    });

    test('CKCall copyWith attributes', () async {
      const id = "123";
      final attributes = <CallAttributes>{};
      final call = CKCall.init(
          uuid: id, localizedName: 'handle', attributes: attributes);
      final copyWith = call.copyWith(attributes: {CallAttributes.hold});
      expect(call.attributes, <CallAttributes>{},
          reason: 'Call attributes should be empty');
      expect(copyWith.attributes, {CallAttributes.hold},
          reason: 'Copied call attributes should be {CallAttributes.hold}');
    });

    test('CKCall copyWith attributes without', () async {
      const id = "123";
      final attributes = <CallAttributes>{CallAttributes.hold};
      final call = CKCall.init(
          uuid: id, localizedName: 'handle', attributes: attributes);
      final copyWith = call.copyWith(attributes: {});
      expect(call.attributes, <CallAttributes>{CallAttributes.hold},
          reason: 'Call attributes should be {CallAttributes.hold}');
      expect(copyWith.attributes, <CallAttributes>{},
          reason: 'Copied call attributes should be {}');
    });

    test('CKCall copyWith CallType.audio to CallType.video', () async {
      const id = "123";
      final call = CKCall.init(
          uuid: id, localizedName: 'handle', callType: CallType.audio);
      final copyWith = call.copyWith(callType: CallType.video);
      expect(call.callType, CallType.audio,
          reason: 'Call callType should be audio');
      expect(copyWith.callType, CallType.video,
          reason: 'Copied call callType should be video');
    });

    test('CKCall copyWith CallState.initiated to CallState.ringing', () async {
      const id = "123";
      final call = CKCall.init(uuid: id, localizedName: 'handle');
      final copyWith = call.copyWith(state: CallState.ringing);
      expect(call.state, CallState.initiated,
          reason: 'Call callType should be initiated');
      expect(copyWith.state, CallState.ringing,
          reason: 'Copied call callType should be ringing');
    });
  });

  group("Web Callkit", () {
    group("reportNewCall", () {
      test('new call', () async {
        await platform.reportIncomingCall(
          uuid: '123',
          handle: 'handle',
        );

        final call = platform.getCall('123');
        expect(call, isNotNull, reason: 'Call should not be null');
        expect(call!.uuid, '123', reason: 'Call uuid should be 123');
      });
    });

    group("updateCallAttributes", () {
      test('updateCallAttributes: does not exist', () async {
        await platform
            .updateCallAttributes('123', attributes: {CallAttributes.hold});
        final call = platform.getCall('123');
        expect(call, isNull, reason: 'Call should be null');
      });

      test('updateCallAttributes: perform hold toggle', () async {
        const id = "123";
        await platform.reportIncomingCall(uuid: id, handle: 'handle');
        final call = platform.getCall(id);

        await platform
            .updateCallAttributes(id, attributes: {CallAttributes.hold});
        final holding = platform.getCall(id);

        await platform.updateCallAttributes(id, attributes: {});
        final notholding = platform.getCall(id);

        expect(call, isNotNull, reason: 'Call should not be null');
        expect(call!.isHolding, false, reason: 'Call should not be holding');
        expect(holding!.isHolding, true, reason: 'Call should be holding');
        expect(notholding!.isHolding, true,
            reason: 'Call should not be holding');
      });
    });

    group("updateCallData", () {});

    group("updateCallStatus", () {
      test('updateCallStatus: does not exist', () async {
        await platform.updateCallStatus('123', callStatus: CallState.active);
        final call = platform.getCall('123');
        expect(call, isNull, reason: 'Call should be null');
      });

      test('updateCallStatus: ringing to active to ended', () async {
        const id = "123";
        await platform.reportIncomingCall(uuid: id, handle: 'handle');
        final call = platform.getCall(id);

        await platform.updateCallStatus(id, callStatus: CallState.active);
        final active = platform.getCall(id);

        await platform.updateCallStatus(id, callStatus: CallState.disconnected);
        final disconnected = platform.getCall(id);

        expect(call, isNotNull, reason: 'Call should not be null');
        expect(call!.uuid, '123', reason: 'Call uuid should be "123"');
        expect(call.localizedName, "handle",
            reason: 'Call handle should be "handle"');

        expect(active, isNotNull, reason: 'Call active should not be null');
        expect(active!.state, CallState.active,
            reason: 'Call state should be active');

        expect(disconnected, isNotNull,
            reason: 'Call disconnected should not be null');
        expect(disconnected!.state, CallState.disconnected,
            reason: 'Call state should be disconnected');
      });
    });
  });
}
