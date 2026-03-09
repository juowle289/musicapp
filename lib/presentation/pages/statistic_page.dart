import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';
import 'package:musicapp/presentation/pages/statistic.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final darkBackground = const Color(0xFF121212);

        return CupertinoPageScaffold(
          backgroundColor: isDarkMode ? darkBackground : Colors.white,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: isDarkMode
                ? darkBackground.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            middle: Text(
              'Thống kê',
              style: TextStyle(
                color: isDarkMode ? Colors.white : CupertinoColors.label,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  const MusicBioChart(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
