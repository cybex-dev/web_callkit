import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit_example/utils.dart';

import '../../widgets/ck_card.dart';
import '../../widgets/ck_call_log.dart';
import '../../widgets/data_grid.dart';
import '../../widgets/text.dart';

class CustomScreen extends StatelessWidget {
  const CustomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app: Custom Call'),
      ),
      body: Column(
        children: [
          const Expanded(
            child: _CustomCallCard(),
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

class _CustomCallCard extends StatefulWidget {
  // ignore: unused_element
  const _CustomCallCard({super.key});

  @override
  State<_CustomCallCard> createState() => _CustomCallCardState();
}

class _CustomCallCardState extends State<_CustomCallCard> {
  final Map<String, String> data = {
    "data_key": "data_value",
    "data_meta_key": "data_meta_value",
  };
  final Map<String, String> metadata = {
    "meta_key": "meta_value",
    "data_meta_key": "data_meta_value",
  };
  final callId = "customCall";
  final webCallkitPlugin = WebCallkit.instance;
  late final StreamSubscription<Iterable<CKCall>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = webCallkitPlugin.callStream.where((e) => e.any((f) => f.uuid == callId)).listen(
      (event) {
        final call = event.firstWhere((element) => element.uuid == callId);
        final updatedData = call.data?.toStringMap() ?? {};
        final updatedMeta = webCallkitPlugin.getNotification(callId)?.metadata.toStringMap() ?? {};
        data.clear();
        metadata.clear();
        data.addAll(updatedData);
        metadata.addAll(updatedMeta);
        if(mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return CKCard(
      title: const HeaderText("Custom Call"),
      description: const Text("Test all call features with a custom call."),
      child: Expanded(
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Start/end call
                    _CallActionButtons(
                      callId: callId,
                      data: data,
                      metadata: metadata,
                    ),
                    const Divider(height: 24,),

                    // Hold/resume call
                    _CKDisconnectResponses(callId: callId),
                    const SizedBox(height: 16),

                    // Hold/resume call
                    _CallHoldSelector(callId: callId),
                    const SizedBox(height: 16),

                    // Mute/unmute call
                    _CallMuteSelector(callId: callId),
                    const SizedBox(height: 16),

                    // Set specific state of call
                    _CKCallStateSelector(callId: callId),
                    const SizedBox(height: 16),

                    // Set specific type of call
                    _CallTypeSelector(callId: callId),
                    const SizedBox(height: 16),

                    // Set specific capabilities of call
                    _CallCapabilities(callId: callId),
                    const SizedBox(height: 16),

                    _CallDataEditor(
                      callId: callId,
                      onMetadataChanged: (e) {
                        setState(() {
                          metadata.clear();
                          metadata.addAll(e);
                        });
                      },
                      onDataChanged: (e) {
                        setState(() {
                          data.clear();
                          data.addAll(e);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(),
            Container(
              constraints: BoxConstraints(minWidth: 200, maxWidth: width * 0.4),
              child: SingleChildScrollView(child: _InformationPanel(callId: callId)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}

class _CallCapabilities extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _CallCapabilities({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    final call = webCallkitPlugin.getCall(callId);
    return Column(
      children: [
        const Text("Call Capabilities"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: CKCapability.values.map((e) {
            final enabled = call?.capabilities.contains(e) ?? false;
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled ? Colors.greenAccent : null,
                  foregroundColor: enabled ? Colors.white : null,
                ),
                onPressed: () async {
                  final call = webCallkitPlugin.getCall(callId);
                  if (call == null) {
                    return;
                  }
                  final cap = call.capabilities.toggleWith(e);
                  await webCallkitPlugin.updateCallCapabilities(callId, capabilities: cap);
                },
                child: Text(e.name.capitalize()),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CallTypeSelector extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _CallTypeSelector({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Column(
      children: [
        const Text("Call Type"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: CKCallType.values.map((e) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white),
                onPressed: () async {
                  await webCallkitPlugin.updateCallType(callId, callType: e);
                },
                child: Text(e.name.capitalize()),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CKCallStateSelector extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _CKCallStateSelector({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Column(
      children: [
        const Text("Call State"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: CKCallState.values.map((e) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white),
                onPressed: () async {
                  await webCallkitPlugin.updateCallStatus(callId, callStatus: e);
                },
                child: Text(e.name.capitalize()),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CallMuteSelector extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _CallMuteSelector({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Column(
      children: [
        const Text("Call Mute"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final call = webCallkitPlugin.getCall(callId);
                if (call == null) {
                  return;
                }
                final attr = call.attributes.addWith(CKCallAttributes.mute);
                await webCallkitPlugin.updateCallAttributes(callId, attributes: attr);
              },
              child: const Text("Mute"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final call = webCallkitPlugin.getCall(callId);
                if (call == null) {
                  return;
                }
                final attr = call.attributes.removeWith(CKCallAttributes.mute);
                await webCallkitPlugin.updateCallAttributes(callId, attributes: attr);
              },
              child: const Text("Unmute"),
            ),
          ],
        ),
      ],
    );
  }
}

class _CallHoldSelector extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _CallHoldSelector({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Column(
      children: [
        const Text("Call Hold"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                final call = webCallkitPlugin.getCall(callId);
                if (call == null) {
                  return;
                }
                final attr = call.attributes.addWith(CKCallAttributes.hold);
                webCallkitPlugin.updateCallAttributes(callId, attributes: attr);
              },
              child: const Text("Hold"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                final call = webCallkitPlugin.getCall(callId);
                if (call == null) {
                  return;
                }
                final attr = call.attributes.removeWith(CKCallAttributes.hold);
                webCallkitPlugin.updateCallAttributes(callId, attributes: attr);
              },
              child: const Text("Resume"),
            ),
          ],
        ),
      ],
    );
  }
}

class _CallActionButtons extends StatelessWidget {
  final Map<String, String> data;
  final Map<String, String> metadata;
  final String callId;

  const _CallActionButtons({
    // ignore: unused_element
    super.key,
    required this.callId,
    required this.data,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            const name = "Jane Smith";
            if(data.isEmpty) {
              return;
            }
            await webCallkitPlugin.reportIncomingCall(
              uuid: callId,
              handle: name,
              capabilities: {},
              data: data,
              metadata: metadata,
            );
          },
          child: const Text('Incoming Call'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            const name = "Jane Smith";
            await webCallkitPlugin.reportOutgoingCall(
              uuid: callId,
              handle: name,
              capabilities: {},
              data: data,
              metadata: metadata
            );
          },
          child: const Text('Outgoing Call'),
        ),
      ],
    );
  }
}

class _CKDisconnectResponses extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _CKDisconnectResponses({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Column(
      children: [
        const Text("Disconnect Responses"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: CKDisconnectResponse.values.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  await webCallkitPlugin.reportCallDisconnected(callId, response: e);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call_end, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(e.name),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CallDataEditor extends StatefulWidget {
  final ValueChanged<Map<String, String>> onDataChanged;
  final ValueChanged<Map<String, String>> onMetadataChanged;
  final String callId;

  const _CallDataEditor({
    // ignore: unused_element
    super.key,
    required this.callId,
    required this.onDataChanged,
    required this.onMetadataChanged,
  });

  @override
  State<_CallDataEditor> createState() => _CallDataEditorState();
}

class _CallDataEditorState extends State<_CallDataEditor> {
  final webCallkitPlugin = WebCallkit.instance;
  final Map<String, String> data = {
    "data_key": "data_value",
    "data_meta_key": "data_meta_value",
  };
  final Map<String, String> meta = {
    "meta_key": "meta_value",
    "data_meta_key": "data_meta_value",
  };
  late StreamSubscription<Iterable<CKCall>> _sub;

  @override
  void initState() {
    super.initState();
    _sub = webCallkitPlugin.callStream.listen((event) {
      final call = event.where((element) => element.uuid == widget.callId).firstOrNull;
      data.clear();
      meta.clear();
      if (call != null) {
        final mapped = call.data?.map((key, value) => MapEntry(key, value.toString())) ?? <String, String>{};
        data.addAll(mapped);
      } else {
        data.clear();
        // metaData.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final merged = Map<String, String>.from(data)..addAll(meta);
    return Column(
      children: [
        const Text("Call Data"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
          child: DataGridWidget(
            currentData: merged,
            dataKeys: data.keys.toSet(),
            metadataKeys: meta.keys.toSet(),
            onDataToggle: (updatedData) {
              setState(() {
                data.clear();
                data.addAll(updatedData);
                widget.onDataChanged(updatedData);
                if (webCallkitPlugin.getCall(widget.callId) != null) {
                  webCallkitPlugin.updateCallData(widget.callId, data: updatedData);
                }
                if (kDebugMode) {
                  print("data: $updatedData");
                }
              });
            },
            onMetaToggle: (updatedMetadata) {
              setState(() {
                meta.clear();
                meta.addAll(updatedMetadata);
                widget.onMetadataChanged(updatedMetadata);
                if (webCallkitPlugin.getCall(widget.callId) != null) {
                  webCallkitPlugin.updateCallMetadata(widget.callId, metadata: updatedMetadata);
                }
                if (kDebugMode) {
                  print("metadata: $updatedMetadata");
                }
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _InformationPanel extends StatelessWidget {
  final String callId;

  // ignore: unused_element
  const _InformationPanel({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    const smallTextStyle = TextStyle(fontSize: 10);
    const smallBoldTextStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
    final instance = WebCallkit.instance;
    return CKCard(
      title: const Text("Call Information"),
      child: StreamBuilder<Iterable<CKCall>>(
        stream: instance.callStream,
        builder: (context, snapshot) {
          final call = snapshot.data?.where((element) => element.uuid == callId).firstOrNull;
          if (call == null) {
            return const Text("No call found");
          }
          final n = instance.getNotification(callId);
          final map = <String, String>{
            "UUID": call.uuid,
            "Handle": call.localizedName,
            "Started": call.dateStarted.toTime(),
            "State": call.state.name,
            "Type": call.callType.name,
            "Updated Ago": call.dateUpdated.getTimeDifference(call.dateStarted),
            "Holding": call.isHolding ? "Yes" : "No",
            "Muted": call.isMuted ? "Yes" : "No",
            "Attributes": call.attributes.isEmpty ? "{}" : call.attributes.map((e) => e.name).join(", "),
            "Capabilities": call.capabilities.isEmpty ? "{}" : call.capabilities.map((e) => e.name).join(", "),
            "Data": (call.data ?? {}).isEmpty ? "{}" : call.data!.entries.map((e) => "${e.key}: ${e.value}").join(", "),
            "MetaData": (n?.metadata ?? {}).isEmpty ? "{}" : n!.metadata.entries.map((e) => "${e.key}: ${e.value}").join(", "),
          };
          return DataTable(
            dataRowMinHeight: 16,
            columns: const [
              DataColumn(label: Text("Key", style: smallBoldTextStyle)),
              DataColumn(label: Text("Value", style: smallBoldTextStyle)),
            ],
            rows: map.entries.map(
              (e) {
                final k = Text(e.key, style: smallBoldTextStyle);
                final v = Text(e.value, style: smallTextStyle);
                return DataRow(
                  cells: [
                    DataCell(k),
                    DataCell(v),
                  ],
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}
