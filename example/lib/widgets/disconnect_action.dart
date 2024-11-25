import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit/web_callkit_web.dart';

class DisconnectAction extends StatelessWidget {
  final String uuid;
  final DisconnectResponse response;

  const DisconnectAction({super.key, required this.uuid, this.response = DisconnectResponse.local});

  factory DisconnectAction.error(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.error);
  }

  factory DisconnectAction.local(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.local);
  }

  factory DisconnectAction.remote(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.remote);
  }

  factory DisconnectAction.canceled(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.canceled);
  }

  factory DisconnectAction.missed(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.missed);
  }

  factory DisconnectAction.rejected(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.rejected);
  }

  factory DisconnectAction.busy(String uuid) {
    return DisconnectAction(uuid: uuid, response: DisconnectResponse.busy);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.call_end),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.redAccent),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      label: Text(
        response.name,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () {
        final webCallkitPlugin = WebCallkit.instance;
        webCallkitPlugin.reportCallDisconnected(uuid, response: response);
      },
    );
  }
}