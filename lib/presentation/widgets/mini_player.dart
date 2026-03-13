import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        BoxDecoration,
        BoxShadow,
        LinearProgressIndicator,
        AlwaysStoppedAnimation;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/music_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  bool _isCompact = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleCompact() {
    setState(() {
      _isCompact = !_isCompact;
      if (_isCompact) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
        _rotationController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicProvider, ThemeProvider>(
      builder: (context, musicProvider, themeProvider, child) {
        final currentSong = musicProvider.currentSong;
        final isDarkMode = themeProvider.isDarkMode;
        final darkBackground = const Color(0xFF121212);
        final darkAccent = const Color(0xFFFEEC93);

        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = musicProvider.isPlaying;
        final progress = musicProvider.totalDurationSeconds > 0
            ? musicProvider.currentPositionSeconds /
                  musicProvider.totalDurationSeconds
            : 0.0;

        if (isPlaying && !_rotationController.isAnimating) {
          _rotationController.repeat();
        } else if (!isPlaying && _rotationController.isAnimating) {
          _rotationController.stop();
        }

        if (_isCompact) {
          return _buildCompactMode(
            context,
            musicProvider,
            currentSong,
            isDarkMode,
            isPlaying,
          );
        }

        return GestureDetector(
          onTap: () => _openSongDetail(context, currentSong),
          child: Container(
            height: 64,
            width: MediaQuery.of(context).size.width - 32,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? darkBackground.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Album cover that rotates
                          GestureDetector(
                            onTap: _toggleCompact,
                            child: AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle:
                                      _rotationController.value * 2 * 3.14159,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child:
                                          currentSong.coverPath != null &&
                                              currentSong.coverPath!.isNotEmpty
                                          ? Image.asset(
                                              currentSong.coverPath!,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              CupertinoIcons.music_note,
                                              size: 20,
                                              color: isDarkMode
                                                  ? Colors.grey[600]
                                                  : CupertinoColors.systemGrey,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSong.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white
                                        : CupertinoColors.label,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentSong.artist,
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
                          GestureDetector(
                            onTap: () => musicProvider.togglePlayPause(),
                            child: Icon(
                              isPlaying
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.play_fill,
                              size: 28,
                              color: isDarkMode
                                  ? Colors.white
                                  : CupertinoColors.label,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                    width: MediaQuery.of(context).size.width - 32,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: isDarkMode
                          ? Colors.grey[800]!
                          : CupertinoColors.systemGrey5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? darkAccent : CupertinoColors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactMode(
    BuildContext context,
    MusicProvider musicProvider,
    Song currentSong,
    bool isDarkMode,
    bool isPlaying,
  ) {
    return GestureDetector(
      onTap: _toggleCompact,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating album cover
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child:
                          currentSong.coverPath != null &&
                              currentSong.coverPath!.isNotEmpty
                          ? Image.asset(
                              currentSong.coverPath!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              CupertinoIcons.music_note,
                              size: 24,
                              color: isDarkMode
                                  ? Colors.grey[600]
                                  : CupertinoColors.systemGrey,
                            ),
                    ),
                  ),
                );
              },
            ),
            // TODO Vinyl shine effect (static)
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
            // Center hole
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSongDetail(BuildContext context, Song song) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SongDetailPage(song: song),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 480),
      ),
    );
  }
}
