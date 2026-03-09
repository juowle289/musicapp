import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Brightness,
        Colors,
        LinearGradient,
        Alignment,
        BoxShadow,
        Scaffold,
        ScaffoldMessenger,
        SnackBar;
import 'package:musicapp/presentation/pages/playlist_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/playlist_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';

class AddPlaylistPage extends StatefulWidget {
  const AddPlaylistPage({super.key});

  @override
  State<AddPlaylistPage> createState() => _AddPlaylistPageState();
}

class _AddPlaylistPageState extends State<AddPlaylistPage> {
  final _playlistNameController = TextEditingController();
  final _focusNode = FocusNode();

  // Validation error
  String? _nameError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _nameError = null;
      if (_playlistNameController.text.trim().isEmpty) {
        _nameError = 'Vui lòng nhập tên playlist';
      }
    });
  }

  bool _isFormValid() {
    return _playlistNameController.text.trim().isNotEmpty;
  }

  Future<void> _createPlaylist() async {
    _validateForm();

    if (!_isFormValid()) return;

    setState(() => _isLoading = true);

    // Get current user's email
    final authProvider = context.read<AuthProvider>();
    final creatorEmail = authProvider.userEmail;

    // Add playlist to database via Provider
    final playlistProvider = context.read<PlaylistProvider>();

    try {
      final playlist = await playlistProvider.addPlaylist(
        _playlistNameController.text.trim(),
        creatorEmail: creatorEmail,
      );

      if (!mounted) return;

      if (playlist != null) {
        // Pop back to library page
        Navigator.pop(context);

        // Navigate to playlist detail page
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Thêm playlist thất bại')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final darkBackground = const Color(0xFF121212);

        return Scaffold(
          backgroundColor: isDarkMode ? darkBackground : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 18,
                            color: isDarkMode
                                ? Colors.white
                                : CupertinoColors.label,
                          ),
                        ),
                      ),
                      Text(
                        'Tạo playlist',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Playlist cover placeholder
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [Colors.grey[800]!, Colors.grey[700]!]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      CupertinoIcons.music_albums,
                      size: 80,
                      color: isDarkMode ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Playlist name input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tên playlist',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _playlistNameController,
                        focusNode: _focusNode,
                        placeholder: 'Nhập tên playlist...',
                        placeholderStyle: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[500]
                              : CupertinoColors.placeholderText,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[800]
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: _nameError != null
                              ? Border.all(color: Colors.red, width: 1)
                              : null,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.white
                              : CupertinoColors.label,
                        ),
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                        onSubmitted: (_) => _createPlaylist(),
                      ),
                      if (_nameError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _nameError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // Create button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: isDarkMode
                          ? const Color(0xFFFEEC93)
                          : Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      onPressed: _isLoading ? null : _createPlaylist,
                      child: _isLoading
                          ? const CupertinoActivityIndicator()
                          : Text(
                              'Tạo playlist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
