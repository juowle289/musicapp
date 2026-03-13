import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Brightness,
        Colors,
        Icons,
        Divider,
        ListTile,
        showModalBottomSheet,
        BottomNavigationBar,
        BottomNavigationBarType,
        Theme,
        Scaffold,
        TextButton,
        IconButton,
        FloatingActionButtonLocation;
import 'package:provider/provider.dart';
import 'package:musicapp/presentation/pages/add_song_page.dart';
import 'package:musicapp/presentation/pages/add_playlist.dart';
import 'package:musicapp/presentation/pages/library_page.dart';
import 'package:musicapp/presentation/pages/loved_page.dart';
import 'package:musicapp/presentation/pages/settings_page.dart';
import 'package:musicapp/presentation/pages/song_detail_page.dart';
import 'package:musicapp/presentation/pages/search_page.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/providers/song_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/presentation/widgets/song_card.dart';
import 'package:musicapp/presentation/widgets/chip_filter.dart';
import 'package:musicapp/presentation/widgets/mini_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const LibraryPage(),
    const SizedBox(),
    const LovedPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddBottomSheet();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _openSearchPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const SearchPage()),
    );
  }

  void _showAddBottomSheet() {
    final themeProvider = context.read<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final darkBackground = const Color(0xFF2C2C2C);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkBackground : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[700]
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.music_albums,
                    size: 30,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                title: Text(
                  'Tạo playlist',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddPlaylistPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            );
                          },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDarkMode
                    ? Colors.grey[700]
                    : CupertinoColors.systemGrey5,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[700]
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.add,
                    size: 30,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                title: Text(
                  'Thêm nhạc',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const AddSongPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final darkAccent = const Color(0xFFFEEC93);
        final darkBackground = const Color(0xFF121212);

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          floatingActionButton: const MiniPlayer(),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isDarkMode ? darkAccent : Colors.black,
            unselectedItemColor: isDarkMode ? Colors.grey : Colors.grey,
            backgroundColor: isDarkMode ? darkBackground : Colors.white,
            selectedLabelStyle: TextStyle(
              color: isDarkMode ? darkAccent : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(
              color: isDarkMode ? Colors.grey : Colors.grey,
            ),
            showUnselectedLabels: true,
            selectedFontSize: 13,
            unselectedFontSize: 13,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  size: 30,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.home,
                  size: 30,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.library_music_outlined,
                  size: 30,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.library_music,
                  size: 30,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Thư viện',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 30,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.add_circle_sharp,
                  size: 30,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Thêm nhạc',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border_outlined,
                  size: 30,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.favorite_sharp,
                  size: 30,
                  color: isDarkMode ? darkAccent : Colors.black,
                ),
                label: 'Yêu thích',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings_outlined,
                  size: 30,
                  color: isDarkMode ? Colors.grey : Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.settings,
                  size: 30,
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
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _selectedChipIndex = 0;

  final List<String> _chipLabels = [
    'Tất cả',
    'Mới phát hành',
    'Trending',
    'Top',
  ];

  List<Song> _filterSongs(List<Song> songs) {
    return songs;
  }

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
            navigationBar: CupertinoNavigationBar(
              backgroundColor: isDarkMode
                  ? darkBackground.withValues(alpha: 0.8)
                  : CupertinoColors.systemBackground,
              middle: const SizedBox.shrink(),
              leading: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final email = authProvider.userEmail ?? 'user';
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Hi, $email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.label,
                      ),
                    ),
                  );
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _openSearchPage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[800]
                            : CupertinoColors.systemGrey5,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.search,
                        size: 20,
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[800]
                          : CupertinoColors.systemGrey5,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.bell,
                      size: 20,
                      color: isDarkMode ? Colors.white : CupertinoColors.label,
                    ),
                  ),
                  // const SizedBox(width: 8),
                ],
              ),
            ),
            child: SafeArea(
              child: Consumer<SongProvider>(
                builder: (context, provider, child) {
                  // Loading indicator
                  if (provider.isLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        radius: 16,
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.activeBlue,
                      ),
                    );
                  }

                  if (provider.songs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note_outlined,
                            size: 80,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có bài hát nào',
                            style: TextStyle(
                              fontSize: 20,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredSongs = _filterSongs(provider.songs);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ChipFilter(
                            labels: _chipLabels,
                            selectedIndex: _selectedChipIndex,
                            isDarkMode: isDarkMode,
                            onSelected: (index) {
                              setState(() => _selectedChipIndex = index);
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedChipIndex == 0
                                    ? 'Phổ biến ngày hôm nay'
                                    : _chipLabels[_selectedChipIndex],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : CupertinoColors.label,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Xem hết',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? darkAccent
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 222,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: SongCard(
                                  song: song,
                                  isDarkMode: isDarkMode,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            SongDetailPage(song: song),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bạn hay nghe gần đây',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : CupertinoColors.label,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Xem hết',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? darkAccent
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            itemCount: filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:
                                          song.coverPath != null &&
                                              song.coverPath!.isNotEmpty
                                          ? Image.asset(
                                              song.coverPath!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.grey[300],
                                              child: Icon(
                                                Icons.music_note,
                                                size: 30,
                                                color: isDarkMode
                                                    ? Colors.grey[600]
                                                    : Colors.grey,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : CupertinoColors.label,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  song.artist,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isDarkMode
                                                        ? Colors.grey[400]
                                                        : Colors.grey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(song.duration / 60).floor()}:${(song.duration % 60).toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
