import 'package:flutter/material.dart';

/// Central design system — all colours, text styles, and component themes.
/// Use [AppTheme.dark()] in MaterialApp.theme.
class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _background = Color(0xFF13131F);
  static const Color _surface = Color(0xFF1E1E2E);
  static const Color _surfaceCard = Color(0xFF252538);
  static const Color _surfaceCardHover = Color(0xFF2E2E45);
  static const Color _primary = Color(0xFF7C6FCD);
  static const Color _primaryDark = Color(0xFF6558B8);
  static const Color _onPrimary = Colors.white;
  static const Color _onSurface = Color(0xFFE2E2F2);
  static const Color _muted = Color(0xFF8B8B9E);
  static const Color _border = Color(0xFF2E2E45);
  static const Color _error = Color(0xFFCF6679);
  static const Color _success = Color(0xFF52C28A);

  // ── Public colour tokens (use in screens instead of raw Color literals) ──
  static const Color primaryColor = _primary;
  static const Color cardColor = _surfaceCard;
  static const Color cardHoverColor = _surfaceCardHover;
  static const Color mutedColor = _muted;
  static const Color errorColor = _error;
  static const Color successColor = _success;
  static const Color borderColor = _border;
  static const Color onSurfaceColor = _onSurface;

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _primaryDark,
        surface: _surface,
        error: _error,
        onPrimary: _onPrimary,
        onSurface: _onSurface,
      ),
      scaffoldBackgroundColor: _background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF16162A),
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: _onSurface),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: _surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: _border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: _muted),
        hintStyle: const TextStyle(color: _muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
        errorStyle: const TextStyle(color: _error),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          disabledBackgroundColor: _surfaceCardHover,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: _border, thickness: 0.5),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceCard,
        contentTextStyle: const TextStyle(color: _onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _border),
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(color: _muted),

      // Text
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: _onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          color: _onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(color: _onSurface, fontSize: 16),
        bodyMedium: TextStyle(color: _muted, fontSize: 14),
        labelLarge: TextStyle(
          color: _onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
