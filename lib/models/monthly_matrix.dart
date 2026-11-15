import 'package:flutter/material.dart';
import 'daily_jejak.dart';
import 'sleep_record.dart';

/// ============================================================================
/// MODEL: Baris Tabel Matriks Harian (MonthlyMatrixRow)
/// ============================================================================
/// Mewakili 1 baris tanggal (misal tanggal 01 s/d 31) pada Tabel Matriks Bulanan.
/// Di layar HP, kolom Tanggal dibekukan (frozen) sedangkan kolom lainnya
/// dapat digeser secara horizontal.
class MonthlyMatrixRow {
  final int dayNumber; // 1 s/d 31
  final String dateString; // 'YYYY-MM-DD'
  final int moodLevel; // 1 s/d 5
  final double sleepDuration; // contoh: 6.5
  final SleepQuality sleepQuality;
  final String sleepReason;
  final String mealSummary; // contoh: "✅/❌/✅"
  final String medSummary; // contoh: "✅/✅"
  final String notePreview;
  final bool hasPin;
  final bool hasPhoto;

  const MonthlyMatrixRow({
    required this.dayNumber,
    required this.dateString,
    required this.moodLevel,
    required this.sleepDuration,
    required this.sleepQuality,
    required this.sleepReason,
    required this.mealSummary,
    required this.medSummary,
    this.notePreview = '',
    this.hasPin = false,
    this.hasPhoto = false,
  });

  factory MonthlyMatrixRow.fromDailyJejak(DailyJejak jejak) {
    DateTime parsed = DateTime.tryParse(jejak.date) ?? DateTime.now();
    return MonthlyMatrixRow(
      dayNumber: parsed.day,
      dateString: jejak.date,
      moodLevel: jejak.moodLevel,
      sleepDuration: jejak.sleep.durasiJam,
      sleepQuality: jejak.sleep.kualitas,
      sleepReason: jejak.sleep.alasan,
      mealSummary: jejak.ringkasanMakanTeks,
      medSummary: jejak.ringkasanObatTeks,
      notePreview: jejak.feelingsNote,
      hasPin: jejak.hasImportantPin,
    );
  }

  /// Warna badge mood sesuai palet Lumi
  Color get moodColor {
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
  }
}

/// ============================================================================
/// MODEL: Rekap Perkembangan Bulanan (MonthlySummary)
/// ============================================================================
/// Mengagregasi seluruh hari dalam satu bulan menjadi ringkasan statistik
/// objektif agar pengguna depresi bisa melihat bukti kemajuan mereka.
class MonthlySummary {
  final int year;
  final int month;
  final int totalDaysRecorded;
  final double averageMood; // skala 1.0 - 5.0
  final double averageSleepDuration; // jam per hari
  final double medAdherencePercentage; // contoh: 92.0%
  final double mealRegularityPercentage; // contoh: 80.0%
  final Map<SleepQuality, int> sleepQualityBreakdown;
  final Map<int, int> moodDistribution; // level 1..5 -> jumlah hari
  final String recoveryInsight; // Analisis otomatis ramah pengguna

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalDaysRecorded,
    required this.averageMood,
    required this.averageSleepDuration,
    required this.medAdherencePercentage,
    required this.mealRegularityPercentage,
    required this.sleepQualityBreakdown,
    required this.moodDistribution,
    required this.recoveryInsight,
  });

  /// Hitung agregasi otomatis dari daftar jejak harian sebulan
  factory MonthlySummary.calculate(int year, int month, List<DailyJejak> logs) {
    if (logs.isEmpty) {
      return MonthlySummary(
        year: year,
        month: month,
        totalDaysRecorded: 0,
        averageMood: 3.0,
        averageSleepDuration: 0.0,
        medAdherencePercentage: 0.0,
        mealRegularityPercentage: 0.0,
        sleepQualityBreakdown: {for (var q in SleepQuality.values) q: 0},
        moodDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        recoveryInsight: 'Mulai catat jejak pertamamu untuk melihat wawasan pola pemulihan.',
      );
    }

    double totalMood = 0;
    double totalSleep = 0;
    double totalMedRatio = 0;
    double totalMealRatio = 0;

    Map<SleepQuality, int> sleepMap = {for (var q in SleepQuality.values) q: 0};
    Map<int, int> moodMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var log in logs) {
      totalMood += log.moodLevel;
      totalSleep += log.sleep.durasiJam;
      totalMedRatio += log.rasioKepatuhanObat;
      totalMealRatio += log.rasioKeteraturanMakan;

      sleepMap[log.sleep.kualitas] = (sleepMap[log.sleep.kualitas] ?? 0) + 1;
      moodMap[log.moodLevel] = (moodMap[log.moodLevel] ?? 0) + 1;
    }

    int n = logs.length;
    double avgMood = totalMood / n;
    double avgSleep = totalSleep / n;
    double medPct = (totalMedRatio / n) * 100.0;
    double mealPct = (totalMealRatio / n) * 100.0;

    // Menghasilkan wawasan pemulihan otomatis
    String insight;
    if (medPct >= 85 && avgSleep >= 6.5) {
      insight = '✨ Tidur yang cukup dan kepatuhan minum obat di atas 85% terbukti menjaga kestabilan suasana hatimu bulan ini.';
    } else if (avgSleep < 5.5) {
      insight = '💡 Suasana hati cenderung lebih berat saat durasi tidur di bawah 5.5 jam. Luangkan waktu rileks sebelum tidur ya.';
    } else {
      insight = '🌱 Kamu sudah berusaha sebaik mungkin mencatat $n hari bulan ini. Setiap jejak kecil adalah kemajuan nyata!';
    }

    return MonthlySummary(
      year: year,
      month: month,
      totalDaysRecorded: n,
      averageMood: avgMood,
      averageSleepDuration: avgSleep,
      medAdherencePercentage: medPct,
      mealRegularityPercentage: mealPct,
      sleepQualityBreakdown: sleepMap,
      moodDistribution: moodMap,
      recoveryInsight: insight,
    );
  }
}
