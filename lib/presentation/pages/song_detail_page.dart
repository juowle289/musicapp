import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Material,
        Slider,
        SliderTheme,
        SliderComponentShape,
        MaterialType,
        Brightness,
        Colors,
        BoxDecoration,
        BoxShadow,
        BorderRadius,
        Border,
        BorderSide,
        ClipRRect,
        BoxFit,
        Offset,
        Scaffold,
        AppBar,
        ListTile,
        AlertDialog,
        showDialog,
        showModalBottomSheet,
        TextButton,
        ScaffoldMessenger,
        SnackBar,
        GestureDetector;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/models/comment.dart';
import 'package:musicapp/datas/models/playlist.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/playlist_provider.dart';
import 'package:musicapp/datas/providers/music_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/datas/providers/loved_provider.dart';
import 'package:musicapp/datas/providers/comment_provider.dart';
import 'package:musicapp/datas/providers/song_provider.dart';

class SongDetailPage extends StatefulWidget {
  final Song song;

  const SongDetailPage({super.key, required this.song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  int _selectedTabIndex = -1;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentScrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isLovedAnimating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = context.read<MusicProvider>();
      if (musicProvider.currentSong?.id != widget.song.id) {
        musicProvider.playSong(widget.song);
        // Increment play count when song starts
        context.read<SongProvider>().incrementPlayCount(widget.song.id);
      }
    });
    _commentScrollController.addListener(_onCommentScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentScrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onCommentScroll() {
    if (_commentScrollController.position.pixels >=
        _commentScrollController.position.maxScrollExtent - 200) {
      final commentProvider = context.read<CommentProvider>();
      if (widget.song.id != null &&
          commentProvider.hasMore &&
          !commentProvider.isLoading) {
        commentProvider.loadComments(widget.song.id!);
      }
    }
  }

  void _onTabTap(int index) {
    _dismissKeyboard();
    setState(() {
      if (_selectedTabIndex == index) {
        _selectedTabIndex = -1;
      } else {
        _selectedTabIndex = index;
        if (index == 1 && widget.song.id != null) {
          final commentProvider = context.read<CommentProvider>();
          commentProvider.loadComments(widget.song.id!, refresh: true);
        }
      }
    });
  }

  void _toggleLoveSong() {
    setState(() {
      _isLovedAnimating = true;
    });
    final authProvider = context.read<AuthProvider>();
    final lovedProvider = context.read<LovedProvider>();
    lovedProvider.toggleLovedSong(widget.song, authProvider.userEmail);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLovedAnimating = false;
        });
      }
    });
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _dismissKeyboard();
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final commentProvider = context.read<CommentProvider>();

    if (widget.song.id == null) {
      _dismissKeyboard();
      return;
    }

    final comment = Comment(
      songId: widget.song.id!,
      authorEmail: authProvider.userEmail ?? 'anonymous',
      content: content,
      createdAt: DateTime.now(),
    );

    commentProvider.addComment(comment);
    _commentController.clear();
    _dismissKeyboard();
  }

  void _showCommentOptions(Comment comment, bool isDarkMode) {
    final authProvider = context.read<AuthProvider>();
    final isOwner = comment.authorEmail == authProvider.userEmail;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1E1E1E)
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[600]
                    : CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isOwner)
              ListTile(
                leading: Icon(
                  CupertinoIcons.trash,
                  color: CupertinoColors.destructiveRed,
                ),
                title: Text(
                  'Xóa',
                  style: TextStyle(color: CupertinoColors.destructiveRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CommentProvider>().deleteComment(comment.id!);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Đã xóa bình luận')));
                },
              ),
            ListTile(
              leading: Icon(
                CupertinoIcons.flag,
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
              title: Text(
                'Báo cáo',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<CommentProvider>().reportComment(comment.id!);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Đã báo cáo bình luận')));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _showOptionsSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionsBottomSheet(
        isDarkMode: isDarkMode,
        onShare: () {
          Navigator.pop(context);
          _shareSong();
        },
        onAddToPlaylist: () {
          Navigator.pop(context);
          _showAddToPlaylistSheet(isDarkMode);
        },
      ),
    );
  }

  void _shareSong() {
    Clipboard.setData(
      ClipboardData(
        text:
            'Check out this song: ${widget.song.title} by ${widget.song.artist}',
      ),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Đã sao chép thông tin bài hát!'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _AddToPlaylistSheet(isDarkMode: isDarkMode, song: widget.song),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final musicProvider = context.watch<MusicProvider>();
    final lovedProvider = context.watch<LovedProvider>();

    final isDarkMode = themeProvider.isDarkMode;
    final darkAccent = const Color(0xFFFEEC93);
    final darkBackground = const Color(0xFF121212);

    final isLoved = lovedProvider.isSongLoved(widget.song.id);

    final isCurrentSong = musicProvider.currentSong?.id == widget.song.id;
    final isPlaying = isCurrentSong && musicProvider.isPlaying;
    final currentPosition = isCurrentSong
        ? musicProvider.currentPositionSeconds
        : 0.0;
    final totalDuration =
        isCurrentSong && musicProvider.totalDurationSeconds > 0
        ? musicProvider.totalDurationSeconds
        : widget.song.duration.toDouble();

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? darkBackground
            : CupertinoColors.systemBackground,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            widget.song.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _dismissKeyboard();
              Navigator.pop(context);
            },
            child: Icon(
              CupertinoIcons.chevron_down,
              size: 20,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
          ),
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showOptionsSheet(isDarkMode),
              child: Icon(
                CupertinoIcons.ellipsis,
                size: 20,
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMainContent(
                        context,
                        isDarkMode,
                        darkAccent,
                        isPlaying,
                        currentPosition,
                        totalDuration,
                        isLoved,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: !isDarkMode
                              ? Border.all(
                                  color: CupertinoColors.inactiveGray,
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTabButton(
                              0,
                              CupertinoIcons.person_fill,
                              isDarkMode,
                            ),
                            _buildTabButton(
                              1,
                              CupertinoIcons.chat_bubble_fill,
                              isDarkMode,
                            ),
                            _buildTabButton(
                              2,
                              CupertinoIcons.doc_text_fill,
                              isDarkMode,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTabContent(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              if (_selectedTabIndex == 1) _buildCommentInput(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDarkMode) {
    if (_selectedTabIndex == -1) {
      return const SizedBox.shrink();
    }

    switch (_selectedTabIndex) {
      case 0:
        return _buildArtistContent(isDarkMode);
      case 1:
        return _buildCommentsContent(isDarkMode);
      case 2:
        return _buildLyricsContent(isDarkMode);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isDarkMode,
    Color darkAccent,
    bool isPlaying,
    double currentPosition,
    double totalDuration,
    bool isLoved,
  ) {
    final musicProvider = context.read<MusicProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingLine = screenWidth - 56;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        children: [
          Center(
            child: Container(
              width: paddingLine,
              height: paddingLine,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDarkMode
                                ? Colors.grey[700]!
                                : CupertinoColors.systemGrey)
                            .withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    widget.song.coverPath != null &&
                        widget.song.coverPath!.isNotEmpty
                    ? Image.asset(
                        widget.song.coverPath!,
                        width: paddingLine,
                        height: paddingLine,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: paddingLine,
                        height: paddingLine,
                        color: isDarkMode
                            ? Colors.grey[800]
                            : CupertinoColors.systemGrey5,
                        child: Icon(
                          CupertinoIcons.music_note,
                          size: 60,
                          color: isDarkMode
                              ? Colors.grey[600]
                              : CupertinoColors.systemGrey,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.label,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.song.artist,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : CupertinoColors.secondaryLabel,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleLoveSong,
                child: AnimatedScale(
                  scale: _isLovedAnimating ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isLoved
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      key: ValueKey(isLoved),
                      color: isLoved
                          ? (isDarkMode
                                ? darkAccent
                                : CupertinoColors.systemYellow)
                          : (isDarkMode ? Colors.white : CupertinoColors.label),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            type: MaterialType.transparency,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: SliderComponentShape.noThumb,
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: isDarkMode
                    ? darkAccent
                    : CupertinoColors.label,
                inactiveTrackColor: isDarkMode
                    ? Colors.grey[700]
                    : CupertinoColors.systemGrey4.withValues(alpha: 0.5),
              ),
              child: Slider(
                value: currentPosition.clamp(0, totalDuration),
                min: 0,
                max: totalDuration > 0 ? totalDuration : 1,
                onChanged: (value) => musicProvider.seekToSeconds(value),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(currentPosition.toInt()),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '-${_formatDuration(totalDuration.toInt() - currentPosition.toInt())}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          SizedBox(
            width: paddingLine,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  CupertinoIcons.shuffle,
                  size: 20,
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
                GestureDetector(
                  onTap: () => musicProvider.skipBackward(),
                  child: Icon(
                    CupertinoIcons.backward_fill,
                    size: 32,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (musicProvider.currentSong?.id == widget.song.id) {
                      musicProvider.togglePlayPause();
                    } else {
                      musicProvider.playSong(widget.song);
                      // Increment play count when switching to a new song
                      context.read<SongProvider>().incrementPlayCount(widget.song.id);
                    }
                  },
                  child: Icon(
                    isPlaying
                        ? CupertinoIcons.pause_circle_fill
                        : CupertinoIcons.play_circle_fill,
                    size: 56,
                    color: isDarkMode ? darkAccent : CupertinoColors.label,
                  ),
                ),
                GestureDetector(
                  onTap: () => musicProvider.skipForward(),
                  child: Icon(
                    CupertinoIcons.forward_fill,
                    size: 32,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                Icon(
                  CupertinoIcons.repeat,
                  size: 20,
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 0) seconds = 0;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildCommentInput(bool isDarkMode) {
    final darkAccent = const Color(0xFFFEEC93);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              placeholder: 'Viết bình luận...',
              style: TextStyle(
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
              placeholderStyle: TextStyle(
                color: isDarkMode
                    ? Colors.grey[500]
                    : CupertinoColors.placeholderText,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[800]
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(24),
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _submitComment,
            child: Icon(
              CupertinoIcons.paperplane_fill,
              color: isDarkMode ? darkAccent : CupertinoColors.activeBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistContent(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nghệ sĩ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.song.artist,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode
                  ? Colors.grey[300]
                  : CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]
                  : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Thông tin về nghệ sĩ ${widget.song.artist} sẽ được hiển thị ở đây.',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? Colors.grey[400]
                    : CupertinoColors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsContent(bool isDarkMode) {
    final darkAccent = const Color(0xFFFEEC93);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bình luận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<CommentProvider>(
            builder: (context, commentProvider, child) {
              if (commentProvider.comments.isEmpty &&
                  !commentProvider.isLoading) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[800]
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Chưa có bình luận nào. Hãy là người đầu tiên!',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                controller: _commentScrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    commentProvider.comments.length +
                    (commentProvider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == commentProvider.comments.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }

                  final comment = commentProvider.comments[index];
                  return _buildCommentItem(comment, isDarkMode, darkAccent);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, bool isDarkMode, Color darkAccent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.authorEmail,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ),
              GestureDetector(
                onTap: () => _showCommentOptions(comment, isDarkMode),
                child: Icon(
                  CupertinoIcons.ellipsis,
                  size: 18,
                  color: isDarkMode
                      ? Colors.grey[500]
                      : CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? Colors.grey[300]
                  : CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTimeAgo(comment.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? Colors.grey[500]
                  : CupertinoColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsContent(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lời bài hát',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]
                  : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lời bài hát "${widget.song.title}" sẽ được hiển thị ở đây.',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? Colors.grey[400]
                    : CupertinoColors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, bool isDarkMode) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 480),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.grey[700] : CupertinoColors.systemGrey4)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected
              ? (isDarkMode ? Colors.white : CupertinoColors.label)
              : (isDarkMode
                    ? Colors.grey[400]
                    : CupertinoColors.secondaryLabel),
        ),
      ),
    );
  }
}

class _OptionsBottomSheet extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onShare;
  final VoidCallback onAddToPlaylist;

  const _OptionsBottomSheet({
    required this.isDarkMode,
    required this.onShare,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[600]
                  : CupertinoColors.systemGrey3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.share,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
            title: Text(
              'Chia sẻ',
              style: TextStyle(
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
            ),
            onTap: onShare,
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.list_bullet,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
            title: Text(
              'Thêm vào playlist',
              style: TextStyle(
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
            ),
            onTap: onAddToPlaylist,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _AddToPlaylistSheet extends StatefulWidget {
  final bool isDarkMode;
  final Song song;

  const _AddToPlaylistSheet({required this.isDarkMode, required this.song});

  @override
  State<_AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<_AddToPlaylistSheet> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final authProvider = context.read<AuthProvider>();
    final currentUserEmail = authProvider.userEmail;

    return Container(
      height: screenHeight * 0.8,
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF1E1E1E)
            : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.isDarkMode
                      ? Colors.grey[700]!
                      : CupertinoColors.systemGrey4,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: widget.isDarkMode
                        ? Colors.white
                        : CupertinoColors.label,
                  ),
                ),
                Text(
                  'Thêm vào playlist',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode
                        ? Colors.white
                        : CupertinoColors.label,
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PlaylistProvider>(
              builder: (context, playlistProvider, child) {
                // Lọc chỉ lấy playlist của tài khoản hiện tại
                final myPlaylists = playlistProvider.playlists
                    .where(
                      (playlist) => playlist.creatorEmail == currentUserEmail,
                    )
                    .toList();

                if (myPlaylists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.music_albums,
                          size: 48,
                          color: widget.isDarkMode
                              ? Colors.grey[600]
                              : CupertinoColors.systemGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bạn chưa tạo playlist nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: myPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = myPlaylists[index];
                    // Kiểm tra xem bài hát đã có trong playlist chưa
                    final isInPlaylist =
                        widget.song.id != null &&
                        playlist.songIds.contains(widget.song.id);

                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.grey[800]
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: playlist.coverPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  playlist.coverPath!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                CupertinoIcons.music_albums,
                                color: widget.isDarkMode
                                    ? Colors.grey[600]
                                    : CupertinoColors.systemGrey,
                              ),
                      ),
                      title: Text(
                        playlist.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.isDarkMode
                              ? Colors.white
                              : CupertinoColors.label,
                        ),
                      ),
                      subtitle: Text(
                        '${playlist.songIds.length} bài hát',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode
                              ? Colors.grey[500]
                              : CupertinoColors.secondaryLabel,
                        ),
                      ),
                      trailing: Icon(
                        isInPlaylist
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        color: isInPlaylist
                            ? (widget.isDarkMode
                                  ? const Color(0xFFFEEC93)
                                  : CupertinoColors.systemYellow)
                            : (widget.isDarkMode
                                  ? Colors.grey[600]
                                  : CupertinoColors.systemGrey),
                      ),
                      onTap: () => _togglePlaylist(playlist, isInPlaylist),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlaylist(Playlist playlist, bool isInPlaylist) async {
    final playlistProvider = context.read<PlaylistProvider>();

    if (isInPlaylist) {
      // Xóa bài hát khỏi playlist
      final updatedSongIds = playlist.songIds
          .where((id) => id != widget.song.id)
          .toList();
      final updatedPlaylist = playlist.copyWith(songIds: updatedSongIds);
      await playlistProvider.updatePlaylist(updatedPlaylist);
    } else {
      // Thêm bài hát vào playlist
      if (widget.song.id != null &&
          !playlist.songIds.contains(widget.song.id)) {
        final updatedSongIds = [...playlist.songIds, widget.song.id!];
        final updatedPlaylist = playlist.copyWith(songIds: updatedSongIds);
        await playlistProvider.updatePlaylist(updatedPlaylist);
      }
    }

    // Force rebuild để cập nhật UI
    setState(() {});
  }
}
