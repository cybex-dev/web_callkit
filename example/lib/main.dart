import 'package:flutter/material.dart';
import 'dart:async';

import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit_example/utils.dart';

void main() {
  runApp(const MyApp());
}

const _headerTextStyle = TextStyle(fontSize: 18, color: Colors.deepPurple);
const _bodyTextStyle = TextStyle(fontSize: 14);
final webCallkitPlugin = WebCallkit();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                children: [
                  _SimpleCall(),
                  SizedBox(height: 24),
                  _HoldCall(),
                ],
              ),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: BoxConstraints.expand(height: height * 0.2),
              child: const _CallStreamList(),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: BoxConstraints.expand(height: height * 0.3),
              child: const _CallLog(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleCall extends StatelessWidget {
  final _simpleCallId = "simpleCall";

  const _SimpleCall({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Simple Call",
          style: _headerTextStyle,
        ),
        const Text(
          "Show a simple call dialog with a name and a number, will automatically disconnect after 10 seconds if not dismissed already.",
          style: _bodyTextStyle,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                const name = "John Doe";
                await webCallkitPlugin.reportNewCall(
                  uuid: _simpleCallId,
                  handle: name,
                );

                // Future.delayed(
                //   const Duration(seconds: 10),
                //   () {
                //     webCallkitPlugin.reportCallDisconnected(_simpleCallId, response: DisconnectResponse.local);
                //   },
                // );
              },
              child: const Text('Report New Call'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                await webCallkitPlugin.reportCallDisconnected(_simpleCallId, response: DisconnectResponse.local);
              },
              child: const Text('Report Call Disconnected'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HoldCall extends StatefulWidget {
  const _HoldCall({super.key});

  @override
  State<_HoldCall> createState() => _HoldCallState();
}

class _HoldCallState extends State<_HoldCall> {
  final _holdCallId = "holdCall";
  bool _holding = false;

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit();
    return Column(
      children: [
        const Text(
          "Call Holding",
          style: _headerTextStyle,
        ),
        const Text(
          "Toggle between holding a call.",
          style: _bodyTextStyle,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                const name = "John \"Hold\" Doe";
                await webCallkitPlugin.reportNewCall(
                  uuid: _holdCallId,
                  handle: name,
                  capabilities: {
                    CallKitCapability.hold,
                  },
                );

                final call = await webCallkitPlugin.getCall(_holdCallId);
                if (call == null) {
                  return;
                }
                setState(() {
                  _holding = call.isHolding;
                });
              },
              child: const Text('Report New Call'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final call = await webCallkitPlugin.getCall(_holdCallId);
                if (call == null) {
                  return;
                }
                final Set<CallAttributes> attr = {};
                if (!call.isHolding) {
                  attr.add(CallAttributes.hold);
                }
                webCallkitPlugin.updateCallAttributes(_holdCallId, attributes: attr);
                setState(() {
                  _holding = !call.isHolding;
                });
              },
              child: Text(_holding ? 'Resume' : "Hold"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                await webCallkitPlugin.reportCallDisconnected(_holdCallId, response: DisconnectResponse.local);
              },
              child: const Text('Report Call Disconnected'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CallStreamList extends StatefulWidget {
  const _CallStreamList({super.key});

  @override
  State<_CallStreamList> createState() => _CallStreamListState();
}

class _CallStreamListState extends State<_CallStreamList> {
  final webCallkitPlugin = WebCallkit.instance;
  List<CKCall> _calls = [];
  late StreamSubscription<Iterable<CKCall>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = webCallkitPlugin.callStream.listen((event) {
      setState(() {
        _calls.clear();
        _calls = event.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Active Calls", style: _headerTextStyle),
        const SizedBox(height: 4),
        ListView.builder(
          itemBuilder: (context, index) => _CallWidget(call: _calls[index]),
          itemCount: _calls.length,
          shrinkWrap: true,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}

class _CallLog extends StatefulWidget {
  const _CallLog({super.key});

  @override
  State<_CallLog> createState() => _CallLogState();
}

class _CallLogState extends State<_CallLog> {
  final controller = ScrollController();
  final List<CallEvent> log = [];
  late final StreamSubscription<CallEvent> subscription;

  @override
  void initState() {
    super.initState();
    subscription = WebCallkit.instance.eventStream.listen((event) {
      setState(() {
        log.add(event);
      });
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Clear"),
                onPressed: () {
                  setState(() {
                    log.clear();
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView(
              controller: controller,
              shrinkWrap: true,
              children: log.map((e) => Text(e.toString())).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}

class _CallWidget extends StatelessWidget {
  final CKCall call;

  const _CallWidget({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIconFromCallState(),
      title: Text(call.localizedName),
      subtitle: _buildCallStateAndId(),
      isThreeLine: true,
      trailing: _buildActions(),
    );
  }

  Widget _buildCallStateAndId() {
    final state = call.state.name;
    final id = call.uuid;
    return Text("State: $state\nID: $id");
  }

  Widget _buildIconFromCallState() {
    final state = call.state;
    switch (state) {
      case CallState.active:
        return const Icon(Icons.call);
      case CallState.disconnecting:
      case CallState.disconnected:
        return const Icon(Icons.call_end);
      case CallState.ringing:
        return const Icon(Icons.ring_volume);
      case CallState.initiated:
        return const Icon(Icons.call_made);
      case CallState.hold:
        return const Icon(Icons.pause);
      case CallState.dialing:
        return const Icon(Icons.call_made);
    }
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildNextActions(),
    );
  }

  List<Widget> _buildNextActions() {
    switch (call.state) {
      case CallState.initiated:
        return [
          _CallStateAction.dialing(call.uuid),
          _DisconnectAction.error(call.uuid),
        ];
      case CallState.dialing:
        return [
          _CallStateAction.active(call.uuid),
          // Hold/resume call while dialing
          _CallHoldAction(call: call),
          // End call (cancelled call)
          _DisconnectAction.canceled(call.uuid),
          // End call (remote party ended)
          _DisconnectAction.rejected(call.uuid),
          // Some error occurred
          _DisconnectAction.error(call.uuid),
        ];
      case CallState.ringing:
        return [
          // Answer call, add hold to answer and hold
          _CallStateAction.active(call.uuid),
          // End call (mark as busy)
          _DisconnectAction.busy(call.uuid),
          // Some error occurred
          _DisconnectAction.error(call.uuid),
        ];
      case CallState.active:
        return [
          // Hold/resume call while dialing
          _ChangeCallType(call: call),
          _CallHoldAction(call: call),
          // Mark call as ended, locally
          _CallStateAction.disconnected(call.uuid),
          // Mark call as ended, remote
          _CallStateAction.disconnecting(call.uuid),
          // End call, locally
          _DisconnectAction.local(call.uuid),
          // End call, remote
          _DisconnectAction.remote(call.uuid),
          // Some error occurred
          _DisconnectAction.error(call.uuid),
        ];
      case CallState.disconnecting:
        return [
          // Mark call as ended
          _CallStateAction.disconnected(call.uuid),
        ];
      case CallState.disconnected:
        return [];
      default:
        return [];
    }
  }
}

class _CallStateAction extends StatelessWidget {
  final String uuid;
  final CallState state;

  const _CallStateAction({super.key, required this.uuid, required this.state});

  factory _CallStateAction.init(String uuid) => _CallStateAction(uuid: uuid, state: CallState.initiated);

  factory _CallStateAction.ringing(String uuid) => _CallStateAction(uuid: uuid, state: CallState.ringing);

  factory _CallStateAction.dialing(String uuid) => _CallStateAction(uuid: uuid, state: CallState.dialing);

  factory _CallStateAction.active(String uuid) => _CallStateAction(uuid: uuid, state: CallState.active);

  factory _CallStateAction.hold(String uuid) => _CallStateAction(uuid: uuid, state: CallState.hold);

  factory _CallStateAction.disconnecting(String uuid) => _CallStateAction(uuid: uuid, state: CallState.disconnecting);

  factory _CallStateAction.disconnected(String uuid) => _CallStateAction(uuid: uuid, state: CallState.disconnected);

  @override
  Widget build(BuildContext context) {
    final webCallkitInstance = WebCallkit.instance;
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.lightGreen),
      ),
      child: Text(state.name, style: const TextStyle(color: Colors.white),),
      onPressed: () {
        webCallkitInstance.updateCallStatus(uuid, callStatus: state);
      },
    );
  }
}

class _CallHoldAction extends StatelessWidget {
  final CKCall call;

  const _CallHoldAction({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final webCallkitInstance = WebCallkit.instance;
    final text = call.isHolding ? "Resume" : "Hold";
    return TextButton(
      child: Text(text),
      onPressed: () {
        final attr = call.isHolding
            ? call.attributes.removeWith(CallAttributes.hold)
            : call.attributes.addWith(CallAttributes.hold);
        webCallkitInstance.updateCallAttributes(call.uuid, attributes: attr);
      },
    );
  }
}

class _DisconnectAction extends StatelessWidget {
  final String uuid;
  final DisconnectResponse response;

  const _DisconnectAction({super.key, required this.uuid, required this.response});

  factory _DisconnectAction.error(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.error);
  }

  factory _DisconnectAction.local(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.local);
  }

  factory _DisconnectAction.remote(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.remote);
  }

  factory _DisconnectAction.canceled(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.canceled);
  }

  factory _DisconnectAction.missed(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.missed);
  }

  factory _DisconnectAction.rejected(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.rejected);
  }

  factory _DisconnectAction.busy(String uuid) {
    return _DisconnectAction(uuid: uuid, response: DisconnectResponse.busy);
  }

  @override
  Widget build(BuildContext context) {
    final webCallkitInstance = WebCallkit.instance;
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.redAccent),
      ),
      child: Text(response.name, style: const TextStyle(color: Colors.white),),
      onPressed: () {
        webCallkitInstance.reportCallDisconnected(uuid, response: response);
      },
    );
  }
}

class _ChangeCallType extends StatelessWidget {
  final CKCall call;

  const _ChangeCallType({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final isAudio = call.isAudioOnly;
    final newType = isAudio ? CallType.video : CallType.audio;
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
      ),
      child: Text("Switch to ${newType.name}"),
      onPressed: () {
        WebCallkit.instance.updateCallType(call.uuid, callType: newType);
      },
    );
  }
}
