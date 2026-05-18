import 'package:flutter/material.dart';

class LaundryHubColors {
  // ── Primary Sky & Slate Palette ───────────────────────────────────────────
  static const primary           = Color(0xFF0891B2); // #0891B2 – main cyan-blue
  static const primaryLight      = Color(0xFF67E8F9); // #67E8F9 – light cyan
  static const primaryDeep       = Color(0xFF0E7490); // #0E7490 – deep cyan
  static const primaryVivid      = Color(0xFF0891B2); // #0891B2 – vivid
  static const primaryVividLight = Color(0xFF67E8F9); // #67E8F9 – vivid light
  static const primaryPale       = Color(0xFFECFEFF); // #ECFEFF – pale cyan tint
  static const primarySoft       = Color(0xFFCFFAFE); // #CFFAFE – soft cyan
  static const primarySoftAccent = Color(0xFFBAF5FC); // derived soft accent
  static const primarySoftBorder = Color(0xFF67E8F9); // #67E8F9 – light cyan border

  // ── Surfaces & Backgrounds ────────────────────────────────────────────────
  static const pageBackground  = Color(0xFFF8FAFC); // #F8FAFC – cool white
  static const surfaceSoft     = Color(0xFFF8FAFC); // #F8FAFC
  static const surfaceMuted    = Color(0xFFE2E8F0); // slate-200
  static const surfaceNeutral  = Color(0xFFF1F5F9); // slate-100

  // ── Borders ───────────────────────────────────────────────────────────────
  static const borderSoft    = Color(0xFFE2E8F0); // slate-200
  static const borderNeutral = Color(0xFFCBD5E1); // slate-300

  // ── Text (anchored to slate #1E293B) ─────────────────────────────────────
  static const textPrimaryDeep = Color(0xFF1E293B); // #1E293B – slate-800
  static const textPrimary     = Color(0xFF1E293B); // #1E293B
  static const textSecondary   = Color(0xFF475569); // slate-600
  static const textTertiary    = Color(0xFF64748B); // slate-500
  static const textMuted       = Color(0xFF64748B); // slate-500
  static const textSubtle      = Color(0xFF94A3B8); // slate-400

  // ── Semantic: Success ─────────────────────────────────────────────────────
  static const success      = Color(0xFF16A34A);
  static const successLight = Color(0xFF22C55E);
  static const successDark  = Color(0xFF15803D);
  static const successSoft  = Color(0xFFDCFCE7);
  static const successPale  = Color(0xFFF0FDF4);

  // ── Semantic: Warning ─────────────────────────────────────────────────────
  static const warning             = Color(0xFFF59E0B);
  static const warningDark         = Color(0xFFB45309);
  static const warningSoft         = Color(0xFFFEF3C7);
  static const warningPale         = Color(0xFFFFFBEB);
  static const warningPaleStrong   = Color(0xFFFDE68A);
  static const warningOrange       = Color(0xFFF97316);
  static const warningOrangeBorder = Color(0xFFFED7AA);
  static const warningSoftAlt      = Color(0xFFFFF7ED);

  // ── Semantic: Error ───────────────────────────────────────────────────────
  static const error       = Color(0xFFDC2626);
  static const errorStrong = Color(0xFFB91C1C);
  static const errorSoft   = Color(0xFFFEE2E2);
  static const errorPale   = Color(0xFFFEF2F2);
  static const errorBorder = Color(0xFFFECACA);

  // ── Accents ───────────────────────────────────────────────────────────────
  static const infoIndigo     = Color(0xFF4F46E5);
  static const infoIndigoPale = Color(0xFFEEF2FF);
  static const accentSky      = Color(0xFF0891B2); // matches primary
}

class LaundryHubTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LaundryHubColors.primary,
        primary: LaundryHubColors.primary,
        secondary: LaundryHubColors.primaryDeep,
        error: LaundryHubColors.error,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: LaundryHubColors.pageBackground,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: LaundryHubColors.pageBackground,
        foregroundColor: LaundryHubColors.textPrimaryDeep,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LaundryHubColors.primary,   // #0891B2 – 4.8:1 on white ✓
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LaundryHubColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LaundryHubColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LaundryHubColors.primary,   // #0891B2 focus ring
            width: 1.5,
          ),
        ),
      ),
    );
  }
}