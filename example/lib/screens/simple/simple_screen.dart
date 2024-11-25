import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit/web_callkit_web.dart';
import 'package:web_callkit_example/widgets/ck_call_log.dart';

import '../../widgets/ck_card.dart';
import '../../widgets/text.dart';

class SimpleScreen extends StatelessWidget {
  const SimpleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app: Simple Call'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CKCard(
              title: const HeaderText("Simple Call"),
              description: const Text(
                "Show a simple call dialog with a name and a number, will automatically disconnect after 10 seconds if not dismissed already.",
              ),
              child: _Content(),
            ),
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
  const _Content({super.key});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  Future? _future;
  bool _cancelAfter = true;

  final callId = "simpleCall";
  final _controller = TextEditingController(text: "10");

  @override
  Widget build(BuildContext context) {
    final webCallkitPlugin = WebCallkit.instance;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                const name = "John Doe";
                await webCallkitPlugin.reportIncomingCall(
                  uuid: callId,
                  handle: name,
                  stateOverride: CallState.ringing,
                );

                if (_cancelAfter) {
                  final seconds = int.tryParse(_controller.text) ?? 10;
                  _future = Future.delayed(
                    Duration(seconds: seconds),
                    () {
                      webCallkitPlugin.reportCallDisconnected(callId, response: DisconnectResponse.local);
                    },
                  );
                }
              },
              child: const Text('Report New Call'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                await webCallkitPlugin.reportCallDisconnected(callId, response: DisconnectResponse.local);
              },
              child: const Text('Report Call Disconnected'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Checkbox(
                  value: _cancelAfter,
                  onChanged: (value) {
                    setState(() {
                      _cancelAfter = value!;
                    });
                  },
                ),
                const Text("Cancel after X seconds"),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: TextField(
                enabled: _cancelAfter,
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Seconds",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        )
      ],
    );
  }
}
