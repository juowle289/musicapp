import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Brightness,
        Colors,
        LinearGradient,
        Alignment,
        BoxShadow,
        Divider,
        Scaffold,
        AppBar,
        ReorderableListView,
        ReorderableDragStartListener,
        Text,
        showModalBottomSheet,
        TextField,
        InputDecoration,
        OutlineInputBorder,
        BottomNavigationBar,
        BottomNavigationBarType,
        Icons;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/models/playlist.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/song_provider.dart';
import 'package:musicapp/datas/providers/playlist_provider.dart';
import 'package:musicapp/datas/providers/music_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';
import 'package:musicapp/presentation/widgets/mini_player.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late Playlist _currentPlaylist;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 280;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  List<Song> _getPlaylistSongs(List<Song> allSongs) {
    final List<Song> orderedSongs = [];
    for (final songId in _currentPlaylist.songIds) {
      final song = allSongs.firstWhere(
        (s) => s.id == songId,
        orElse: () =>
            Song(title: 'Unknown', artist: 'Unknown', album: '', duration: 0),
      );
      if (song.id != null) {
        orderedSongs.add(song);
      }
    }
    return orderedSongs;
  }

  void _showEditSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditPlaylistSheet(
        isDarkMode: isDarkMode,
        playlist: _currentPlaylist,
        onSave: (updatedPlaylist) async {
          final playlistProvider = context.read<PlaylistProvider>();
          await playlistProvider.updatePlaylist(updatedPlaylist);
          setState(() {
            _currentPlaylist = updatedPlaylist;
          });
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showAddSongSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddSongToPlaylistSheet(
        isDarkMode: isDarkMode,
        playlist: _currentPlaylist,
        onSave: (updatedPlaylist) async {
          final playlistProvider = context.read<PlaylistProvider>();
          await playlistProvider.updatePlaylist(updatedPlaylist);
          setState(() {
            _currentPlaylist = updatedPlaylist;
          });
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _openSongDetail(Song song) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => SongDetailPage(song: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUserEmail = authProvider.userEmail;
    final isOwner = _currentPlaylist.creatorEmail == currentUserEmail;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final darkAccent = const Color(0xFFFEEC93);
        final darkBackground = const Color(0xFF121212);
        final bgColor = isDarkMode ? darkBackground : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: _showAppBarTitle
                ? (isDarkMode ? darkBackground : Colors.white)
                : Colors.transparent,
            elevation: 0,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.back,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: _showAppBarTitle
                ? Text(
                    _currentPlaylist.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  )
                : null,
          ),
          body: Consumer<SongProvider>(
            builder: (context, songProvider, child) {
              final playlistSongs = _getPlaylistSongs(songProvider.songs);

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildHeader(isDarkMode, darkAccent),
                              const SizedBox(height: 10),
                              _buildActionButtons(
                                isDarkMode,
                                darkAccent,
                                isOwner,
                              ),
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DANH SÁCH BÀI HÁT',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: isDarkMode
                                            ? darkAccent.withValues(alpha: 0.7)
                                            : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (playlistSongs.isEmpty)
                          SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Chưa có bài hát nào trong playlist',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final song = playlistSongs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: _buildSongItem(isDarkMode, song),
                              );
                            }, childCount: playlistSongs.length),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
                  const MiniPlayer(),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isDarkMode ? darkAccent : Colors.black,
            unselectedItemColor: isDarkMode ? Colors.grey : Colors.grey,
            backgroundColor: isDarkMode ? darkBackground : Colors.white,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 8,
            onTap: (index) {},
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.home,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.library_music,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.library_music,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Thư viện',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.add_circle_outline,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Thêm nhạc',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.favorite_border,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Yêu thích',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.settings,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Cài đặt',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 100, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [accent.withValues(alpha: 0.15), const Color(0xFF121212)]
              : [Colors.grey[200]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? accent.withValues(alpha: 0.1)
                      : Colors.black26,
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _currentPlaylist.coverPath != null
                  ? Image.asset(_currentPlaylist.coverPath!, fit: BoxFit.cover)
                  : Container(
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                      child: const Icon(CupertinoIcons.music_albums, size: 50),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _currentPlaylist.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tác giả: ',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              Text(
                _currentPlaylist.creatorEmail ?? 'Không xác định',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? accent : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode, Color accent, bool isOwner) {
    final leftBtnBg = isDarkMode ? Colors.grey[850]! : Colors.black;
    final rightIconColor = isDarkMode ? accent : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isOwner)
                _buildSmallIconButton(
                  CupertinoIcons.add,
                  'Thêm',
                  leftBtnBg,
                  Colors.white,
                  onTap: () => _showAddSongSheet(isDarkMode),
                ),
              if (isOwner) const SizedBox(width: 8),
              if (isOwner)
                _buildSmallIconButton(
                  CupertinoIcons.pen,
                  'Sửa',
                  leftBtnBg,
                  Colors.white,
                  onTap: () => _showEditSheet(isDarkMode),
                ),
              if (!isOwner)
                Text(
                  ' ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Icon(CupertinoIcons.shuffle, color: rightIconColor, size: 26),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: rightIconColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rightIconColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.play_fill,
                  color: isDarkMode ? Colors.black : Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton(
    IconData icon,
    String label,
    Color bg,
    Color text, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: text, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: text,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(bool isDarkMode, Song song) {
    return GestureDetector(
      onTap: () => _openSongDetail(song),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 55,
                height: 55,
                color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                child: song.coverPath != null
                    ? Image.asset(song.coverPath!, fit: BoxFit.cover)
                    : const Icon(CupertinoIcons.music_note, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.ellipsis,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSongToPlaylistSheet extends StatefulWidget {
  final bool isDarkMode;
  final Playlist playlist;
  final Function(Playlist) onSave;

  const _AddSongToPlaylistSheet({
    required this.isDarkMode,
    required this.playlist,
    required this.onSave,
  });

  @override
  State<_AddSongToPlaylistSheet> createState() =>
      _AddSongToPlaylistSheetState();
}

class _AddSongToPlaylistSheetState extends State<_AddSongToPlaylistSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<String> _selectedSongIds;

  @override
  void initState() {
    super.initState();
    _selectedSongIds = List<String>.from(widget.playlist.songIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addSong(String songId) {
    setState(() {
      if (!_selectedSongIds.contains(songId)) {
        _selectedSongIds.add(songId);
      }
    });
  }

  void _save() {
    final updatedPlaylist = widget.playlist.copyWith(songIds: _selectedSongIds);
    widget.onSave(updatedPlaylist);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
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
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: Icon(
                    CupertinoIcons.checkmark,
                    color: widget.isDarkMode
                        ? const Color(0xFFFEEC93)
                        : CupertinoColors.systemYellow,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài hát...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.grey[500]
                      : CupertinoColors.placeholderText,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: widget.isDarkMode
                      ? Colors.grey[500]
                      : CupertinoColors.systemGrey,
                ),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.grey[800]
                    : CupertinoColors.systemGrey6,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<SongProvider>(
              builder: (context, songProvider, child) {
                var availableSongs = songProvider.songs
                    .where((song) => !_selectedSongIds.contains(song.id))
                    .toList();

                if (_searchQuery.isNotEmpty) {
                  availableSongs = availableSongs.where((song) {
                    return song.title.toLowerCase().contains(_searchQuery) ||
                        song.artist.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (availableSongs.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Tất cả bài hát đã được thêm'
                          : 'Không tìm thấy bài hát',
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : CupertinoColors.secondaryLabel,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableSongs.length,
                  itemBuilder: (context, index) {
                    final song = availableSongs[index];
                    return _buildAddableSongItem(song);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddableSongItem(Song song) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = widget.isDarkMode
        ? Colors.grey[400]
        : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: widget.isDarkMode
                  ? Colors.grey[800]
                  : CupertinoColors.systemGrey6,
            ),
            child: song.coverPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(song.coverPath!, fit: BoxFit.cover),
                  )
                : Icon(
                    CupertinoIcons.music_note,
                    color: widget.isDarkMode
                        ? Colors.grey[600]
                        : CupertinoColors.systemGrey,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _addSong(song.id!),
            child: Icon(
              CupertinoIcons.plus_circle_fill,
              color: widget.isDarkMode
                  ? const Color(0xFFFEEC93)
                  : CupertinoColors.systemYellow,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditPlaylistSheet extends StatefulWidget {
  final bool isDarkMode;
  final Playlist playlist;
  final Function(Playlist) onSave;

  const _EditPlaylistSheet({
    required this.isDarkMode,
    required this.playlist,
    required this.onSave,
  });

  @override
  State<_EditPlaylistSheet> createState() => _EditPlaylistSheetState();
}

class _EditPlaylistSheetState extends State<_EditPlaylistSheet> {
  late List<String> _songIds;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _songIds = List<String>.from(widget.playlist.songIds);
    _nameController = TextEditingController(text: widget.playlist.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _removeSong(int index) {
    setState(() {
      _songIds.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _songIds.removeAt(oldIndex);
      _songIds.insert(newIndex, item);
    });
  }

  void _save() {
    final updatedPlaylist = widget.playlist.copyWith(
      name: _nameController.text.trim(),
      songIds: _songIds,
    );
    widget.onSave(updatedPlaylist);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
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
                  'Chỉnh sửa playlist',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode
                        ? Colors.white
                        : CupertinoColors.label,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: Icon(
                    CupertinoIcons.checkmark,
                    color: widget.isDarkMode
                        ? const Color(0xFFFEEC93)
                        : CupertinoColors.systemYellow,
                  ),
                ),
              ],
            ),
          ),
          // Phần đổi tên playlist
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tên playlist',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Nhập tên playlist...',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  placeholderStyle: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey[500]
                        : CupertinoColors.placeholderText,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? Colors.grey[800]
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: widget.isDarkMode
                ? Colors.grey[700]
                : CupertinoColors.systemGrey4,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Danh sách bài hát',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_songIds.length} bài hát',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode
                        ? Colors.grey[500]
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SongProvider>(
              builder: (context, songProvider, child) {
                final List<Song> orderedSongs = [];
                for (final songId in _songIds) {
                  final song = songProvider.songs.firstWhere(
                    (s) => s.id == songId,
                    orElse: () => Song(
                      title: 'Unknown',
                      artist: 'Unknown',
                      album: '',
                      duration: 0,
                    ),
                  );
                  if (song.id != null) {
                    orderedSongs.add(song);
                  }
                }

                if (orderedSongs.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có bài hát nào',
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : CupertinoColors.secondaryLabel,
                      ),
                    ),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: orderedSongs.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final song = orderedSongs[index];
                    return _buildEditableSongItem(
                      key: ValueKey('song_${index}_${song.id}'),
                      song: song,
                      index: index,
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

  Widget _buildEditableSongItem({
    required Key key,
    required Song song,
    required int index,
  }) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = widget.isDarkMode
        ? Colors.grey[400]
        : Colors.grey[600];

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _removeSong(index),
            child: Icon(
              CupertinoIcons.minus_circle_fill,
              color: widget.isDarkMode
                  ? Colors.red[400]
                  : CupertinoColors.destructiveRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: widget.isDarkMode
                  ? Colors.grey[800]
                  : CupertinoColors.systemGrey6,
            ),
            child: song.coverPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(song.coverPath!, fit: BoxFit.cover),
                  )
                : Icon(
                    CupertinoIcons.music_note,
                    color: widget.isDarkMode
                        ? Colors.grey[600]
                        : CupertinoColors.systemGrey,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            CupertinoIcons.line_horizontal_3,
            color: widget.isDarkMode
                ? Colors.grey[500]
                : CupertinoColors.systemGrey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
