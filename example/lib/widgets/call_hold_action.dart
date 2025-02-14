import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit_example/utils.dart';

class CallHoldAction extends StatelessWidget {
  final CKCall call;

  const CallHoldAction({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final text = call.isHolding ? "Resume" : "Hold";
    return TextButton.icon(
      icon: switch (call.isHolding) {
        true => const Icon(Icons.play_arrow),
        false => const Icon(Icons.pause),
      },
      label: Text(text),
      onPressed: () {
        final attr = call.isHolding
            ? call.attributes.removeWith(CallAttributes.hold)
            : call.attributes.addWith(CallAttributes.hold);
        final webCallkitPlugin = WebCallkit.instance;
        webCallkitPlugin.updateCallAttributes(call.uuid, attributes: attr);
      },
    );
  }
}
