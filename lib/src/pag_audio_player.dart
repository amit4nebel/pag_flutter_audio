import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'pag_audio_config.dart';

class PAGAudioPlayer {
  static const MethodChannel _channel = MethodChannel('pag_flutter_audio');

  AudioPlayer? _audioPlayer;
  PAGAudioConfig _config;
  PAGAudioState _state = const PAGAudioState();
  String? _tempAudioPath;
  final String _id = const Uuid().v4();
  final StreamController<PAGAudioState> _stateController =
      StreamController<PAGAudioState>.broadcast();

  Stream<PAGAudioState> get stateStream => _stateController.stream;
  PAGAudioState get state => _state;

  PAGAudioPlayer({PAGAudioConfig config = const PAGAudioConfig()})
      : _config = config {
    _audioPlayer = AudioPlayer();
    _audioPlayer?.playerStateStream.listen((playerState) {
      _updateState(_state.copyWith(
        isPlaying: playerState.playing,
        isPaused: !playerState.playing,
      ));
    });
    _audioPlayer?.positionStream.listen((pos) {
      _updateState(_state.copyWith(position: pos));
    });
    _audioPlayer?.durationStream.listen((dur) {
      if (dur != null) _updateState(_state.copyWith(duration: dur));
    });
  }

  void _updateState(PAGAudioState s) {
    _state = s;
    _stateController.add(s);
  }

  Future<bool> loadFromBytes(Uint8List pagBytes) async {
    try {
      final result = await _channel.invokeMethod('extractAudio', {
        'pagBytes': pagBytes,
      });
      if (result == null || (result as Uint8List).isEmpty) {
        _updateState(_state.copyWith(hasAudio: false));
        return false;
      }
      final dir = await getTemporaryDirectory();
      _tempAudioPath = '${dir.path}/pag_audio_$_id.aac';
      await File(_tempAudioPath!).writeAsBytes(result);
      _updateState(_state.copyWith(hasAudio: true));
      return true;
    } catch (e) {
      _updateState(_state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> loadFromPath(String path) async {
    final bytes = await File(path).readAsBytes();
    return loadFromBytes(bytes);
  }

  Future<bool> loadFromAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return loadFromBytes(data.buffer.asUint8List());
  }

  Future<void> play() async {
    if (_tempAudioPath == null || !File(_tempAudioPath!).existsSync()) return;
    await _audioPlayer?.setFilePath(_tempAudioPath!);
    if (_config.loop) await _audioPlayer?.setLoopMode(LoopMode.one);
    await _audioPlayer?.setVolume(_config.volume);
    await _audioPlayer?.play();
  }

  Future<void> pause() async => _audioPlayer?.pause();

  Future<void> stop() async {
    await _audioPlayer?.stop();
    _updateState(_state.copyWith(isPlaying: false, position: Duration.zero));
  }

  Future<void> setVolume(double v) async {
    _config = _config.copyWith(volume: v);
    await _audioPlayer?.setVolume(v.clamp(0.0, 1.0));
  }

  void updateConfig(PAGAudioConfig config) => _config = config;

  Future<void> dispose() async {
    await _audioPlayer?.dispose();
    if (_tempAudioPath != null) {
      final f = File(_tempAudioPath!);
      if (await f.exists()) await f.delete();
    }
    await _stateController.close();
  }
}
