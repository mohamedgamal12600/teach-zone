// app_colors.dart
// Colors taken from the "Free electronics e-commerce app" XD file.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surfaces
  static const background = Color(0xFF333742); // screen background
  static const surface = Color(0xFF454D5A); // cards, search field, chips
  static const surfaceDark = Color(0xFF191B20); // selected nav pill, dark buttons

  // Accent
  static const accent = Color(0xFFFDD14B); // yellow highlight (CTA buttons)
  static const pink = Color(0xFFEF5E9F); // secondary highlight
  static const danger = Color(0xFFED5454); // red swatch / errors

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0B0BC);
  static const textMuted = Color(0xFF787C85);

  // Lines
  static const outline = Color(0x33FFFFFF); // white @ 20%
}

class AppRadius {
  AppRadius._();

  static const double field = 14;
  static const double card = 24;
  static const double pill = 255;
}
