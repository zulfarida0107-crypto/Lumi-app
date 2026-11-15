import 'package:flutter/material.dart';

/// ============================================================================
/// ENUM: Kualitas Tidur (Sleep Quality)
/// ============================================================================
/// Menilai kualitas istirahat pengguna secara psikologis dan medis.
/// Pada penyintas depresi, jam tidur saja tidak cukup; kualitas tidur dan
/// penyebab di baliknya sangat krusial untuk pemantauan dosis obat & stres.
enum SleepQuality {
  nyenyak,
  seringTerbangun,
  biasa,
  insomnia,
  hypersomnia;

  /// Level 1 sampai 5 (Level 5 tertinggi / nyenyak, Level 1 tidur berlebihan)
  int get level {
    switch (this) {
      case SleepQuality.nyenyak:
        return 5;
      case SleepQuality.seringTerbangun:
        return 4;
      case SleepQuality.biasa:
        return 3;
      case SleepQuality.insomnia:
        return 2;
      case SleepQuality.hypersomnia:
        return 1;
    }
  }

  /// Label Bahasa Indonesia yang ramah & bebas penghakiman
  String get label {
    switch (this) {
      case SleepQuality.nyenyak:
        return 'Nyenyak / Segar';
      case SleepQuality.seringTerbangun:
        return 'Sering Terbangun';
      case SleepQuality.biasa:
        return 'Biasa / Cukup';
      case SleepQuality.insomnia:
        return 'Susah Tidur (Insomnia)';
      case SleepQuality.hypersomnia:
        return 'Tidur Berlebihan (>10 jam)';
    }
  }

  /// Warna representasi sesuai Palet Resmi Lumi (Level 5 ke Level 1)
  Color get color {
    switch (this) {
      case SleepQuality.nyenyak:
        return const Color(0xFFB5EAD7); // Vivid Mint Green (Level 5)
      case SleepQuality.seringTerbangun:
        return const Color(0xFFFFC0CB); // Soft Pink (Level 4)
      case SleepQuality.biasa:
        return const Color(0xFFD8A4B1); // Light Mauve Pink (Level 3)
      case SleepQuality.insomnia:
        return const Color(0xFF4A4E69); // Dusty Indigo (Level 2)
      case SleepQuality.hypersomnia:
        return const Color(0xFF355070); // Muted Navy Blue (Level 1)
    }
  }

  /// Ikon Material Symbols
  IconData get icon {
    switch (this) {
      case SleepQuality.nyenyak:
        return Icons.sentiment_very_satisfied_rounded;
      case SleepQuality.seringTerbangun:
        return Icons.alarm_on_rounded;
      case SleepQuality.biasa:
        return Icons.sentiment_neutral_rounded;
      case SleepQuality.insomnia:
        return Icons.nightlight_round;
      case SleepQuality.hypersomnia:
        return Icons.bedtime_off_rounded;
    }
  }

  /// Konversi string dari database SQLite
  static SleepQuality fromString(String? val) {
    if (val == null) return SleepQuality.seringTerbangun;
    if (val.toLowerCase() == 'mimpiburuk') return SleepQuality.hypersomnia;
    return SleepQuality.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SleepQuality.seringTerbangun,
    );
  }
}

/// ============================================================================
/// MODEL: Rekam Jejak Tidur (SleepRecord)
/// ============================================================================
/// Menyimpan detail jam mulai tidur, jam bangun, durasi total, kualitas,
/// dan alasan/catatan mengapa tidurnya demikian.
class SleepRecord {
  final String jamMulai; // contoh: "00:30"
  final String jamBangun; // contoh: "07:00"
  final double durasiJam; // contoh: 6.5
  final SleepQuality kualitas;
  final String alasan; // contoh: "Kebangun jam 3 pagi cemas & haus"
  final bool isRecorded;
  final bool isSkipped; // disilang (tidak dicatat hari ini)
  final String catatanJam; // jam catatan personal, contoh: "14:30"

  const SleepRecord({
    this.jamMulai = '00:00',
    this.jamBangun = '07:00',
    this.durasiJam = 7.0,
    this.kualitas = SleepQuality.nyenyak,
    this.alasan = '',
    this.isRecorded = false,
    this.isSkipped = false,
    this.catatanJam = '',
  });

  /// Hitung durasi jam otomatis berdasarkan waktu mulai dan bangun
  static double hitungDurasi(TimeOfDay mulai, TimeOfDay bangun) {
    double jamMulaiDec = mulai.hour + (mulai.minute / 60.0);
    double jamBangunDec = bangun.hour + (bangun.minute / 60.0);

    if (jamBangunDec < jamMulaiDec) {
      // Melewati tengah malam (misal 23:00 s/d 07:00)
      return (24.0 - jamMulaiDec) + jamBangunDec;
    } else {
      return jamBangunDec - jamMulaiDec;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'jamMulai': jamMulai,
      'jamBangun': jamBangun,
      'durasiJam': durasiJam,
      'kualitas': kualitas.name,
      'alasan': alasan,
      'isRecorded': isRecorded ? 1 : 0,
      'isSkipped': isSkipped ? 1 : 0,
      'catatanJam': catatanJam,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      jamMulai: map['jamMulai'] as String? ?? '00:00',
      jamBangun: map['jamBangun'] as String? ?? '07:00',
      durasiJam: (map['durasiJam'] as num?)?.toDouble() ?? 7.0,
      kualitas: SleepQuality.fromString(map['kualitas'] as String?),
      alasan: map['alasan'] as String? ?? '',
      isRecorded: (map['isRecorded'] as int? ?? 0) == 1,
      isSkipped: (map['isSkipped'] as int? ?? 0) == 1,
      catatanJam: map['catatanJam'] as String? ?? '',
    );
  }

  SleepRecord copyWith({
    String? jamMulai,
    String? jamBangun,
    double? durasiJam,
    SleepQuality? kualitas,
    String? alasan,
    bool? isRecorded,
    bool? isSkipped,
    String? catatanJam,
  }) {
    return SleepRecord(
      jamMulai: jamMulai ?? this.jamMulai,
      jamBangun: jamBangun ?? this.jamBangun,
      durasiJam: durasiJam ?? this.durasiJam,
      kualitas: kualitas ?? this.kualitas,
      alasan: alasan ?? this.alasan,
      isRecorded: isRecorded ?? this.isRecorded,
      isSkipped: isSkipped ?? this.isSkipped,
      catatanJam: catatanJam ?? this.catatanJam,
    );
  }
}
