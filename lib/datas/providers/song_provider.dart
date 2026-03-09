import 'package:flutter/material.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/services/firestore_service.dart';

class SongProvider with ChangeNotifier {
  List<Song> _songs = [];
  List<Song> _topSongs = [];
  bool _isLoading = false;

  List<Song> get songs => _songs;
  List<Song> get topSongs => _topSongs;
  bool get isLoading => _isLoading;

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _songs = await FirestoreService.getAllSongs();
      _topSongs = await FirestoreService.getTopSongs(limit: 5);
    } catch (e) {
      debugPrint('Error loading songs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSong(Song song, {String? creatorEmail}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final songWithCreator = song.copyWith(creatorEmail: creatorEmail);
      await FirestoreService.addSong(songWithCreator);
      await loadSongs();
    } catch (e) {
      debugPrint('Error adding song: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSong(Song song) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await FirestoreService.updateSong(song);
      await loadSongs();
    } catch (e) {
      debugPrint('Error updating song: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSong(String? id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await FirestoreService.deleteSong(id);
      await loadSongs();
    } catch (e) {
      debugPrint('Error deleting song: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementPlayCount(String? songId) async {
    try {
      await FirestoreService.incrementPlayCount(songId);
      await loadSongs();
    } catch (e) {
      debugPrint('Error incrementing play count: $e');
    }
  }

  List<Song> getSongsByCreator(String email) {
    return _songs.where((song) => song.creatorEmail == email).toList();
  }

  Song? getSongById(String? id) {
    try {
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    try {
      return await FirestoreService.searchSongs(query);
    } catch (e) {
      debugPrint('Error searching songs: $e');
      return [];
    }
  }
}
