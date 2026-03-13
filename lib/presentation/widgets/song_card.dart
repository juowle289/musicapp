import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SongDetailPage(song: song),
              ),
            );
          },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: song.coverPath != null && song.coverPath!.isNotEmpty
                  ? Image.asset(
                      song.coverPath!,
                      height: 160,
                      width: 160,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 160,
                      width: 160,
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
            const SizedBox(height: 8),
            Text(
              song.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: TextStyle(
                color: isDarkMode
                    ? Colors.grey[400]
                    : CupertinoColors.systemGrey,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
