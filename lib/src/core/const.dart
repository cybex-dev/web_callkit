import './enums/enums.dart';

const Duration durationSecond = Duration(seconds: 1);
// ignore: constant_identifier_names
const CALLKIT_PERSIST = "ck_persist";

const Map<CKCallState, List<CKDisconnectResponse>> validCallStateDisconnectResponses = {
  CKCallState.initiated: [
    CKDisconnectResponse.unknown,
    CKDisconnectResponse.error,
    CKDisconnectResponse.local,
    CKDisconnectResponse.remote,
    CKDisconnectResponse.canceled,
    CKDisconnectResponse.rejected,
    CKDisconnectResponse.declined,
    CKDisconnectResponse.busy
  ],
  CKCallState.ringing: [
    CKDisconnectResponse.unknown,
    CKDisconnectResponse.error,
    CKDisconnectResponse.remote,
    CKDisconnectResponse.missed,
    CKDisconnectResponse.rejected,
    CKDisconnectResponse.declined,
    CKDisconnectResponse.busy
  ],
  CKCallState.dialing: [CKDisconnectResponse.unknown, CKDisconnectResponse.error, CKDisconnectResponse.local, CKDisconnectResponse.rejected, CKDisconnectResponse.busy],
  CKCallState.active: [CKDisconnectResponse.unknown, CKDisconnectResponse.error, CKDisconnectResponse.local, CKDisconnectResponse.remote],
  CKCallState.reconnecting: [CKDisconnectResponse.unknown, CKDisconnectResponse.error, CKDisconnectResponse.local, CKDisconnectResponse.remote],
  CKCallState.disconnecting: [CKDisconnectResponse.unknown, CKDisconnectResponse.error, CKDisconnectResponse.local, CKDisconnectResponse.remote],
  CKCallState.disconnected: [CKDisconnectResponse.unknown, CKDisconnectResponse.error, CKDisconnectResponse.local, CKDisconnectResponse.remote],
};
