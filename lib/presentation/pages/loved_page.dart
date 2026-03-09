import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Brightness, Colors;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/loved_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';

class LovedPage extends StatefulWidget {
  const LovedPage({super.key});

  @override
  State<LovedPage> createState() => _LovedPageState();
}

class _LovedPageState extends State<LovedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLovedSongs();
    });
  }

  void _loadLovedSongs() {
    final authProvider = context.read<AuthProvider>();
    final lovedProvider = context.read<LovedProvider>();
    if (authProvider.userEmail != null) {
      lovedProvider.loadLovedSongs(authProvider.userEmail);
    }
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
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                'Yêu thích',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ),
              backgroundColor: isDarkMode
                  ? const Color(0xFF121212)
                  : CupertinoColors.systemBackground,
            ),
            backgroundColor: isDarkMode
                ? const Color(0xFF121212)
                : CupertinoColors.systemBackground,
            child: SafeArea(
              child: Consumer<LovedProvider>(
                builder: (context, lovedProvider, child) {
                  // Loading indicator
                  if (lovedProvider.isLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        radius: 16,
                        color: isDarkMode ? Colors.white : CupertinoColors.activeBlue,
                      ),
                    );
                  }
                  
                  final lovedSongs = lovedProvider.lovedSongs;

                  if (lovedSongs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.heart,
                            size: 80,
                            color: isDarkMode
                                ? Colors.grey[600]
                                : CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có bài yêu thích nào',
                            style: TextStyle(
                              fontSize: 20,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thả tim cho bài hát bạn yêu thích',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lovedSongs.length,
                    itemBuilder: (context, index) {
                      final song = lovedSongs[index];
                      return _buildLovedSongItem(song, isDarkMode);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLovedSongItem(song, bool isDarkMode) {
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
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDarkMode
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
                      color: isDarkMode
                          ? Colors.grey[600]
                          : CupertinoColors.systemGrey,
                      size: 24,
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
                      fontSize: 16,
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
            Icon(
              CupertinoIcons.heart_fill,
              color: isDarkMode
                  ? const Color(0xFFFEEC93)
                  : CupertinoColors.systemYellow,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
