enum CKSoundType { url, asset }

class CKSound {
  final bool looping;
  final bool enabled;
  final Duration delay;
  final CKSoundType type;

  const CKSound(
      {required this.type,
      this.looping = false,
      this.enabled = true,
      this.delay = const Duration(seconds: 0)});
}

class CKURLSound extends CKSound {
  final String url;

  const CKURLSound(this.url,
      {super.looping,
      super.enabled,
      super.delay,
      super.type = CKSoundType.url});
}

class CKAssetSound extends CKSound {
  final String asset;

  const CKAssetSound(this.asset,
      {super.looping,
      super.enabled,
      super.delay,
      super.type = CKSoundType.asset});
}

class CKSounds {
  static const String defaultIncomingUrl =
      "https://sdk.twilio.com/js/client/sounds/releases/1.0.0/incoming.mp3";
  static const String defaultIncomingWaitingUrl =
      "https://www.soundsnap.com/play?t=e&p=files/audio/n8/456121-COMCell-Notification-Two_note_keys_11-KDRa-CNMPHN.mp3";
  static const String defaultHoldUrl =
      "https://onlinesound.net/_ld/72/7210_busy_tone_2.mp3";
  // static const String defaultHoldUrl = "https://www.soundsnap.com/play?t=e&p=files/audio/54/50952-TECHNOLOGY_TELEPHONE_OPERATOR_UNFILTERED_MALE_VOICE_CLIP_YOUR_CALL_IS_VERY_IMPORTANT_TO_US_PLEASE.mp3";
  static const String defaultDialingUrl =
      "https://onlinesound.net/_ld/72/7212_ringing_tone_2.mp3";

  final bool enabled;
  final CKSound? incoming;
  final CKSound? dialing;
  final CKSound? callWaiting;
  final CKSound? holding;
  final CKSound? ended;

  const CKSounds({
    this.enabled = true,
    this.incoming,
    this.dialing,
    this.callWaiting,
    this.holding,
    this.ended,
  });

  factory CKSounds.standard({
    CKSound? incoming,
    CKSound? dialing,
    CKSound? callWaiting,
    CKSound? holding,
    CKSound? ended,
  }) {
    return CKSounds(
      incoming: incoming ?? const CKURLSound(defaultIncomingUrl),
      dialing: dialing ?? const CKURLSound(defaultDialingUrl),
      callWaiting: callWaiting ?? const CKURLSound(defaultIncomingWaitingUrl),
      holding: holding ?? const CKURLSound(defaultHoldUrl),
      ended: ended,
    );
  }
}
