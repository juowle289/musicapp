import 'dart:ui';
import 'package:flutter/material.dart';

class ColorProvider with ChangeNotifier {
  Color _dominantColor = const Color(0xFF121212);
  Color _dominantTextColor = Colors.white;

  Color get dominantColor => _dominantColor;
  Color get dominantTextColor => _dominantTextColor;

  Future<void> extractColorFromImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      // Default dark colors
      _dominantColor = const Color(0xFF121212);
      _dominantTextColor = Colors.white;
      notifyListeners();
      return;
    }

    try {
      // Generate a color based on the song title/artist hash
      // This creates a consistent color for each song
      final String colorKey = imagePath;
      final int hash = colorKey.hashCode;

      // Generate colors from hash
      final int r = (hash & 0xFF0000) >> 16;
      final int g = (hash & 0x00FF00) >> 8;
      final int b = hash & 0x0000FF;

      Color baseColor = Color.fromARGB(255, r, g, b);

      // Use darker variant for background
      _dominantColor = _getDarkVariant(baseColor);

      // Determine text color based on brightness
      _dominantTextColor = _getTextColor(baseColor);

      notifyListeners();
    } catch (e) {
      // Fallback on error
      _dominantColor = const Color(0xFF121212);
      _dominantTextColor = Colors.white;
      notifyListeners();
    }
  }

  Color _getDarkVariant(Color color) {
    // Create a darker version of the color for background
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.3).clamp(0.05, 0.3)).toColor();
  }

  Color _getTextColor(Color color) {
    // Determine if text should be light or dark based on color brightness
    final double luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void reset() {
    _dominantColor = const Color(0xFF121212);
    _dominantTextColor = Colors.white;
    notifyListeners();
  }
}
