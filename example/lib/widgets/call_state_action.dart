import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';

class CKCallStateAction extends StatelessWidget {
  final String uuid;
  final CKCallState state;

  const CKCallStateAction({super.key, required this.uuid, required this.state});

  factory CKCallStateAction.init(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.initiated);

  factory CKCallStateAction.ringing(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.ringing);

  factory CKCallStateAction.dialing(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.dialing);

  factory CKCallStateAction.active(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.active);

  factory CKCallStateAction.reconnecting(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.reconnecting);

  factory CKCallStateAction.disconnecting(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.disconnecting);

  factory CKCallStateAction.disconnected(String uuid) =>
      CKCallStateAction(uuid: uuid, state: CKCallState.disconnected);

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
