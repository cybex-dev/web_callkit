import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';

import 'call_hold_action.dart';
import 'call_state_action.dart';
import 'call_type_selector.dart';
import 'disconnect_action.dart';

class CKCallWidget extends StatelessWidget {
  final CKCall call;

  const CKCallWidget({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildIconFromCallState(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(call.localizedName),
                _buildCallStateAndId(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: _buildNextActions(),
        ),
      ],
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
      case CallState.reconnecting:
        return const Icon(Icons.refresh);
      case CallState.dialing:
        return const Icon(Icons.call_made);
    }
  }

  List<Widget> _buildNextActions() {
    switch (call.state) {
      case CallState.initiated:
        return [
          CallStateAction.dialing(call.uuid),
          DisconnectAction.error(call.uuid),
        ];
      case CallState.dialing:
        return [
          CallStateAction.active(call.uuid),
          // Hold/resume call while dialing
          CallHoldAction(call: call),
          // End call (cancelled call)
          DisconnectAction.canceled(call.uuid),
          // End call (remote party ended)
          DisconnectAction.rejected(call.uuid),
          // Some error occurred
          DisconnectAction.error(call.uuid),
        ];
      case CallState.ringing:
        return [
          // Answer call, add hold to answer and hold
          CallStateAction.active(call.uuid),
          // End call (mark as busy)
          DisconnectAction.busy(call.uuid),
          // Some error occurred
          DisconnectAction.error(call.uuid),
        ];
      case CallState.active:
        return [
          // Hold/resume call while dialing
          CallTypeSelector(call: call),
          CallHoldAction(call: call),
          // Mark call as ended, locally
          CallStateAction.disconnected(call.uuid),
          // Mark call as ended, remote
          CallStateAction.disconnecting(call.uuid),
          // End call, locally
          DisconnectAction.local(call.uuid),
          // End call, remote
          DisconnectAction.remote(call.uuid),
          // Some error occurred
          DisconnectAction.error(call.uuid),
        ];
      case CallState.disconnecting:
        return [
          // Mark call as ended
          CallStateAction.disconnected(call.uuid),
        ];
      case CallState.disconnected:
        return [];
      default:
        return [];
    }
  }
}
