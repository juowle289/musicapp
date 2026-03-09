import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicapp/datas/models/playlist.dart';

class PlaylistFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Collection reference
  static CollectionReference get playlistsCollection => _db.collection('playlists');

  // Get all playlists
  static Future<List<Playlist>> getAllPlaylists() async {
    try {
      final snapshot = await playlistsCollection.get();
      return snapshot.docs.map((doc) => Playlist.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting playlists: $e');
      return [];
    }
  }

  // Get playlists by creator email
  static Future<List<Playlist>> getPlaylistsByCreator(String creatorEmail) async {
    try {
      final snapshot = await playlistsCollection
          .where('creatorEmail', isEqualTo: creatorEmail)
          .get();
      return snapshot.docs.map((doc) => Playlist.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting playlists by creator: $e');
      return [];
    }
  }

  // Add a new playlist
  static Future<String?> addPlaylist(Playlist playlist) async {
    try {
      final docRef = await playlistsCollection.add(playlist.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding playlist: $e');
      return null;
    }
  }

  // Update a playlist
  static Future<bool> updatePlaylist(Playlist playlist) async {
    try {
      if (playlist.id == null) return false;
      await playlistsCollection.doc(playlist.id).update(playlist.toFirestore());
      return true;
    } catch (e) {
      print('Error updating playlist: $e');
      return false;
    }
  }

  // Delete a playlist
  static Future<bool> deletePlaylist(String? id) async {
    try {
      if (id == null) return false;
      await playlistsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  // Delete all playlists by creator (when account is deleted)
  static Future<bool> deletePlaylistsByCreator(String creatorEmail) async {
    try {
      final snapshot = await playlistsCollection
          .where('creatorEmail', isEqualTo: creatorEmail)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting playlists by creator: $e');
      return false;
    }
  }
}

