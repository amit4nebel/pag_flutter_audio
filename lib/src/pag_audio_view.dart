import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pag/pag.dart';

import 'pag_audio_config.dart';
import 'pag_audio_player.dart';

class PAGAudioView extends StatefulWidget {
  final Uint8List? pagBytes;
  final String? assetPath;
  final String? url;
  final PAGAudioConfig audioConfig;
  final int repeatCount;
  final double initProgress;
  final bool autoPlay;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationEnd;
  final VoidCallback? onAnimationRepeat;
  final void Function(PAGAudioState state)? onAudioStateChanged;
  final Widget Function(BuildContext context, PAGAudioViewState state)?
      audioControlsBuilder;

  const PAGAudioView({
    super.key,
    this.pagBytes,
    this.assetPath,
    this.url,
    this.audioConfig = const PAGAudioConfig(),
    this.repeatCount = 0,
    this.initProgress = 0.0,
    this.autoPlay = true,
    this.onAnimationStart,
    this.onAnimationEnd,
    this.onAnimationRepeat,
    this.onAudioStateChanged,
    this.audioControlsBuilder,
  });

  @override
  PAGAudioViewState createState() => PAGAudioViewState();
}

class PAGAudioViewState extends State<PAGAudioView> {
  PAGAudioPlayer? _audioPlayer;
  final GlobalKey<PAGViewState> _pagKey = GlobalKey<PAGViewState>();
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = PAGAudioPlayer(config: widget.audioConfig);
    _audioPlayer?.stateStream.listen((s) {
      if (mounted) widget.onAudioStateChanged?.call(s);
    });
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    bool loaded = false;
    if (widget.pagBytes != null) {
      loaded = await _audioPlayer!.loadFromBytes(widget.pagBytes!);
    } else if (widget.assetPath != null) {
      loaded = await _audioPlayer!.loadFromAsset(widget.assetPath!);
    } else if (widget.url != null) {
      // Load from network - download first
      loaded = false;
    }
    if (mounted) setState(() { _hasAudio = loaded; _audioReady = true; });
  }

  Future<void> play() async {
    _pagKey.currentState?.start();
    if (_hasAudio) await _audioPlayer?.play();
    if (mounted) setState(() => _isPlaying = true);
  }

  Future<void> pause() async {
    _pagKey.currentState?.pause();
    await _audioPlayer?.pause();
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> stop() async {
    _pagKey.currentState?.stop();
    await _audioPlayer?.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  bool get isPlaying => _isPlaying;
  PAGAudioPlayer? get audioPlayer => _audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _buildPag()),
        if (widget.audioControlsBuilder != null)
          widget.audioControlsBuilder!(context, this),
      ],
    );
  }

  Widget _buildPag() {
    PAGView pag;
    if (widget.pagBytes != null) {
      pag = PAGView.bytes(widget.pagBytes!, key: _pagKey,
        repeatCount: widget.repeatCount, initProgress: widget.initProgress,
        autoPlay: widget.autoPlay, onAnimationStart: _onStart,
        onAnimationEnd: _onEnd, onAnimationRepeat: widget.onAnimationRepeat);
    } else if (widget.assetPath != null) {
      pag = PAGView.asset(widget.assetPath!, key: _pagKey,
        repeatCount: widget.repeatCount, initProgress: widget.initProgress,
        autoPlay: widget.autoPlay, onAnimationStart: _onStart,
        onAnimationEnd: _onEnd, onAnimationRepeat: widget.onAnimationRepeat);
    } else if (widget.url != null) {
      pag = PAGView.network(widget.url!, key: _pagKey,
        repeatCount: widget.repeatCount, initProgress: widget.initProgress,
        autoPlay: widget.autoPlay, onAnimationStart: _onStart,
        onAnimationEnd: _onEnd, onAnimationRepeat: widget.onAnimationRepeat);
    } else {
      return const SizedBox.shrink();
    }
    return pag;
  }

  void _onStart() {
    if (_audioReady && _hasAudio) _audioPlayer?.play();
    if (mounted) setState(() => _isPlaying = true);
    widget.onAnimationStart?.call();
  }

  void _onEnd() {
    if (mounted) setState(() => _isPlaying = false);
    widget.onAnimationEnd?.call();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}

class PAGAudioControls extends StatelessWidget {
  final PAGAudioState state;
  final PAGAudioViewState? viewState;

  const PAGAudioControls({super.key, required this.state, this.viewState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (viewState == null) return;
              state.isPlaying ? viewState!.pause() : viewState!.play();
            },
          ),
          Text('${_fmt(state.position)} / ${_fmt(state.duration)}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}
