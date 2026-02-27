import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_weather_channel/services/audio_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeSource extends Fake implements Source {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReleaseMode.loop);
    registerFallbackValue(FakeSource());
  });

  group('AudioService', () {
    late AudioService service;
    late MockAudioPlayer mockPlayer;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      service = AudioService(player: mockPlayer);

      // Default stubs — all player methods return completed futures.
      when(() => mockPlayer.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});
      when(
        () => mockPlayer.play(any(), volume: any(named: 'volume')),
      ).thenAnswer((_) async {});
      when(() => mockPlayer.pause()).thenAnswer((_) async {});
      when(() => mockPlayer.resume()).thenAnswer((_) async {});
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});
      when(() => mockPlayer.state).thenReturn(PlayerState.stopped);
    });

    test('isPlaying returns true when player is playing', () {
      when(() => mockPlayer.state).thenReturn(PlayerState.playing);
      expect(service.isPlaying, isTrue);
    });

    test('isPlaying returns false when player is stopped', () {
      when(() => mockPlayer.state).thenReturn(PlayerState.stopped);
      expect(service.isPlaying, isFalse);
    });

    test('play sets loop mode, volume, and starts playback', () async {
      await service.play();

      verify(() => mockPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
      verify(() => mockPlayer.setVolume(AudioService.defaultVolume)).called(1);
      verify(() => mockPlayer.play(any(that: isA<AssetSource>()))).called(1);
    });

    test('play is a no-op when already playing', () async {
      when(() => mockPlayer.state).thenReturn(PlayerState.playing);

      await service.play();

      verifyNever(() => mockPlayer.play(any()));
    });

    test('pause delegates to player', () async {
      await service.pause();

      verify(() => mockPlayer.pause()).called(1);
    });

    test('resume delegates to player', () async {
      await service.resume();

      verify(() => mockPlayer.resume()).called(1);
    });

    test('stop delegates to player', () async {
      await service.stop();

      verify(() => mockPlayer.stop()).called(1);
    });

    test('setVolume clamps value between 0 and 1', () async {
      await service.setVolume(1.5);
      verify(() => mockPlayer.setVolume(1.0)).called(1);

      await service.setVolume(-0.5);
      verify(() => mockPlayer.setVolume(0.0)).called(1);

      await service.setVolume(0.5);
      verify(() => mockPlayer.setVolume(0.5)).called(1);
    });

    test('dispose releases player resources', () async {
      await service.dispose();

      verify(() => mockPlayer.dispose()).called(1);
    });

    test('defaultVolume is 0.3', () {
      expect(AudioService.defaultVolume, 0.3);
    });

    test('assetPath points to bg_music.mp3', () {
      expect(AudioService.assetPath, 'assets/audio/bg_music.mp3');
    });
  });
}
