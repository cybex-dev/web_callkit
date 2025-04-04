import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit_example/utils.dart';

import '../../widgets/ck_card.dart';
import '../../widgets/ck_call_log.dart';
import '../../widgets/text.dart';

class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app: Advanced Call'),
      ),
      body: Column(
        children: [
          const Expanded(
            child: _Content(),
          ),
          const Divider(),
          ConstrainedBox(
            constraints: BoxConstraints.expand(height: height * 0.25),
            child: CKCallLog(builder: CKCallLog.defaultBuilder),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatefulWidget {
  // ignore: unused_element
  const _Content({super.key});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final callId = "advancedCall";
  CKCall? _call;

  bool get _hasCall => _call != null;

  final webCallkitPlugin = WebCallkit.instance;
  late StreamSubscription<Iterable<CKCall>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = webCallkitPlugin.callStream.listen((event) {
      setState(() {
        _call = event.firstWhereOrNull((element) => element.uuid == callId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final capabilities = CKCapability.values.map((e) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: _hasCall
              ? () async {
                  final call = webCallkitPlugin.getCall(callId);
                  if (call == null) {
                    return;
                  }
                  final cap = call.capabilities.contains(e)
                      ? call.capabilities.removeWith(e)
                      : call.capabilities.addWith(e);
                  await webCallkitPlugin.updateCallCapabilities(callId,
                      capabilities: cap);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasCall && _call!.capabilities.contains(e)
                ? Colors.green
                : Colors.transparent,
            foregroundColor: Colors.white,
          ),
          child: Text(e.name.capitalize()),
        ),
      );
    });
    final callTypes = CKCallType.values.map((e) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white),
          onPressed: _hasCall && _call!.callType != e
              ? () async {
                  await webCallkitPlugin.updateCallType(callId, callType: e);
                }
              : null,
          child: Text(e.name.capitalize()),
        ),
      );
    });
    final callStates = CKCallState.values.map((e) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white),
          onPressed: _hasCall && _call!.state != e
              ? () async {
                  await webCallkitPlugin.updateCallStatus(callId,
                      callStatus: e);
                }
              : null,
          child: Text(e.name.capitalize()),
        ),
      );
    });

    return CKCard(
      title: const HeaderText("Advanced Call"),
      description: const Text(
          "Test advanced call features such as holding, muting, switching call types between audio, video and screenshare."),
      child: Column(
        children: [
          // Start/end call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  const name = "John \"Hold\" Doe";
                  await webCallkitPlugin.reportOutgoingCall(
                    uuid: callId,
                    handle: name,
                    capabilities: {
                      CKCapability.hold,
                    },
                  );
                },
                child: const Text('Report Outgoing Call'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  const name = "John \"Hold\" Doe";
                  await webCallkitPlugin.reportOngoingCall(
                    uuid: callId,
                    handle: name,
                    capabilities: {
                      // CallKitCapability.hold,
                    },
                    holding: true,
                  );
                },
                child: const Text('Report Ongoing Call'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  const name = "John \"Incoming\" Doe";
                  await webCallkitPlugin.reportIncomingCall(
                    uuid: callId,
                    handle: name,
                    capabilities: {
                      CKCapability.supportHold,
                    },
                  );
                },
                child: const Text('Report Incoming Call'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                icon: const Icon(Icons.call_end),
                onPressed: _hasCall
                    ? () async {
                        await webCallkitPlugin.reportCallDisconnected(callId,
                            response: CKDisconnectResponse.local);
                      }
                    : null,
                label: const Text('Report Call Disconnected'),
              ),
            ],
          ),
          const Divider(),

          // Hold/resume call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                onPressed: _hasCall &&
                        !_call!.isHolding &&
                        (_call!.hasCapabilityHold ||
                            _call!.hasCapabilitySupportsHold)
                    ? () async {
                        final call = webCallkitPlugin.getCall(callId);
                        if (call == null) {
                          return;
                        }
                        final attr =
                            call.attributes.addWith(CKCallAttributes.hold);
                        await webCallkitPlugin.updateCallAttributes(callId,
                            attributes: attr);
                      }
                    : null,
                child: const Text("Hold"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                onPressed: _hasCall &&
                        _call!.isHolding &&
                        (_call!.hasCapabilityHold ||
                            _call!.hasCapabilitySupportsHold)
                    ? () async {
                        final call = webCallkitPlugin.getCall(callId);
                        if (call == null) {
                          return;
                        }
                        final attr =
                            call.attributes.removeWith(CKCallAttributes.hold);
                        await webCallkitPlugin.updateCallAttributes(callId,
                            attributes: attr);
                      }
                    : null,
                child: const Text("Resume"),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Divider(),

          // Mute/unmute call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                onPressed:
                    _hasCall && !_call!.isMuted && _call!.hasCapabilityMute
                        ? () async {
                            final call = webCallkitPlugin.getCall(callId);
                            if (call == null) {
                              return;
                            }
                            final attr =
                                call.attributes.addWith(CKCallAttributes.mute);
                            await webCallkitPlugin.updateCallAttributes(callId,
                                attributes: attr);
                          }
                        : null,
                child: const Text("Mute"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                onPressed:
                    _hasCall && _call!.isMuted && _call!.hasCapabilityMute
                        ? () async {
                            final call = webCallkitPlugin.getCall(callId);
                            if (call == null) {
                              return;
                            }
                            final attr =
                                call.attributes.removeWith(CKCallAttributes.mute);
                            await webCallkitPlugin.updateCallAttributes(callId,
                                attributes: attr);
                          }
                        : null,
                child: const Text("Unmute"),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Divider(),

          // Set specific state of call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("States:"),
              const SizedBox(width: 4),
              ...callStates,
            ],
          ),
          const SizedBox(width: 8),
          const Divider(),

          // Set specific type of call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Types:"),
              const SizedBox(width: 4),
              ...callTypes,
            ],
          ),
          const SizedBox(width: 8),
          const Divider(),

          // Set specific capabilities of call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Capabilities:"),
              const SizedBox(width: 4),
              ...capabilities,
            ],
          ),
          const SizedBox(width: 8),
          const Divider(),

          // Set specific data of call
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _hasCall
                    ? () async {
                        await webCallkitPlugin
                            .updateCallData(callId, data: {"key": "value"});
                      }
                    : null,
                child: const Text("Set Data"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _hasCall
                    ? () async {
                        final call = webCallkitPlugin.getCall(callId);
                        if (call == null) {
                          return;
                        }
                        final data = call.data ?? {};
                        data.update("key", (value) => "value2",
                            ifAbsent: () => "value3");
                        await webCallkitPlugin.updateCallData(callId,
                            data: data);
                      }
                    : null,
                child: const Text("Update Data"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _hasCall
                    ? () async {
                        final call = webCallkitPlugin.getCall(callId);
                        if (call == null) {
                          return;
                        }
                        final data = call.data ?? {};
                        data.remove("key");
                        await webCallkitPlugin.updateCallData(callId,
                            data: data);
                      }
                    : null,
                child: const Text("Remove Data"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _hasCall
                    ? () async {
                        await webCallkitPlugin.updateCallData(callId, data: {});
                      }
                    : null,
                child: const Text("Clear Data"),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
