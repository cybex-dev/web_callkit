import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';

class CallStateAction extends StatelessWidget {
  final String uuid;
  final CallState state;

  const CallStateAction({super.key, required this.uuid, required this.state});

  factory CallStateAction.init(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.initiated);

  factory CallStateAction.ringing(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.ringing);

  factory CallStateAction.dialing(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.dialing);

  factory CallStateAction.active(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.active);

  factory CallStateAction.reconnecting(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.reconnecting);

  factory CallStateAction.disconnecting(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.disconnecting);

  factory CallStateAction.disconnected(String uuid) =>
      CallStateAction(uuid: uuid, state: CallState.disconnected);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      icon: const Icon(
        Icons.circle,
        size: 4,
      ),
      label: Text(state.name),
      onPressed: () {
        final webCallkitPlugin = WebCallkit.instance;
        webCallkitPlugin.updateCallStatus(uuid, callStatus: state);
      },
    );
  }
}
