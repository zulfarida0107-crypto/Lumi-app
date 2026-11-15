import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// SISTEM WARNA & TEMA RESMI: LUMI
/// ============================================================================
/// Mengacu langsung pada blueprint resmi aplikasi Lumi:
/// Memadukan warna membumi (grounding) dengan pastel lembut yang ramah mata.
class LumiColors {
  // 5 Warna Utama Resmi Lumi:
  static const Color mutedNavy = Color(0xFF355070); // Primary / Header / Level 1 Sangat Berat
  static const Color dustyIndigo = Color(0xFF4A4E69); // Secondary / Kartu Tidur / Level 2 Lelah
  static const Color lightMauve = Color(0xFFD8A4B1); // Aksen Catatan / Level 3 Biasa
  static const Color softPink = Color(0xFFFFC0CB); // Aksen Hangat Lumi / Tombol Catat / Level 4 Tenang
  static const Color vividMint = Color(0xFFB5EAD7); // Indikator Selesai / Obat / Level 5 Baik

  // Warna Netral & Latar Belakang:
  static const Color backgroundLight = Color(0xFFFAF6F8); // Latar lembut putih kemerahan
  static const Color surfaceLight = Color(0xFFFFFFFF); // Kartu putih bersih
  static const Color surfaceContainerLow = Color(0xFFF6F2F4);
  static const Color surfaceContainer = Color(0xFFF1EDEF);
  static const Color outlineLight = Color(0xFFC3C6CE);
  static const Color textPrimary = Color(0xFF1C1B1D);
  static const Color textSecondary = Color(0xFF595D78);

  // Mode Malam / Teduh (Deep Grounding Mode):
  static const Color backgroundDark = Color(0xFF1D2F42);
  static const Color surfaceDark = Color(0xFF2B3E54);
}

class LumiTheme {
  /// Tema Mode Terang (Soft Pastel Mode)
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LumiColors.backgroundLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: LumiColors.mutedNavy,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD2E4FF),
        onPrimaryContainer: LumiColors.mutedNavy,
        secondary: LumiColors.dustyIndigo,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFDBDEFF),
        onSecondaryContainer: LumiColors.dustyIndigo,
        tertiary: LumiColors.lightMauve,
        onTertiary: Colors.white,
        surface: LumiColors.surfaceLight,
        onSurface: LumiColors.textPrimary,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        outline: LumiColors.outlineLight,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: LumiColors.mutedNavy,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: LumiColors.mutedNavy,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: LumiColors.textPrimary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: LumiColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: LumiColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: LumiColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LumiColors.backgroundLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: LumiColors.mutedNavy),
      ),
      cardTheme: CardThemeData(
        color: LumiColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x1F355070)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LumiColors.surfaceLight,
        indicatorColor: LumiColors.vividMint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: LumiColors.mutedNavy,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: LumiColors.dustyIndigo,
          );
        }),
      ),
    );
  }
}
