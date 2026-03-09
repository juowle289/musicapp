import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:musicapp/datas/models/comment.dart';

class CommentFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  static CollectionReference get commentsCollection =>
      _db.collection('comments');

  // Get all comments by song ID - simplified query
  static Future<List<Comment>> getCommentsBySongId(
    String songId, {
    int page = 0,
    int limit = 10,
  }) async {
    try {
      debugPrint('Loading comments for songId: $songId');

      // Get all comments and filter by songId in memory to avoid index requirement
      final snapshot = await commentsCollection.get();

      final comments = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Comment(
              id: doc.id,
              songId: data['songId']?.toString() ?? '',
              authorEmail: data['authorEmail']?.toString() ?? '',
              content: data['content']?.toString() ?? '',
              createdAt: data['createdAt'] != null
                  ? DateTime.tryParse(data['createdAt'] as String) ??
                        DateTime.now()
                  : DateTime.now(),
            );
          })
          .where((comment) => comment.songId == songId)
          .toList();

      // Sort by createdAt descending
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('Found ${comments.length} comments for songId: $songId');

      return comments;
    } catch (e) {
      debugPrint('Error getting comments: $e');
      return [];
    }
  }

  // Add a new comment
  static Future<String?> addComment(Comment comment) async {
    try {
      final docRef = await commentsCollection.add(comment.toFirestore());
      print('Comment added with id: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  // Delete a comment
  static Future<bool> deleteComment(String? id) async {
    try {
      if (id == null) return false;
      await commentsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // Delete all comments by song ID (when song is deleted)
  static Future<bool> deleteCommentsBySongId(String songId) async {
    try {
      final snapshot = await commentsCollection
          .where('songId', isEqualTo: songId)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting comments by songId: $e');
      return false;
    }
  }
}
