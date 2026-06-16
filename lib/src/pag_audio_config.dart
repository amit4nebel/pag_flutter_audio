import 'package:flutter/foundation.dart';

class PAGAudioConfig {
  final bool autoPlayAudio;
  final double volume;
  final bool loop;

  const PAGAudioConfig({
    this.autoPlayAudio = true,
    this.volume = 1.0,
    this.loop = true,
  });

  PAGAudioConfig copyWith({bool? autoPlayAudio, double? volume, bool? loop}) {
    return PAGAudioConfig(
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      volume: volume ?? this.volume,
      loop: loop ?? this.loop,
    );
  }
}

@immutable
class PAGAudioState {
  final bool isPlaying;
  final bool isPaused;
  final Duration position;
  final Duration duration;
  final bool hasAudio;
  final String? error;

  const PAGAudioState({
    this.isPlaying = false,
    this.isPaused = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hasAudio = false,
    this.error,
  });

  PAGAudioState copyWith({
    bool? isPlaying,
    bool? isPaused,
    Duration? position,
    Duration? duration,
    bool? hasAudio,
    String? error,
  }) {
    return PAGAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hasAudio: hasAudio ?? this.hasAudio,
      error: error,
    );
  }
}
