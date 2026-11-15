import 'sleep_record.dart';
import 'routine_item.dart';

/// ============================================================================
/// MODEL: Jejak Harian Lengkap (DailyJejak)
/// ============================================================================
/// Mengintegrasikan 4 pilar utama harian:
/// 1. Tidur (Durasi, Kualitas, & Alasan)
/// 2. Ceklis Makan 1-Tap (Pagi, Siang, Malam)
/// 3. Ceklis Minum Obat 1-Tap (Pagi, Siang, Malam)
/// 4. Catatan Perasaan & Mood Skala 1-5
class DailyJejak {
  final String date; // format: 'YYYY-MM-DD'
  final SleepRecord sleep;
  final List<RoutineItem> meals;
  final List<RoutineItem> medications;
  final int moodLevel; // 1 s/d 5
  final String energyLevel; // 'rendah', 'cukup', 'penuh'
  final String feelingsNote;
  final bool isLowEnergySaved; // Ditekan dari tombol "Lagi Sangat Lelah"
  final bool hasImportantPin;

  const DailyJejak({
    required this.date,
    this.sleep = const SleepRecord(),
    this.meals = const [],
    this.medications = const [],
    this.moodLevel = 3,
    this.energyLevel = 'rendah',
    this.feelingsNote = '',
    this.isLowEnergySaved = false,
    this.hasImportantPin = false,
  });

  /// Inisialisasi slot standar untuk hari baru
  factory DailyJejak.initialForDate(String date) {
    return DailyJejak(
      date: date,
      sleep: const SleepRecord(
        jamMulai: '00:00',
        jamBangun: '07:00',
        durasiJam: 7.0,
        kualitas: SleepQuality.nyenyak,
        alasan: '',
        isRecorded: false,
      ),
      meals: const [
        RoutineItem(id: 'makan_pagi', title: 'Makan Pagi', type: RoutineType.makan),
        RoutineItem(id: 'makan_siang', title: 'Makan Siang', type: RoutineType.makan),
        RoutineItem(id: 'makan_malam', title: 'Makan Malam', type: RoutineType.makan),
      ],
      medications: const [
        RoutineItem(id: 'obat_pagi', title: 'Obat Pagi', type: RoutineType.obat),
        RoutineItem(id: 'obat_siang', title: 'Obat Siang', type: RoutineType.obat),
        RoutineItem(id: 'obat_malam', title: 'Obat Malam', type: RoutineType.obat),
      ],
      moodLevel: 3,
      feelingsNote: '',
      isLowEnergySaved: false,
      hasImportantPin: false,
    );
  }

  /// Rasio kepatuhan obat (contoh: 2/2 = 1.0)
  double get rasioKepatuhanObat {
    if (medications.isEmpty) return 1.0;
    int selesai = medications.where((m) => m.isCompleted).length;
    return selesai / medications.length;
  }

  /// Rasio keteraturan makan (contoh: 3/3 = 1.0)
  double get rasioKeteraturanMakan {
    if (meals.isEmpty) return 1.0;
    int selesai = meals.where((m) => m.isCompleted).length;
    return selesai / meals.length;
  }

  /// Format teks ringkas untuk kolom spreadsheet/tabel matriks
  /// ✅ = sudah, ❌ = disilang/terlewat, ⬜ = tidak diceklis (default)
  static String _statusIcon(RoutineItem m) {
    if (m.isCompleted) return '✅';
    if (m.isSkipped) return '❌';
    return '⬜';
  }

  String get ringkasanMakanTeks {
    return meals.map(_statusIcon).join('/');
  }

  String get ringkasanObatTeks {
    return medications.map(_statusIcon).join('/');
  }

  /// Sudah ada isi mood/perasaan yang dicatat hari ini?
  bool get isMoodRecorded => feelingsNote.isNotEmpty || isLowEnergySaved;

  /// Encode status rutinitas ke teks: "id@jam" (sudah), "!id" (disilang)
  static String _encodeRoutine(List<RoutineItem> items) {
    final parts = <String>[];
    for (final m in items) {
      if (m.isCompleted) {
        parts.add('${m.id}@${m.completedTime ?? ''}');
      } else if (m.isSkipped) {
        parts.add('!${m.id}');
      }
    }
    return parts.join(',');
  }

  static List<RoutineItem> _decodeRoutine(List<RoutineItem> defaults, String raw) {
    final done = <String, String>{};
    final skipped = <String>{};
    for (final token in raw.split(',')) {
      if (token.isEmpty) continue;
      if (token.startsWith('!')) {
        skipped.add(token.substring(1));
      } else {
        final idx = token.indexOf('@');
        if (idx == -1) {
          done[token] = '';
        } else {
          done[token.substring(0, idx)] = token.substring(idx + 1);
        }
      }
    }
    return defaults.map((m) {
      if (done.containsKey(m.id)) {
        final t = done[m.id]!;
        return m.copyWith(isCompleted: true, completedTime: t.isEmpty ? null : t);
      }
      if (skipped.contains(m.id)) {
        return m.copyWith(isSkipped: true);
      }
      return m;
    }).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'sleep_jamMulai': sleep.jamMulai,
      'sleep_jamBangun': sleep.jamBangun,
      'sleep_durasiJam': sleep.durasiJam,
      'sleep_kualitas': sleep.kualitas.name,
      'sleep_alasan': sleep.alasan,
      'sleep_isRecorded': sleep.isRecorded ? 1 : 0,
      'sleep_isSkipped': sleep.isSkipped ? 1 : 0,
      'sleep_catatanJam': sleep.catatanJam,
      'moodLevel': moodLevel,
      'feelingsNote': feelingsNote,
      'isLowEnergySaved': energyLevel == 'penuh' ? 3 : (energyLevel == 'cukup' ? 2 : 1),
      'hasImportantPin': hasImportantPin ? 1 : 0,
      'meals_completed': _encodeRoutine(meals),
      'meds_completed': _encodeRoutine(medications),
    };
  }

  factory DailyJejak.fromMap(Map<String, dynamic> map, {List<RoutineItem>? defaultMeals, List<RoutineItem>? defaultMeds}) {
    final rawEnergy = map['isLowEnergySaved'] as int? ?? 1;
    final parsedEnergy = rawEnergy == 3 ? 'penuh' : (rawEnergy == 2 ? 'cukup' : 'rendah');

    final resolvedMeals = _decodeRoutine(
      defaultMeals ?? [
        const RoutineItem(id: 'makan_pagi', title: 'Makan Pagi', type: RoutineType.makan),
        const RoutineItem(id: 'makan_siang', title: 'Makan Siang', type: RoutineType.makan),
        const RoutineItem(id: 'makan_malam', title: 'Makan Malam', type: RoutineType.makan),
      ],
      map['meals_completed'] as String? ?? '',
    );

    final resolvedMeds = _decodeRoutine(
      defaultMeds ?? [
        const RoutineItem(id: 'obat_pagi', title: 'Obat Pagi', type: RoutineType.obat),
        const RoutineItem(id: 'obat_siang', title: 'Obat Siang', type: RoutineType.obat),
        const RoutineItem(id: 'obat_malam', title: 'Obat Malam', type: RoutineType.obat),
      ],
      map['meds_completed'] as String? ?? '',
    );

    return DailyJejak(
      date: map['date'] as String,
      sleep: SleepRecord(
        jamMulai: map['sleep_jamMulai'] as String? ?? '00:00',
        jamBangun: map['sleep_jamBangun'] as String? ?? '07:00',
        durasiJam: (map['sleep_durasiJam'] as num?)?.toDouble() ?? 7.0,
        kualitas: SleepQuality.fromString(map['sleep_kualitas'] as String?),
        alasan: map['sleep_alasan'] as String? ?? '',
        isRecorded: (map['sleep_isRecorded'] as int? ?? 0) == 1,
        isSkipped: (map['sleep_isSkipped'] as int? ?? 0) == 1,
        catatanJam: map['sleep_catatanJam'] as String? ?? '',
      ),
      meals: resolvedMeals,
      medications: resolvedMeds,
      moodLevel: map['moodLevel'] as int? ?? 3,
      energyLevel: parsedEnergy,
      feelingsNote: map['feelingsNote'] as String? ?? '',
      isLowEnergySaved: parsedEnergy == 'rendah',
      hasImportantPin: (map['hasImportantPin'] as int? ?? 0) == 1,
    );
  }

  DailyJejak copyWith({
    String? date,
    SleepRecord? sleep,
    List<RoutineItem>? meals,
    List<RoutineItem>? medications,
    int? moodLevel,
    String? energyLevel,
    String? feelingsNote,
    bool? isLowEnergySaved,
    bool? hasImportantPin,
  }) {
    final nextEnergy = energyLevel ?? this.energyLevel;
    return DailyJejak(
      date: date ?? this.date,
      sleep: sleep ?? this.sleep,
      meals: meals ?? this.meals,
      medications: medications ?? this.medications,
      moodLevel: moodLevel ?? this.moodLevel,
      energyLevel: nextEnergy,
      feelingsNote: feelingsNote ?? this.feelingsNote,
      isLowEnergySaved: isLowEnergySaved ?? (nextEnergy == 'rendah'),
      hasImportantPin: hasImportantPin ?? this.hasImportantPin,
    );
  }
}
