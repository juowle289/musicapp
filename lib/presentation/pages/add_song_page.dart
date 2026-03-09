
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Brightness,
        Colors,
        LinearGradient,
        Alignment,
        BoxShadow,
        Scaffold;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/providers/song_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _coverController = TextEditingController();
  final _audioController = TextEditingController();

  // Validation error messages
  String? _titleError;
  String? _artistError;
  String? _albumError;
  String? _audioError;

  int _duration = 0;
  bool _isLoading = false;
  bool _isCalculatingDuration = false;

  void _validateForm() {
    setState(() {
      _titleError = null;
      _artistError = null;
      _albumError = null;
      _audioError = null;

      if (_titleController.text.trim().isEmpty) {
        _titleError = 'Vui lòng nhập tên bài hát';
      }
      if (_artistController.text.trim().isEmpty) {
        _artistError = 'Vui lòng nhập tên nghệ sĩ';
      }
      if (_albumController.text.trim().isEmpty) {
        _albumError = 'Vui lòng nhập tên album';
      }
      if (_audioController.text.trim().isEmpty) {
        _audioError = 'Vui lòng nhập đường dẫn audio';
      }
    });
  }

  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _artistController.text.trim().isNotEmpty &&
        _albumController.text.trim().isNotEmpty &&
        _audioController.text.trim().isNotEmpty;
  }

  Future<void> _calculateDuration() async {
    final audioPath = _audioController.text.trim();
    if (audioPath.isEmpty) {
      setState(() => _audioError = 'Vui lòng nhập đường dẫn audio trước');
      return;
    }

    setState(() => _isCalculatingDuration = true);

    try {
      final player = AudioPlayer();
      await player.setSource(
        AssetSource(audioPath.replaceFirst('assets/', '')),
      );
      final duration = await player.getDuration();
      if (duration != null && mounted) {
        setState(() => _duration = duration.inSeconds);
      }
      await player.dispose();
    } catch (e) {
      if (mounted) {
        setState(() => _audioError = 'Không thể tải audio, vui lòng kiểm tra đường dẫn');
      }
    }

    if (mounted) {
      setState(() => _isCalculatingDuration = false);
    }
  }

  Future<void> _save() async {
    _validateForm();

    if (!_isFormValid()) return;

    setState(() => _isLoading = true);

    // Get current user's email
    final authProvider = context.read<AuthProvider>();
    final creatorEmail = authProvider.userEmail;

    final song = Song(
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
      duration: _duration > 0 ? _duration : 180,
      coverPath: _coverController.text.trim().isNotEmpty
          ? _coverController.text.trim()
          : null,
      audioPath: _audioController.text.trim().isNotEmpty
          ? _audioController.text.trim()
          : null,
    );

    try {
      await Provider.of<SongProvider>(
        context,
        listen: false,
      ).addSong(song, creatorEmail: creatorEmail);

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Thành công'),
            content: const Text('Đã thêm bài hát mới'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: Text('Không thể thêm bài hát: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        );
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
                        'Thêm bài hát',
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

                // Song cover placeholder
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
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      CupertinoIcons.music_note,
                      size: 80,
                      color: isDarkMode ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Form fields
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView(
                      children: [
                        // Title field
                        _buildTextField(
                          controller: _titleController,
                          label: 'Tên bài hát',
                          placeholder: 'Nhập tên bài hát...',
                          isDarkMode: isDarkMode,
                          error: _titleError,
                          onChanged: (_) {
                            if (_titleError != null) {
                              setState(() => _titleError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Artist field
                        _buildTextField(
                          controller: _artistController,
                          label: 'Nghệ sĩ',
                          placeholder: 'Nhập tên nghệ sĩ...',
                          isDarkMode: isDarkMode,
                          error: _artistError,
                          onChanged: (_) {
                            if (_artistError != null) {
                              setState(() => _artistError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Album field
                        _buildTextField(
                          controller: _albumController,
                          label: 'Album',
                          placeholder: 'Nhập tên album...',
                          isDarkMode: isDarkMode,
                          error: _albumError,
                          onChanged: (_) {
                            if (_albumError != null) {
                              setState(() => _albumError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Audio path field
                        _buildTextField(
                          controller: _audioController,
                          label: 'Đường dẫn audio',
                          placeholder: 'assets/audios/ten_bai_hat.mp3',
                          isDarkMode: isDarkMode,
                          error: _audioError,
                          onChanged: (_) {
                            if (_audioError != null) {
                              setState(() => _audioError = null);
                            }
                            if (_duration > 0) {
                              setState(() => _duration = 0);
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Duration calculation button
                        Row(
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              onPressed: _isCalculatingDuration
                                  ? null
                                  : _calculateDuration,
                              child: _isCalculatingDuration
                                  ? const CupertinoActivityIndicator()
                                  : Text(
                                      'Tính thời lượng',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? const Color(0xFFFEEC93)
                                            : CupertinoColors.activeBlue,
                                      ),
                                    ),
                            ),
                            if (_duration > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${(_duration / 60).floor()}:${(_duration % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Cover path field
                        _buildTextField(
                          controller: _coverController,
                          label: 'Đường dẫn ảnh bìa (không bắt buộc)',
                          placeholder: 'assets/images/ten_anh.png',
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Add song button
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
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CupertinoActivityIndicator(),
                                const SizedBox(width: 8),
                                Text(
                                  'Đang thêm...',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Thêm bài hát',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required bool isDarkMode,
    String? error,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[400] : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          placeholderStyle: TextStyle(
            color: isDarkMode
                ? Colors.grey[500]
                : CupertinoColors.placeholderText,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: error != null
                ? Border.all(color: Colors.red, width: 1)
                : null,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : CupertinoColors.label,
          ),
          onChanged: onChanged,
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _coverController.dispose();
    _audioController.dispose();
    super.dispose();
  }
}


