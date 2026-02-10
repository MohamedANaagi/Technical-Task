import 'package:flutter/material.dart';

/// Centralized app color palette with a modern, vibrant feel.
abstract final class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────────────
  /// Primary brand color – a deep indigo-violet.
  static const Color primary = Color(0xFF6C5CE7);

  /// Secondary accent – a vibrant teal.
  static const Color secondary = Color(0xFF00CEC9);

  /// Tertiary accent – warm coral.
  static const Color tertiary = Color(0xFFFF7675);

  // ── Semantic Colors ───────────────────────────────────────────────────
  /// Rating / star accent (amber gold).
  static const Color rating = Color(0xFFFFC107);

  /// Favorite / like accent (warm rose).
  static const Color favorite = Color(0xFFE84393);

  /// Success green.
  static const Color success = Color(0xFF00B894);

  // ── Gradients ─────────────────────────────────────────────────────────
  /// Primary gradient for buttons, headers, splash.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient for highlights.
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00CEC9), Color(0xFF81ECEC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm gradient for login / onboarding backgrounds.
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFF74B9FF)],
  );

  // ── Surface helpers ───────────────────────────────────────────────────
  /// Soft overlay for cards on images.
  static Color overlayLight(BuildContext context) =>
      Theme.of(context).colorScheme.surface.withValues(alpha: 0.92);

  /// Placeholder / empty state surface.
  static Color placeholder(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Shimmer base color.
  static Color shimmerBase(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF2A2A2A);
  }

  /// Shimmer highlight color.
  static Color shimmerHighlight(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? const Color(0xFFF5F5F5)
        : const Color(0xFF3A3A3A);
  }
}
