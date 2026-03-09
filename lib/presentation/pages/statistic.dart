import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show AnimatedContainer, BorderRadius, BoxDecoration, BoxShadow, Colors, GestureDetector, Image, Material, TextStyle;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/song_provider.dart';
import 'package:musicapp/datas/models/song.dart';

class SongData {
  final String title;
  final String artist;
  final String? coverPath;
  final int playCount;

  SongData({
    required this.title,
    required this.artist,
    this.coverPath,
    required this.playCount,
  });
}

class VinylTopSongsChart extends StatefulWidget {
  const VinylTopSongsChart({super.key});

  @override
  State<VinylTopSongsChart> createState() => _VinylTopSongsChartState();
}

class _VinylTopSongsChartState extends State<VinylTopSongsChart> {
  int? _touchedIndex;

  // Màu sắc cho biểu đồ - đa sắc
  final List<Color> _chartColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFF95E1D3),
    const Color(0xFFDDA0DD),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final songProvider = context.watch<SongProvider>();
    final isDark = themeProvider.isDarkMode;

    // Lấy top 5 bài hát được nghe nhiều nhất
    final topSongs = songProvider.topSongs;
    
    // Chuyển đổi dữ liệu
    final List<SongData> songs = topSongs.map((song) {
      return SongData(
        title: song.title,
        artist: song.artist,
        coverPath: song.coverPath,
        playCount: song.playCount,
      );
    }).toList();

    // Nếu không có dữ liệu, hiển thị thông báo
    if (songs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Material(
          child: Column(
            children: [
              Text(
                "Top bài hát được nghe nhiều nhất",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Icon(
                CupertinoIcons.music_note_list,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu\nHãy nghe nhạc để thống kê!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    // Tính tổng play count
    final totalPlays = songs.fold<int>(0, (sum, song) => sum + song.playCount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top bài hát được nghe nhiều nhất",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Biểu đồ Vinyl (Pie Chart)
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = null;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: _buildSections(songs, totalPlays),
                  ),
                ),
                // Center - Total plays
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark 
                        ? const Color(0xFF2A2A2A) 
                        : Colors.grey[100],
                    border: Border.all(
                      color: isDark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.play_fill,
                        size: 20,
                        color: isDark 
                            ? Colors.grey[400] 
                            : Colors.grey[600],
                      ),
                      Text(
                        '$totalPlays',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Danh sách top bài hát
          ...songs.asMap().entries.map((entry) {
            final index = entry.key;
            final song = entry.value;
            final isSelected = _touchedIndex == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _touchedIndex = isSelected ? null : index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _chartColors[index % _chartColors.length].withValues(alpha: 0.15) 
                      : (isDark 
                          ? Colors.grey[800] 
                          : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                      ? Border.all(
                          color: _chartColors[index % _chartColors.length], 
                          width: 2) 
                      : null,
                ),
                child: Row(
                  children: [
                    // Số thứ tự
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _chartColors[index % _chartColors.length],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Ảnh bìa
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: song.coverPath != null
                          ? Image.asset(
                              song.coverPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                CupertinoIcons.music_note,
                                size: 20,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            )
                          : Icon(
                              CupertinoIcons.music_note,
                              size: 20,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Tên bài hát và nghệ sĩ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Số lượt nghe
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${song.playCount}',
                          style: TextStyle(
                            color: _chartColors[index % _chartColors.length],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'lượt',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<SongData> songs, int totalPlays) {
    return songs.asMap().entries.map((entry) {
      final index = entry.key;
      final song = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 50.0 : 40.0;
      final fontSize = isTouched ? 14.0 : 10.0;
      final percentage = totalPlays > 0 ? (song.playCount / totalPlays * 100).round() : 0;

      return PieChartSectionData(
        color: _chartColors[index % _chartColors.length],
        value: song.playCount.toDouble(),
        title: isTouched ? '$percentage%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
      );
    }).toList();
  }
}

// Widget chính để export
class MusicBioChart extends StatelessWidget {
  const MusicBioChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const VinylTopSongsChart();
  }
}
