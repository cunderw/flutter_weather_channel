import 'package:audioplayers/audioplayers.dart';

/// Manages background music playback for the TV weather experience.
///
/// Wraps an [AudioPlayer] and plays a bundled MP3 asset in a continuous
/// loop at a low volume so it sits behind the weather broadcast visuals.
class AudioService {
  final AudioPlayer _player;

  /// Default volume level for background music (0.0 – 1.0).
  static const double defaultVolume = 0.3;

  /// Asset path to the background music file.
  static const String assetPath = 'assets/audio/bg_music.mp3';

  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  /// Whether the background music is currently playing.
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Start looping the background music.
  ///
  /// If music is already playing this is a no-op.
  Future<void> play() async {
    if (isPlaying) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(defaultVolume);
    await _player.play(AssetSource('audio/bg_music.mp3'));
  }

  /// Pause the background music, keeping the current position.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume playback from the paused position.
  Future<void> resume() async {
    await _player.resume();
  }

  /// Stop playback and reset to the beginning.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Set the playback volume (0.0 – 1.0).
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Release resources held by the underlying player.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
