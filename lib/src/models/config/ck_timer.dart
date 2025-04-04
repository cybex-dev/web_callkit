import '../../core/enums/ck_call_state.dart';

class CKTimer {
  final bool enabled;
  final CKCallState startOnState;

  const CKTimer({
    this.enabled = true,
    this.startOnState = CKCallState.active,
  });

  @override
  String toString() {
    return 'CKTimer{enabled: $enabled, startOnState: $startOnState}';
  }
}