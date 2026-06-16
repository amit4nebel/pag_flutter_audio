import 'package:flutter/material.dart';
import 'package:pag_flutter_audio/pag_flutter_audio.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAG Audio Demo',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pagKey = GlobalKey<PAGAudioViewState>();
  PAGAudioState _audioState = const PAGAudioState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PAG Audio Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: PAGAudioView(
                key: _pagKey,
                assetPath: 'assets/cheers.pag',
                audioConfig: const PAGAudioConfig(autoPlayAudio: true, loop: true),
                repeatCount: -1,
                onAudioStateChanged: (s) => setState(() => _audioState = s),
                audioControlsBuilder: (ctx, vs) =>
                    PAGAudioControls(state: _audioState, viewState: vs),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Audio: ${_audioState.hasAudio ? "Yes" : "No"}'),
                    Text('Playing: ${_audioState.isPlaying}'),
                    Text('${_fmt(_audioState.position)} / ${_fmt(_audioState.duration)}'),
                    if (_audioState.error != null)
                      Text('Error: ${_audioState.error}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => _pagKey.currentState?.play(), child: const Text('Play')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _pagKey.currentState?.pause(), child: const Text('Pause')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _pagKey.currentState?.stop(), child: const Text('Stop')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}
