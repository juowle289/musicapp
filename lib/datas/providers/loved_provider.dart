import 'package:flutter/foundation.dart';
import 'package:musicapp/datas/services/database_helper.dart';
import 'package:musicapp/datas/models/song.dart';

class LovedProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _lovedSongIds = [];
  List<Song> _lovedSongs = [];
  bool _isLoading = false;

  List<String> get lovedSongIds => _lovedSongIds;
  List<Song> get lovedSongs => _lovedSongs;
  bool get isLoading => _isLoading;

  bool isSongLoved(String? songId) {
    return _lovedSongIds.contains(songId);
  }

  Future<void> loadLovedSongs(String? userEmail) async {
    if (userEmail == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final lovedSongIds = await _dbHelper.getLovedSongIds(userEmail);
      _lovedSongIds = lovedSongIds.map((id) => id.toString()).toList();

      // Load full song details
      final allSongs = await _dbHelper.getAllSongs();
      _lovedSongs = allSongs
          .where((song) => _lovedSongIds.contains(song.id?.toString()))
          .toList();
    } catch (e) {
      debugPrint('Error loading loved songs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLovedSong(Song song, String? userEmail) async {
    if (userEmail == null) return;
    if (song.id == null) return;

    try {
      if (_lovedSongIds.contains(song.id)) {
        // Remove from loved - use String id directly
        await _dbHelper.removeLovedSong(song.id!, userEmail);
        _lovedSongIds.remove(song.id);
        _lovedSongs.removeWhere((s) => s.id == song.id);
      } else {
        // Add to loved - use String id directly
        await _dbHelper.addLovedSong(song.id!, userEmail);
        _lovedSongIds.add(song.id!);
        _lovedSongs.add(song);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling loved song: $e');
    }
  }
}
