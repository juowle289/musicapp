import 'package:flutter/foundation.dart';
import 'package:musicapp/datas/models/playlist.dart';
import 'package:musicapp/datas/services/playlist_firestore_service.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  bool _isLoading = false;

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    notifyListeners();

    try {
      _playlists = await PlaylistFirestoreService.getAllPlaylists();
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Playlist?> addPlaylist(String name, {String? creatorEmail}) async {
    try {
      final playlist = Playlist(name: name, creatorEmail: creatorEmail);
      final id = await PlaylistFirestoreService.addPlaylist(playlist);
      await loadPlaylists();
      if (id != null) {
        return getPlaylistById(id);
      }
      return null;
    } catch (e) {
      debugPrint('----- Lỗi thêm playlist: $e');
      return null;
    }
  }

  Future<bool> updatePlaylist(Playlist playlist) async {
    try {
      await PlaylistFirestoreService.updatePlaylist(playlist);
      await loadPlaylists();
      return true;
    } catch (e) {
      debugPrint('Error updating playlist: $e');
      return false;
    }
  }

  Future<bool> deletePlaylist(String? id) async {
    try {
      await PlaylistFirestoreService.deletePlaylist(id);
      await loadPlaylists();
      return true;
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      return false;
    }
  }

  Playlist? getPlaylistById(String? id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
