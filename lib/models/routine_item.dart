/// ============================================================================
/// ENUM: Jenis Rutinitas (RoutineType)
/// ============================================================================
enum RoutineType {
  makan,
  obat;

  String get label {
    switch (this) {
      case RoutineType.makan:
        return 'Makan';
      case RoutineType.obat:
        return 'Minum Obat';
    }
  }
}

/// ============================================================================
/// MODEL: Item Rutinitas Ceklis 1-Tap (RoutineItem)
/// ============================================================================
/// Dirancang untuk mengatasi "Basic Self-Care Amnesia" pada pengguna yang
/// mengalami brain fog. Begitu tombol ceklis ditekan:
/// 1. Status langsung terkunci `isCompleted = true`.
/// 2. Jam persis saat diminum/dimakan otomatis dicatat (`completedTime`).
/// 3. Bisa menambahkan catatan menu atau foto bukti minum obat opsional.
class RoutineItem {
  final String id; // contoh: 'makan_pagi', 'obat_pagi', 'obat_malam'
  final String title; // contoh: 'Makan Pagi', 'Obat Pagi (50mg)'
  final RoutineType type;
  final bool isCompleted; // ✓ Sudah
  final bool isSkipped; // ✗ Terlewat / disilang
  final String? completedTime; // contoh: "08:20"
  final String note; // contoh: "Roti & susu hangat"
  final String? photoPath;

  const RoutineItem({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
    this.isSkipped = false,
    this.completedTime,
    this.note = '',
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'isCompleted': isCompleted ? 1 : 0,
      'isSkipped': isSkipped ? 1 : 0,
      'completedTime': completedTime,
      'note': note,
      'photoPath': photoPath,
    };
  }

  factory RoutineItem.fromMap(Map<String, dynamic> map) {
    return RoutineItem(
      id: map['id'] as String,
      title: map['title'] as String,
      type: RoutineType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RoutineType.makan,
      ),
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      isSkipped: (map['isSkipped'] as int? ?? 0) == 1,
      completedTime: map['completedTime'] as String?,
      note: map['note'] as String? ?? '',
      photoPath: map['photoPath'] as String?,
    );
  }

  /// [clearTime] = true menghapus jam tercatat (saat ceklis dibatalkan).
  RoutineItem copyWith({
    String? id,
    String? title,
    RoutineType? type,
    bool? isCompleted,
    bool? isSkipped,
    String? completedTime,
    bool clearTime = false,
    String? note,
    String? photoPath,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      completedTime: clearTime ? null : (completedTime ?? this.completedTime),
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
