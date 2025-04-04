import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';

class DisconnectAction extends StatelessWidget {
  final String uuid;
  final CKDisconnectResponse response;

  const DisconnectAction({
    super.key,
    required this.uuid,
    this.response = CKDisconnectResponse.local,
  });

  factory DisconnectAction.error(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.error);
  }

  factory DisconnectAction.local(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.local);
  }

  factory DisconnectAction.remote(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.remote);
  }

  factory DisconnectAction.canceled(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.canceled);
  }

  factory DisconnectAction.missed(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.missed);
  }

  factory DisconnectAction.rejected(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.rejected);
  }

  factory DisconnectAction.busy(String uuid) {
    return DisconnectAction(uuid: uuid, response: CKDisconnectResponse.busy);
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
