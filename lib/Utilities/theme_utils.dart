import 'package:flutter/material.dart';

Color getNoteColor(BuildContext context, int colorTag) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  switch (colorTag) {
    case 1:
      return isDark ? const Color(0xFF421D1D) : const Color(0xFFFFEBEE); // Soft Red
    case 2:
      return isDark ? const Color(0xFF422D1D) : const Color(0xFFFFF3E0); // Soft Orange
    case 3:
      return isDark ? const Color(0xFF423D1D) : const Color(0xFFFFFDE7); // Soft Yellow
    case 4:
      return isDark ? const Color(0xFF1D4222) : const Color(0xFFE8F5E9); // Soft Green
    case 5:
      return isDark ? const Color(0xFF1D2E42) : const Color(0xFFE3F2FD); // Soft Blue
    case 6:
      return isDark ? const Color(0xFF331D42) : const Color(0xFFF3E5F5); // Soft Purple
    default:
      return isDark ? Colors.black : Colors.white; // No Color (default)
  }
}
