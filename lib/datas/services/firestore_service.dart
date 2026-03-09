import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicapp/datas/models/song.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  static CollectionReference get songsCollection => _db.collection('songs');

  // Get all songs
  static Future<List<Song>> getAllSongs() async {
    try {
      final snapshot = await songsCollection.get();
      return snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting songs: $e');
      return [];
    }
  }

  // Get songs by creator email
  static Future<List<Song>> getSongsByCreator(String creatorEmail) async {
    try {
      final snapshot = await songsCollection
          .where('creatorEmail', isEqualTo: creatorEmail)
          .get();
      return snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting songs by creator: $e');
      return [];
    }
  }

  // Get top songs by play count
  static Future<List<Song>> getTopSongs({int limit = 5}) async {
    try {
      final snapshot = await songsCollection
          .orderBy('playCount', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting top songs: $e');
      return [];
    }
  }

  // Add a new song
  static Future<String?> addSong(Song song) async {
    try {
      final docRef = await songsCollection.add(song.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding song: $e');
      return null;
    }
  }

  // Update a song
  static Future<bool> updateSong(Song song) async {
    try {
      if (song.id == null) return false;
      await songsCollection.doc(song.id).update(song.toFirestore());
      return true;
    } catch (e) {
      print('Error updating song: $e');
      return false;
    }
  }

  // Delete a song
  static Future<bool> deleteSong(String? id) async {
    try {
      if (id == null) return false;
      await songsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting song: $e');
      return false;
    }
  }

  // Increment play count
  static Future<bool> incrementPlayCount(String? id) async {
    try {
      if (id == null) return false;
      final doc = await songsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final currentCount = data?['playCount'] ?? 0;
        await songsCollection.doc(id).update({'playCount': currentCount + 1});
      }
      return true;
    } catch (e) {
      print('Error incrementing play count: $e');
      return false;
    }
  }

  // Delete all songs by creator (when account is deleted)
  static Future<bool> deleteSongsByCreator(String creatorEmail) async {
    try {
      final snapshot = await songsCollection
          .where('creatorEmail', isEqualTo: creatorEmail)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting songs by creator: $e');
      return false;
    }
  }

  // Search songs by title or artist
  static Future<List<Song>> searchSongs(String query) async {
    try {
      // Firestore doesn't support full-text search, so we get all and filter
      final allSongs = await getAllSongs();
      final lowerQuery = query.toLowerCase();
      return allSongs.where((song) {
        return song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }
}
