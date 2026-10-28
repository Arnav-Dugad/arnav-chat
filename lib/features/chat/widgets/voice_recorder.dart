import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../../../core/platform/files.dart';
import '../../../data/media/media_prep.dart';

class VoiceClip {
  const VoiceClip({required this.path, required this.duration, required this.waveform});
  final String path;
  final Duration duration;
  final List<double> waveform;
}

/// Hold-to-record state machine around the `record` plugin.
class VoiceRecorder extends ChangeNotifier {
  final _rec = AudioRecorder();
  StreamSubscription<Amplitude>? _amp;
  Timer? _ticker;
  DateTime? _startedAt;
  String? _path;

  bool recording = false;
  bool locked = false;
  Duration elapsed = Duration.zero;
  final List<double> levels = [];

  /// Gesture offsets while holding (for slide-to-cancel / lock affordances).
  double dragX = 0;
  double dragY = 0;

  Future<bool> start() async {
    if (recording) return true;
    if (!await _rec.hasPermission()) return false;
    _path = await tempFilePath('m4a');
    await _rec.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, sampleRate: 44100, numChannels: 1),
      path: _path!,
    );
    recording = true;
    locked = false;
    levels.clear();
    dragX = dragY = 0;
    _startedAt = DateTime.now();
    elapsed = Duration.zero;
    _amp = _rec.onAmplitudeChanged(const Duration(milliseconds: 70)).listen((a) {
      levels.add(a.current.isFinite ? a.current : -60);
      notifyListeners();
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      elapsed = DateTime.now().difference(_startedAt!);
      notifyListeners();
    });
    notifyListeners();
    return true;
  }

  Future<VoiceClip?> stop() async {
    if (!recording) return null;
    final duration = DateTime.now().difference(_startedAt!);
    final out = await _rec.stop();
    _reset();
    final path = out ?? _path;
    if (path == null || duration < const Duration(milliseconds: 700)) {
      if (path != null) await deleteFile(path);
      return null;
    }
    return VoiceClip(path: path, duration: duration, waveform: normalizeWaveform(List.of(levels)));
  }

  Future<void> cancel() async {
    if (!recording) return;
    final out = await _rec.stop();
    _reset();
    final path = out ?? _path;
    if (path != null) await deleteFile(path);
  }

  void lock() {
    locked = true;
    notifyListeners();
  }

  void drag(double dx, double dy) {
    dragX = dx;
    dragY = dy;
    notifyListeners();
  }

  void _reset() {
    _amp?.cancel();
    _ticker?.cancel();
    recording = false;
    locked = false;
    dragX = dragY = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _amp?.cancel();
    _ticker?.cancel();
    _rec.dispose();
    super.dispose();
  }
}
