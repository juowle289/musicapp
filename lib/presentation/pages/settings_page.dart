import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Brightness,
        Colors,
        Material,
        InkWell,
        AlertDialog,
        TextButton,
        showDialog;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/presentation/pages/statistic_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                  ? const Color(0xFF121212).withOpacity(0.8)
                  : CupertinoColors.systemBackground.withValues(alpha: 0.8),
              middle: Text(
                'Cài đặt',
                style: TextStyle(
                  fontSize: 20,
                  color: isDarkMode ? Colors.white : CupertinoColors.label,
                ),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Cài đặt hồ sơ
                    _buildSectionHeader('Cài đặt hồ sơ', isDarkMode),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        context: context,
                        icon: CupertinoIcons.person,
                        title: 'Chi tiết cá nhân',
                        onTap: () {},
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: CupertinoIcons.bell,
                        title: 'Thông báo',
                        onTap: () {},
                        isDarkMode: isDarkMode,
                      ),
                      _buildThemeToggleTile(themeProvider, isDarkMode),
                    ], isDarkMode),

                    const SizedBox(height: 24),

                    // Công cụ
                    _buildSectionHeader('Công cụ', isDarkMode),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        context: context,
                        icon: CupertinoIcons.chart_bar,
                        title: 'Thống kê',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (_) => const StatisticPage()),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: CupertinoIcons.chat_bubble_2,
                        title: 'Trao đổi',
                        onTap: () {},
                        isDarkMode: isDarkMode,
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: CupertinoIcons.question_circle,
                        title: 'Trợ giúp',
                        onTap: () {},
                        isDarkMode: isDarkMode,
                      ),
                    ], isDarkMode),

                    const SizedBox(height: 24),

                    // Logout
                    _buildSettingsTile(
                      context: context,
                      icon: CupertinoIcons.square_arrow_right,
                      title: 'Đăng xuất',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () => _showLogoutDialog(context, isDarkMode),
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
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
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(context);
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.grey[400] : CupertinoColors.systemGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 26,
                color: iconColor ?? (isDarkMode ? Colors.white : CupertinoColors.label),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: titleColor ?? (isDarkMode ? Colors.white : CupertinoColors.label),
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 20,
                color: isDarkMode ? Colors.grey[600] : CupertinoColors.systemGrey3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleTile(ThemeProvider themeProvider, bool isDarkMode) {
    final darkAccent = const Color(0xFFFEEC93);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => themeProvider.toggleTheme(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                themeProvider.isDarkMode
                    ? CupertinoIcons.moon_fill
                    : CupertinoIcons.sun_max_fill,
                size: 22,
                color: themeProvider.isDarkMode ? darkAccent : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Giao diện: ${themeProvider.isDarkMode ? "Tối" : "Sáng"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : CupertinoColors.label,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeTrackColor: darkAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
