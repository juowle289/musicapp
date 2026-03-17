import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicapp/datas/models/song.dart';

class MusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _currentPositionSeconds = 0;
  double _totalDurationSeconds = 0;
  double _volume = 1.0; // Default volume at 100%

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get currentPositionSeconds => _currentPositionSeconds;
  double get totalDurationSeconds => _totalDurationSeconds;
  double get volume => _volume;

  MusicProvider() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
   
    _audioPlayer.setVolume(_volume);

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _currentPositionSeconds = position.inSeconds.toDouble();
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      _totalDurationSeconds = duration.inSeconds.toDouble();
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _currentPositionSeconds = 0;
      notifyListeners();
    });
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;
    _currentPositionSeconds = 0;
    _isPlaying = true;
    notifyListeners();

    if (song.audioPath != null && song.audioPath!.isNotEmpty) {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(
        AssetSource(song.audioPath!.replaceFirst('assets/', '')),
      );
      _isPlaying = true;
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentSong != null) {
      // Check if the song has completed or position is at the end, replay from beginning
      final position = await _audioPlayer.getCurrentPosition();
      if (_totalDurationSeconds > 0 &&
          position != null &&
          position.inSeconds >= _totalDurationSeconds - 1) {
        // Song has finished, replay from beginning
        await _audioPlayer.seek(Duration.zero);
        _currentPositionSeconds = 0;
      }
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      _isPlaying = true;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentPositionSeconds = 0;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    _currentPositionSeconds = position.inSeconds.toDouble();
    notifyListeners();
  }

  void seekToSeconds(double seconds) {
    _audioPlayer.seek(Duration(seconds: seconds.toInt()));
    _currentPositionSeconds = seconds;
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  // Skip forward 10 seconds
  Future<void> skipForward() async {
    final newPosition = _currentPositionSeconds + 10;
    if (newPosition < _totalDurationSeconds) {
      seekToSeconds(newPosition);
    } else {
      seekToSeconds(_totalDurationSeconds);
    }
  }

  // Skip backward 10 seconds
  Future<void> skipBackward() async {
    final newPosition = _currentPositionSeconds - 10;
    if (newPosition > 0) {
      seekToSeconds(newPosition);
    } else {
      seekToSeconds(0);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
