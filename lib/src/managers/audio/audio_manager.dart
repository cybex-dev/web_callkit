import 'dart:html' as html;

class AudioManager {
  static const tag = 'audio_manager';
}

class AudioPlayer {

  static const tag = 'audio_player';

  static final AudioPlayer _instance = AudioPlayer._();

  AudioPlayer._();

  factory AudioPlayer() => _instance;

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

  @override
  String toString() {
    return 'AudioPlayer#$hashCode{isPlaying: $isPlaying, src: ${_audioElement.src}';
  }
}