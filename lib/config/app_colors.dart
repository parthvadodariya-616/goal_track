import 'package:flutter/material.dart';

class AppColors {
  // Circular Palette Options
  static const List<Color> palette = [
    Color(0xFF3F51B5), // Indigo (Default)
    Color(0xFFE91E63), // Pink
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF4CAF50), // Green
    Color(0xFF00BCD4), // Cyan
    Color(0xFF9C27B0), // Purple
  ];

  static const Color success = Color(0xFF69F0AE);
  static const Color deleteBackground = Colors.redAccent;
  
  // Gradients
  static const LinearGradient lightBanner = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBanner = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}