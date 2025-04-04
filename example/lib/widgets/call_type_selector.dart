import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';

class CallTypeSelector extends StatelessWidget {
  final CKCall call;

  const CallTypeSelector({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final isAudio = call.isAudioOnly;
    final newType = isAudio ? CKCallType.video : CKCallType.audio;
    final icon = switch (newType) {
      CKCallType.audio => const Icon(Icons.mic),
      CKCallType.video => const Icon(Icons.videocam),
      CKCallType.screenShare => const Icon(Icons.screen_share),
    };
    return TextButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      icon: icon,
      label: Text("Switch to ${newType.name}"),
      onPressed: () {
        final webCallkitPlugin = WebCallkit.instance;
        webCallkitPlugin.updateCallType(call.uuid, callType: newType);
      },
    );
  }
}
