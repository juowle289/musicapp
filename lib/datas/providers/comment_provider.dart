import 'package:flutter/foundation.dart';
import 'package:musicapp/datas/models/comment.dart';
import 'package:musicapp/datas/services/comment_firestore_service.dart';

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;
  int _currentPage = 0;
  final int _limit = 10;
  bool _hasMore = true;
  String? _currentSongId;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadComments(String songId, {bool refresh = false}) async {
    // If different song, auto refresh
    if (_currentSongId != songId) {
      refresh = true;
      _currentSongId = songId;
    }

    if (_isLoading) return;
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _comments = [];
    }
    if (!_hasMore && !refresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newComments = await CommentFirestoreService.getCommentsBySongId(
        songId,
        page: _currentPage,
        limit: _limit,
      );

      if (newComments.isEmpty) {
        _hasMore = false;
      } else {
        _comments.addAll(newComments);
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Lỗi loading cmt: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      final id = await CommentFirestoreService.addComment(comment);
      final newComment = comment.copyWith(id: id);
      _comments.insert(0, newComment);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  Future<void> deleteComment(String? commentId) async {
    try {
      await CommentFirestoreService.deleteComment(commentId);
      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi xóa cmt: $e');
    }
  }

  Future<void> reportComment(String? commentId) async {
    debugPrint('Bình luận $commentId đã được báo cáo');
  }

  bool isCommentOwner(Comment comment, String userEmail) {
    return comment.authorEmail == userEmail;
  }
}
