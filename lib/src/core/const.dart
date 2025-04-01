import './enums/enums.dart';

const Duration durationSecond = Duration(seconds: 1);
// ignore: constant_identifier_names
const CALLKIT_PERSIST = "ck_persist";

const Map<CallState, List<DisconnectResponse>> validCallStateDisconnectResponses = {
  CallState.initiated: [
    DisconnectResponse.unknown,
    DisconnectResponse.error,
    DisconnectResponse.local,
    DisconnectResponse.remote,
    DisconnectResponse.canceled,
    DisconnectResponse.rejected,
    DisconnectResponse.busy
  ],
  CallState.ringing: [
    DisconnectResponse.unknown,
    DisconnectResponse.error,
    DisconnectResponse.remote,
    DisconnectResponse.missed,
    DisconnectResponse.rejected,
    DisconnectResponse.declined,
    DisconnectResponse.busy
  ],
  CallState.dialing: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.rejected, DisconnectResponse.busy],
  CallState.active: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
  CallState.reconnecting: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
  CallState.disconnecting: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
  CallState.disconnected: [DisconnectResponse.unknown, DisconnectResponse.error, DisconnectResponse.local, DisconnectResponse.remote],
};
