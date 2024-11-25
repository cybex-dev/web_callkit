import 'dart:html' as html;

class AudioManager {
  static String get defautRingtoneUrl => "https://sdk.twilio.com/js/client/sounds/releases/1.0.0/incoming.mp3";
  static String get defautHoldUrl => "https://sdk.twilio.com/js/client/sounds/releases/1.0.0/incoming.mp3";
  static String get defautDialingUrl => "https://sdk.twilio.com/js/client/sounds/releases/1.0.0/incoming.mp3";

  static final AudioManager _instance = AudioManager._();

  AudioManager._();

  factory AudioManager() => _instance;

  final html.AudioElement _audioElement = html.AudioElement();

  void play(String url, {bool loop = true, double volume = 1.0, bool restart = true}) {
    if(isPlaying) {
      stop();
    }

    _audioElement.src = url;
    if(restart || _audioElement.src != url) {
      _audioElement.currentTime = 0;
    }
    _audioElement.muted = false;
    _audioElement.loop = loop;
    _audioElement.volume = volume;
    _audioElement.play();
  }

  void stop() {
    _audioElement.pause();
  }

  void setVolume(double volume) {
    _audioElement.volume = volume;
  }

  void setLoop(bool loop) {
    _audioElement.loop = loop;
  }

  void setMuted(bool muted) {
    _audioElement.muted = muted;
  }

  bool get isPlaying => !_audioElement.paused;
}