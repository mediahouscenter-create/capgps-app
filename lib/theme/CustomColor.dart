import 'package:flutter/material.dart';

const Color MAPS_IMAGES_COLOR = Color(0xFF0A4349);
const Color YELLOW_CUSTOM = Color(0xFFFFAC00);

class CustomColor {
  // Primary luxury palette
  static const Color primaryDark = Color(0xFF0F172A);      // Deep Slate Navy
  static const Color surfaceDark = Color(0xFF1E293B);      // Card background
  static const Color cardDark = Color(0xFF1E293B);         // Elevated surface
  static const Color glassBorderDark = Color(0x3338BDF8);   // Soft cyan border glow
  
  // Brand accents
  static const Color primaryAccent = Color(0xFF38BDF8);    // Electric Sky Cyan
  static const Color secondaryAccent = Color(0xFF6366F1);  // Deep Indigo
  static const Color accentPurple = Color(0xFFA855F7);     // Vivid Purple
  
  // Refined Status Colors
  static const Color statusDriving = Color(0xFF10B981);    // Emerald Green
  static const Color statusParking = Color(0xFFF59E0B);    // Warm Amber
  static const Color statusIdle = Color(0xFFF97316);       // Vivid Orange
  static const Color statusOffline = Color(0xFFEF4444);    // Rose Red
  static const Color statusExpired = Color(0xFF64748B);    // Muted Slate
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    colors: [Color(0x261E293B), Color(0x0D0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient drivingGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient parkingGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );

  static const LinearGradient offlineGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
  );

  // Backwards compatibility
  static var primaryColor = MaterialColor(0xFF38BDF8, color);
  static var secondaryColor = Colors.white;
  static var onColor = Colors.lightBlue;
  static var offColor = Colors.grey;
  static Color textPrimary = const Color(0xFFF8FAFC);
  static Color textSecondary = const Color(0xFF94A3B8);
  static Color backgroundColor = const Color(0xFF0F172A);
  static Color cardColor = const Color(0xFF1E293B);
  static Color dividerColor = const Color(0xFF334155);
  static Color errorColor = const Color(0xFFEF4444);
  static Color successColor = const Color(0xFF10B981);
  static Color warningColor = const Color(0xFFF59E0B);
  static Color infoColor = const Color(0xFF38BDF8);
  static Color mainBackColor = const Color(0xFF0F172A);
  static Color lightIndigo = const Color(0xFF1E293B);
}

Map<int, Color> color = {
  50: const Color.fromRGBO(56, 189, 248, .1),
  100: const Color.fromRGBO(56, 189, 248, .2),
  200: const Color.fromRGBO(56, 189, 248, .3),
  300: const Color.fromRGBO(56, 189, 248, .4),
  400: const Color.fromRGBO(56, 189, 248, .5),
  500: const Color.fromRGBO(56, 189, 248, .6),
  600: const Color.fromRGBO(56, 189, 248, .7),
  700: const Color.fromRGBO(56, 189, 248, .8),
  800: const Color.fromRGBO(56, 189, 248, .9),
  900: const Color.fromRGBO(56, 189, 248, 1)
};