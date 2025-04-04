import '../../core/enums/ck_call_state.dart';

class CKTimer {
  final bool enabled;
  final CallState startOnState;

  const CKTimer({
    this.enabled = true,
    this.startOnState = CallState.active,
  });

  @override
  String toString() {
    return 'CKTimer{enabled: $enabled, startOnState: $startOnState}';
  }
}