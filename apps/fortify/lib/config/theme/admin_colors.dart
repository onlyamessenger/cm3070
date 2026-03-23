import 'package:flutter/material.dart';

/// Color constants for the admin interface.
/// Dark elevated theme matching the Fortify prototype aesthetic.
class AdminColors {
  AdminColors._();

  // ── Backgrounds ──
  static const Color background = Color(0xFF111113);
  static const Color surface = Color(0xFF1B1B1F);
  static const Color surfaceContainer = Color(0xFF26262C);
  static const Color surfaceContainerHigh = Color(0xFF2E2E36);

  // ── Primary ──
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryVariant = Color(0xFF0891B2);

  // ── Text ──
  static const Color onSurface = Color(0xFFE2E8F0);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFF6B35);

  // ── Effects (applied only on hover/selected/focused states) ──
  static const Color primaryGlow = Color(0x4D00D4FF); // 30% opacity
  static const Color primaryTint = Color(0x0A00D4FF); // 4% opacity
  static const Color primaryOverlay = Color(0x1A00D4FF); // 10% opacity
  static const Color surfaceBorder = Color(0x336B7280); // 20% opacity
  static const Color surfaceBorderSubtle = Color(0x146B7280); // 8% opacity

  // ── Sidebar gradient ──
  static const Color sidebarGradientStart = Color(0xFF111113);
  static const Color sidebarGradientEnd = Color(0xFF0A1628);
}
