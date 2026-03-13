import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        IconButton,
        Brightness,
        Colors,
        AlertDialog,
        showDialog,
        showModalBottomSheet,
        ListTile,
        TextField,
        TextButton,
        GestureDetector;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/models/playlist.dart';
import 'package:musicapp/datas/providers/song_provider.dart';
import 'package:musicapp/datas/providers/playlist_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/presentation/widgets/chip_filter.dart';
import 'package:musicapp/presentation/pages/add_playlist.dart';
import 'package:musicapp/presentation/pages/playlist_detail_page.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';
import 'package:musicapp/presentation/pages/search_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedChipIndex = 0;

  final List<String> _chipLabels = ['Tất cả', 'Bài hát', 'Playlist', 'Của tôi'];

  void _openSearchPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
          child: CupertinoPageScaffold(
            backgroundColor: isDarkMode
                ? const Color(0xFF121212)
                : CupertinoColors.systemBackground,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: isDarkMode
                  ? const Color(0xFF121212).withValues(alpha: 0.8)
                  : CupertinoColors.systemBackground.withValues(alpha: 0.8),
              border: null,
              middle: Text(
                'Thư viện',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavButton(
                    CupertinoIcons.search,
                    _openSearchPage,
                    isDarkMode,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ChipFilter(
                      labels: _chipLabels,
                      selectedIndex: _selectedChipIndex,
                      useContainerStyle: true,
                      isDarkMode: isDarkMode,
                      onSelected: (index) {
                        setState(() => _selectedChipIndex = index);
                      },
                    ),
                  ),
                  Expanded(child: _buildContent(isDarkMode)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : CupertinoColors.systemGrey6,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.white : CupertinoColors.label,
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    switch (_selectedChipIndex) {
      case 1:
        return _buildSongsList(isDarkMode);
      case 2:
        return _buildPlaylistsList(isDarkMode);
      case 3:
        return _buildMyContent(isDarkMode);
      default:
        return _buildAllContent(isDarkMode);
    }
  }

  Widget _buildAllContent(bool isDarkMode) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        if (playlistProvider.isLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
            ),
          );
        }

        final playlists = playlistProvider.playlists;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (playlists.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Playlist',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
              ),
              ...playlists.map(
                (playlist) => _buildPlaylistItem(playlist, isDarkMode),
              ),
            ],
            const SizedBox(height: 10),
            _buildCreatePlaylistCard(isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildPlaylistsList(bool isDarkMode) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
            ),
          );
        }

        final playlists = provider.playlists;
        if (playlists.isEmpty) return _buildEmptyPlaylists(isDarkMode);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: playlists.length + 1,
          itemBuilder: (context, index) {
            if (index == playlists.length) {
              return _buildCreatePlaylistCard(isDarkMode);
            }
            return _buildPlaylistItem(playlists[index], isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildPlaylistItem(Playlist playlist, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => PlaylistDetailPage(playlist: playlist),
            ),
          );
        },
        child: Row(
          children: [
            _buildCoverWrapper(
              isDarkMode: isDarkMode,
              child: playlist.coverPath != null
                  ? Image.asset(playlist.coverPath!, fit: BoxFit.cover)
                  : Icon(
                      CupertinoIcons.music_albums,
                      size: 32,
                      color: isDarkMode
                          ? Colors.grey[600]
                          : CupertinoColors.systemGrey,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : CupertinoColors.label,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist.songIds.length} bài hát',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: isDarkMode
                  ? Colors.grey[600]
                  : CupertinoColors.systemGrey2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePlaylistCard(bool isDarkMode) {
    return CupertinoButton(
      padding: const EdgeInsets.only(bottom: 16),
      onPressed: () => _navigateToCreatePlaylist(),
      child: Row(
        children: [
          _buildCoverWrapper(
            isDarkMode: isDarkMode,
            isDash: true,
            child: Icon(
              CupertinoIcons.plus,
              size: 30,
              color: isDarkMode ? Colors.grey[600] : CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo playlist mới',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                Text(
                  'Lưu trữ các bài hát yêu thích',
                  style: TextStyle(
                    fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildCoverWrapper({
    required Widget child,
    bool isDash = false,
    required bool isDarkMode,
  }) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
        border: isDash
            ? Border.all(
                color: isDarkMode
                    ? Colors.grey[700]!
                    : CupertinoColors.systemGrey4,
                width: 1,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }

  Widget _buildSongsList(bool isDarkMode) {
    return Consumer<SongProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
            ),
          );
        }

        final songs = provider.songs;
        if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.music_note_list,
                  size: 64,
                  color: isDarkMode
                      ? Colors.grey[600]
                      : CupertinoColors.systemGrey3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có bài hát nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: songs.length,
          itemBuilder: (context, index) =>
              _buildSongItem(songs[index], isDarkMode),
        );
      },
    );
  }

  Widget _buildSongItem(
    Song song,
    bool isDarkMode, {
    bool showEditDelete = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => SongDetailPage(song: song)),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: _buildCoverWrapper(
                isDarkMode: isDarkMode,
                child: song.coverPath != null
                    ? Image.asset(song.coverPath!, fit: BoxFit.cover)
                    : Icon(
                        CupertinoIcons.music_note,
                        color: isDarkMode
                            ? Colors.grey[600]
                            : CupertinoColors.systemGrey,
                      ),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : CupertinoColors.label,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: 16,
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
            if (showEditDelete) ...[
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showEditSongSheet(song, isDarkMode),
                child: Icon(
                  CupertinoIcons.pencil_circle,
                  size: 20,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : CupertinoColors.systemGrey,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showDeleteConfirmDialog(song, isDarkMode),
                child: Icon(
                  CupertinoIcons.minus_circle,
                  size: 20,
                  color: isDarkMode
                      ? Colors.red[400]
                      : CupertinoColors.destructiveRed,
                ),
              ),
            ] else ...[
              if (song.duration > 0)
                Text(
                  '${(song.duration / 60).floor()}:${(song.duration % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditSongSheet(Song song, bool isDarkMode) {
    final titleController = TextEditingController(text: song.title);
    final artistController = TextEditingController(text: song.artist);
    final albumController = TextEditingController(text: song.album);
    final coverController = TextEditingController(text: song.coverPath ?? '');
    final audioController = TextEditingController(text: song.audioPath ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode
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
                    color: isDarkMode
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
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.label,
                      ),
                    ),
                  ),
                  Text(
                    'Sửa bài hát',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : CupertinoColors.label,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final updatedSong = song.copyWith(
                        title: titleController.text.trim(),
                        artist: artistController.text.trim(),
                        album: albumController.text.trim(),
                        coverPath: coverController.text.trim().isNotEmpty
                            ? coverController.text.trim()
                            : null,
                        audioPath: audioController.text.trim().isNotEmpty
                            ? audioController.text.trim()
                            : null,
                      );
                      await context.read<SongProvider>().updateSong(
                        updatedSong,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text(
                      'Lưu',
                      style: TextStyle(
                        color: isDarkMode
                            ? const Color(0xFFFEEC93)
                            : CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildEditField('Tên bài hát', titleController, isDarkMode),
                  const SizedBox(height: 16),
                  _buildEditField('Nghệ sĩ', artistController, isDarkMode),
                  const SizedBox(height: 16),
                  _buildEditField('Album', albumController, isDarkMode),
                  const SizedBox(height: 16),
                  _buildEditField(
                    'Ảnh bìa (assets/images/...)',
                    coverController,
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildEditField(
                    'Audio (assets/audios/...)',
                    audioController,
                    isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode
                ? Colors.grey[400]
                : CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: label,
          style: TextStyle(
            color: isDarkMode ? Colors.white : CupertinoColors.label,
          ),
          placeholderStyle: TextStyle(
            color: isDarkMode
                ? Colors.grey[500]
                : CupertinoColors.placeholderText,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(Song song, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài hát'),
        content: Text('Bạn có muốn xóa bài hát "${song.title}" không?'),
        backgroundColor: isDarkMode
            ? const Color(0xFF1E1E1E)
            : CupertinoColors.systemBackground,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await context.read<SongProvider>().deleteSong(song.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreatePlaylist() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const AddPlaylistPage()),
    );
  }

  Widget _buildEmptyPlaylists(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.music_albums,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : CupertinoColors.systemGrey3,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có playlist nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _navigateToCreatePlaylist(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Tạo ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyContent(bool isDarkMode) {
    final authProvider = context.read<AuthProvider>();
    final currentUserEmail = authProvider.userEmail;

    return Consumer2<SongProvider, PlaylistProvider>(
      builder: (context, songProvider, playlistProvider, child) {
        if (songProvider.isLoading || playlistProvider.isLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
            ),
          );
        }

        final mySongs = songProvider.songs
            .where((song) => song.creatorEmail == currentUserEmail)
            .toList();

        final myPlaylists = playlistProvider.playlists
            .where((playlist) => playlist.creatorEmail == currentUserEmail)
            .toList();

        if (mySongs.isEmpty && myPlaylists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 64,
                  color: isDarkMode
                      ? Colors.grey[600]
                      : CupertinoColors.systemGrey3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Của tôi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn chưa thêm tài liệu nào.\nHãy tạo bài hát hoặc playlist để hiển thị ở đây.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : CupertinoColors.secondaryLabel,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _navigateToCreatePlaylist(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Tạo playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (mySongs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Text(
                  'Bài hát của bạn (${mySongs.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
              ),
              ...mySongs.map(
                (song) =>
                    _buildSongItem(song, isDarkMode, showEditDelete: true),
              ),
            ],

            if (myPlaylists.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Text(
                  'Playlist của bạn (${myPlaylists.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
              ),
              ...myPlaylists.map(
                (playlist) => _buildPlaylistItem(playlist, isDarkMode),
              ),
            ],
          ],
        );
      },
    );
  }
}
