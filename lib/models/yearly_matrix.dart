import 'package:flutter/material.dart';
import 'sleep_record.dart';
import 'monthly_matrix.dart';

/// ============================================================================
/// ENUM: Mode Tampilan Warna Pixel Grid (PixelGridColorMode)
/// ============================================================================
enum PixelGridColorMode {
  mood,
  sleepQuality;

  String get label {
    switch (this) {
      case PixelGridColorMode.mood:
        return 'Warna Mood (1-5)';
      case PixelGridColorMode.sleepQuality:
        return 'Kualitas Tidur';
    }
  }
}

/// ============================================================================
/// MODEL: Satu Titik Kotak Pixel (YearPixelCell)
/// ============================================================================
/// Mewakili 1 hari di grid 365 hari ("Year in Pixels").
/// Berwarna sesuai skala emosi atau kualitas tidur tanpa penghakiman.
class YearPixelCell {
  final int month; // 1 s/d 12
  final int day; // 1 s/d 31
  final String dateString; // 'YYYY-MM-DD'
  final int? moodLevel; // 1 s/d 5 (null jika belum diisi)
  final SleepQuality? sleepQuality;
  final bool hasData;

  const YearPixelCell({
    required this.month,
    required this.day,
    required this.dateString,
    this.moodLevel,
    this.sleepQuality,
    this.hasData = false,
  });

  /// Mengambil warna sel berdasarkan mode visualisasi yang dipilih
  Color getColor(PixelGridColorMode mode) {
    if (!hasData) {
      return const Color(0xFFE5E1E3).withValues(alpha: 0.35); // Abu-abu pudar belum tercatat
    }

    if (mode == PixelGridColorMode.mood) {
      switch (moodLevel) {
        case 1:
          return const Color(0xFF355070); // Sangat Berat (Muted Navy)
        case 2:
          return const Color(0xFF4A4E69); // Lelah (Dusty Indigo)
        case 3:
          return const Color(0xFFD8A4B1); // Biasa (Light Mauve Pink)
        case 4:
          return const Color(0xFFFFC0CB); // Cukup Tenang (Soft Pink)
        case 5:
          return const Color(0xFFB5EAD7); // Baik / Cerah (Vivid Mint)
        default:
          return const Color(0xFFD8A4B1);
      }
    } else {
      // Mode Kualitas Tidur
      return sleepQuality?.color ?? const Color(0xFFB5EAD7);
    }
  }
}

/// ============================================================================
/// MODEL: Rekap Perbandingan 12 Bulan (YearlyMonthMilestone)
/// ============================================================================
/// Baris perbandingan antar-bulan untuk tabel matriks tahunan.
class YearlyMonthMilestone {
  final int month;
  final String monthName; // "Januari", "Februari", dst.
  final double avgMood;
  final int stableDays; // Hari dengan Mood >= 3
  final int heavyDays; // Hari dengan Mood <= 2
  final double avgSleepDuration;
  final String dominantSleepQuality;
  final double medAdherencePct;
  final double mealRegularityPct;
  final String milestoneNotes;

  const YearlyMonthMilestone({
    required this.month,
    required this.monthName,
    required this.avgMood,
    required this.stableDays,
    required this.heavyDays,
    required this.avgSleepDuration,
    required this.dominantSleepQuality,
    required this.medAdherencePct,
    required this.mealRegularityPct,
    this.milestoneNotes = '',
  });

  factory YearlyMonthMilestone.fromMonthlySummary(MonthlySummary summary, String monthName, String milestone) {
    int stable = (summary.moodDistribution[3] ?? 0) +
        (summary.moodDistribution[4] ?? 0) +
        (summary.moodDistribution[5] ?? 0);
    int heavy = (summary.moodDistribution[1] ?? 0) + (summary.moodDistribution[2] ?? 0);

    // Cari kualitas tidur terbanyak
    String dominant = 'Nyenyak';
    int maxCount = -1;
    summary.sleepQualityBreakdown.forEach((quality, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = quality.label;
      }
    });

    return YearlyMonthMilestone(
      month: summary.month,
      monthName: monthName,
      avgMood: summary.averageMood,
      stableDays: stable,
      heavyDays: heavy,
      avgSleepDuration: summary.averageSleepDuration,
      dominantSleepQuality: dominant,
      medAdherencePct: summary.medAdherencePercentage,
      mealRegularityPct: summary.mealRegularityPercentage,
      milestoneNotes: milestone,
    );
  }
}
