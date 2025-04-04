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
            _buildIconFromCKCallState(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(call.localizedName),
                _buildCKCallStateAndId(),
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

  Widget _buildCKCallStateAndId() {
    final state = call.state.name;
    final id = call.uuid;
    return Text("State: $state\nID: $id");
  }

  Widget _buildIconFromCKCallState() {
    final state = call.state;
    switch (state) {
      case CKCallState.active:
        return const Icon(Icons.call);
      case CKCallState.disconnecting:
      case CKCallState.disconnected:
        return const Icon(Icons.call_end);
      case CKCallState.ringing:
        return const Icon(Icons.ring_volume);
      case CKCallState.initiated:
        return const Icon(Icons.call_made);
      case CKCallState.reconnecting:
        return const Icon(Icons.refresh);
      case CKCallState.dialing:
        return const Icon(Icons.call_made);
    }
  }

  List<Widget> _buildNextActions() {
    switch (call.state) {
      case CKCallState.initiated:
        return [
          CKCallStateAction.dialing(call.uuid),
          DisconnectAction.error(call.uuid),
        ];
      case CKCallState.dialing:
        return [
          CKCallStateAction.active(call.uuid),
          // Hold/resume call while dialing
          CallHoldAction(call: call),
          // End call (cancelled call)
          DisconnectAction.canceled(call.uuid),
          // End call (remote party ended)
          DisconnectAction.rejected(call.uuid),
          // Some error occurred
          DisconnectAction.error(call.uuid),
        ];
      case CKCallState.ringing:
        return [
          // Answer call, add hold to answer and hold
          CKCallStateAction.active(call.uuid),
          // End call (mark as busy)
          DisconnectAction.busy(call.uuid),
          // Some error occurred
          DisconnectAction.error(call.uuid),
        ];
      case CKCallState.active:
        return [
          // Hold/resume call while dialing
          CallTypeSelector(call: call),
          CallHoldAction(call: call),
          // Mark call as ended, locally
          CKCallStateAction.disconnected(call.uuid),
          // Mark call as ended, remote
          CKCallStateAction.disconnecting(call.uuid),
          // End call, locally
          DisconnectAction.local(call.uuid),
          // End call, remote
          DisconnectAction.remote(call.uuid),
          // Some error occurred
          DisconnectAction.error(call.uuid),
        ];
      case CKCallState.disconnecting:
        return [
          // Mark call as ended
          CKCallStateAction.disconnected(call.uuid),
        ];
      case CKCallState.disconnected:
        return [];
      default:
        return [];
    }
  }
}
