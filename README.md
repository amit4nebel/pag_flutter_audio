# pag_flutter_audio

Flutter plugin for playing [PAG](https://pag.art) files with **audio support**.

The official `pag` plugin renders PAG animations but has no audio playback. This plugin adds audio extraction via `libpag`'s native API and plays it with `just_audio`.

## Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  pag_flutter_audio:
    git:
      url: https://github.com/yourusername/pag_flutter_audio.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:pag_flutter_audio/pag_flutter_audio.dart';

// Minimal - just works
PAGAudioView(
  assetPath: 'assets/animation.pag',
  repeatCount: -1,
)
```

## Examples

### 1. Basic Playback

```dart
PAGAudioView(
  assetPath: 'assets/animation.pag',
  repeatCount: -1,          // -1 = loop forever
  autoPlay: true,           // start automatically
  audioConfig: PAGAudioConfig(
    autoPlayAudio: true,    // play audio with animation
    volume: 1.0,            // 0.0 to 1.0
    loop: true,             // loop audio
  ),
)
```

### 2. With Play/Pause Controls

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _pagKey = GlobalKey<PAGAudioViewState>();
  PAGAudioState _audioState = const PAGAudioState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: PAGAudioView(
            key: _pagKey,
            assetPath: 'assets/animation.pag',
            repeatCount: -1,
            onAudioStateChanged: (state) {
              setState(() => _audioState = state);
            },
            audioControlsBuilder: (context, viewState) {
              return PAGAudioControls(
                state: _audioState,
                viewState: viewState,
              );
            },
          ),
        ),
        // Custom buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pagKey.currentState?.play(),
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => _pagKey.currentState?.pause(),
              child: Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () => _pagKey.currentState?.stop(),
              child: Text('Stop'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 3. From Network URL

```dart
PAGAudioView(
  url: 'https://example.com/animation.pag',
  repeatCount: -1,
)
```

### 4. From Bytes

```dart
Uint8List bytes = await File('animation.pag').readAsBytes();

PAGAudioView(
  pagBytes: bytes,
  repeatCount: -1,
)
```

### 5. Audio Only (No Controls)

```dart
PAGAudioView(
  assetPath: 'assets/animation.pag',
  audioConfig: PAGAudioConfig(
    autoPlayAudio: true,
    loop: true,
    volume: 0.8,
  ),
  onAnimationEnd: () {
    print('Animation finished');
  },
)
```

## API Reference

### PAGAudioView

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `assetPath` | String? | - | PAG file from assets |
| `pagBytes` | Uint8List? | - | PAG file bytes |
| `url` | String? | - | PAG file URL |
| `repeatCount` | int | 0 | -1 = loop forever, 0 = once |
| `autoPlay` | bool | true | Auto-play on load |
| `audioConfig` | PAGAudioConfig | default | Audio settings |
| `audioControlsBuilder` | Function? | - | Custom controls widget |
| `onAnimationStart` | VoidCallback? | - | Animation started |
| `onAnimationEnd` | VoidCallback? | - | Animation ended |
| `onAudioStateChanged` | Function? | - | Audio state changed |

### PAGAudioConfig

```dart
PAGAudioConfig(
  autoPlayAudio: true,  // play audio with animation
  volume: 1.0,          // 0.0 to 1.0
  loop: true,           // loop audio with animation
)
```

### PAGAudioViewState (via GlobalKey)

```dart
final key = GlobalKey<PAGAudioViewState>();

await key.currentState?.play();    // start animation + audio
await key.currentState?.pause();   // pause both
await key.currentState?.stop();    // stop both
bool isPlaying = key.currentState?.isPlaying ?? false;
```

### PAGAudioState

```dart
state.hasAudio    // bool - PAG contains audio
state.isPlaying   // bool - currently playing
state.isPaused    // bool - currently paused
state.position    // Duration - current position
state.duration    // Duration - total duration
state.error       // String? - error message
```

## Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ |
| iOS      | ✅ |

## Requirements

- Flutter 3.10+
- Dart 3.0+
- Android API 21+ (5.0+)
- iOS 12.0+

## How It Works

1. `PAGView` renders the animation (via `pag` plugin)
2. Native code calls `PAGFile.audioBytes()` to extract AAC audio
3. Audio is saved to temp file and played with `just_audio`
4. Both start together when `play()` is called

## License

MIT
