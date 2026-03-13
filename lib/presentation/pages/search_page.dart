import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Brightness, Colors, Divider, Material;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/models/playlist.dart';
import 'package:musicapp/datas/providers/song_provider.dart';
import 'package:musicapp/datas/providers/playlist_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/datas/providers/loved_provider.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';
import 'package:musicapp/presentation/pages/playlist_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      _hasSearched = query.isNotEmpty;
    });
  }

  void _toggleLoveSong(Song song) {
    final authProvider = context.read<AuthProvider>();
    final lovedProvider = context.read<LovedProvider>();
    lovedProvider.toggleLovedSong(song, authProvider.userEmail);
    setState(() {});
  }

  List<Song> _getFilteredSongs(List<Song> songs) {
    if (_searchQuery.isEmpty) return [];
    return songs.where((song) {
      return song.title.toLowerCase().contains(_searchQuery) ||
          song.artist.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Playlist> _getFilteredPlaylists(List<Playlist> playlists) {
    if (_searchQuery.isEmpty) return [];
    return playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Song> _getSuggestions(List<Song> songs) {
    if (_searchQuery.isEmpty) {
      return songs.take(5).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final darkAccent = const Color(0xFFFEEC93);
        final darkBackground = const Color(0xFF121212);

        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
          child: CupertinoPageScaffold(
            backgroundColor: isDarkMode
                ? darkBackground
                : CupertinoColors.systemBackground,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    // Thanh tìm kiếm và nút Hủy
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CupertinoTextField(
                                controller: _searchController,
                                placeholder: 'Tìm Kiếm bài hát, playlist...',
                                placeholderStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[500]
                                      : CupertinoColors.placeholderText,
                                ),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : CupertinoColors.label,
                                ),
                                prefix: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Icon(
                                    CupertinoIcons.search,
                                    size: 20,
                                    color: isDarkMode
                                        ? Colors.grey[500]
                                        : CupertinoColors.systemGrey,
                                  ),
                                ),
                                decoration: const BoxDecoration(),
                                onChanged: _onSearch,
                                onSubmitted: _onSearch,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : CupertinoColors.label,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Nội dung
                    Expanded(
                      child: _hasSearched
                          ? _buildSearchResults(isDarkMode, darkAccent)
                          : _buildSuggestions(isDarkMode, darkAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions(bool isDarkMode, Color darkAccent) {
    return Consumer2<SongProvider, LovedProvider>(
      builder: (context, songProvider, lovedProvider, child) {
        // Loading indicator
        if (songProvider.isLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
            ),
          );
        }

        final suggestions = _getSuggestions(songProvider.songs);

        if (suggestions.isEmpty) {
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
                    color: isDarkMode
                        ? Colors.grey[400]
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đề xuất',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 12),
              ...suggestions.map(
                (song) =>
                    _buildSongItem(song, isDarkMode, darkAccent, lovedProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(bool isDarkMode, Color darkAccent) {
    return Consumer2<SongProvider, PlaylistProvider>(
      builder: (context, songProvider, playlistProvider, child) {
        // Loading indicator
        if (songProvider.isLoading || playlistProvider.isLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 16,
              color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
            ),
          );
        }

        return Consumer<LovedProvider>(
          builder: (context, lovedProvider, child) {
            final filteredSongs = _getFilteredSongs(songProvider.songs);
            final filteredPlaylists = _getFilteredPlaylists(
              playlistProvider.playlists,
            );

            if (filteredSongs.isEmpty && filteredPlaylists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 64,
                      color: isDarkMode
                          ? Colors.grey[600]
                          : CupertinoColors.systemGrey3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy kết quả',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thử tìm kiếm từ khóa khác',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey[400]
                            : CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bài hát
                  if (filteredSongs.isNotEmpty) ...[
                    _buildSectionHeader('Bài hát', isDarkMode, darkAccent),
                    const SizedBox(height: 12),
                    ...filteredSongs.map(
                      (song) => _buildSongItem(
                        song,
                        isDarkMode,
                        darkAccent,
                        lovedProvider,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Playlist
                  if (filteredPlaylists.isNotEmpty) ...[
                    _buildSectionHeader('Playlist', isDarkMode, darkAccent),
                    const SizedBox(height: 12),
                    ...filteredPlaylists.map(
                      (playlist) => _buildPlaylistItem(playlist, isDarkMode),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, Color darkAccent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : CupertinoColors.label,
          ),
        ),
        Text(
          'Xem hết',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? darkAccent : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSongItem(
    Song song,
    bool isDarkMode,
    Color darkAccent,
    LovedProvider lovedProvider,
  ) {
    final isLoved = lovedProvider.isSongLoved(song.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => SongDetailPage(song: song)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isDarkMode
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
                      color: isDarkMode
                          ? Colors.grey[600]
                          : CupertinoColors.systemGrey,
                      size: 20,
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
                  const SizedBox(height: 4),
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
            GestureDetector(
              onTap: () => _toggleLoveSong(song),
              child: Icon(
                isLoved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 26,
                color: isLoved
                    ? (isDarkMode ? darkAccent : CupertinoColors.systemYellow)
                    : (isDarkMode
                          ? Colors.grey[600]
                          : CupertinoColors.systemGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(Playlist playlist, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDarkMode
                    ? Colors.grey[800]
                    : CupertinoColors.systemGrey6,
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
                      color: isDarkMode
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
                    playlist.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : CupertinoColors.label,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist.songIds.length} bài hát',
                    style: TextStyle(
                      fontSize: 13,
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
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: isDarkMode
                  ? Colors.grey[600]
                  : CupertinoColors.systemGrey2,
            ),
          ],
        ),
      ),
    );
  }
}
