/// ============================================================================
/// MODEL: Catatan Perasaan & Dokumentasi Memori (NoteMemory)
/// ============================================================================
/// Menyimpan uneg-uneg, catatan perasaan, foto dokumentasi, dan rekaman suara.
/// Dilengkapi penanda `isPinnedForTherapy` (Pin Terapi) yang secara otomatis
/// dirangkum ke "Mode Siap Konsultasi" untuk dibawa ke psikolog/psikiater.
class NoteMemory {
  final String id;
  final String date; // format: YYYY-MM-DD
  final String time; // format: HH:mm
  final int moodLevel; // 1 (Sangat Berat) s/d 5 (Baik/Cerah)
  final String content;
  final String? photoPath;
  final String? audioPath;
  final List<String> tags; // contoh: ['Overthinking', 'Efek Obat', 'Pekerjaan']
  final bool isPinnedForTherapy; // Pin untuk konsultasi dokter/psikolog

  const NoteMemory({
    required this.id,
    required this.date,
    required this.time,
    required this.moodLevel,
    required this.content,
    this.photoPath,
    this.audioPath,
    this.tags = const [],
    this.isPinnedForTherapy = false,
  });

  static String moodLabel(int level) {
    switch (level) {
      case 1:
        return 'Sangat Berat';
      case 2:
        return 'Lelah';
      case 3:
        return 'Biasa';
      case 4:
        return 'Cukup Tenang';
      case 5:
        return 'Baik';
      default:
        return 'Baik sekali';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'moodLevel': moodLevel,
      'content': content,
      'photoPath': photoPath,
      'audioPath': audioPath,
      'tags': tags.join(','),
      'isPinnedForTherapy': isPinnedForTherapy ? 1 : 0,
    };
  }

  factory NoteMemory.fromMap(Map<String, dynamic> map) {
    return NoteMemory(
      id: map['id'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      moodLevel: map['moodLevel'] as int? ?? 3,
      content: map['content'] as String? ?? '',
      photoPath: map['photoPath'] as String?,
      audioPath: map['audioPath'] as String?,
      tags:
          (map['tags'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      isPinnedForTherapy: (map['isPinnedForTherapy'] as int? ?? 0) == 1,
    );
  }

  NoteMemory copyWith({
    String? id,
    String? date,
    String? time,
    int? moodLevel,
    String? content,
    String? photoPath,
    String? audioPath,
    List<String>? tags,
    bool? isPinnedForTherapy,
  }) {
    return NoteMemory(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      moodLevel: moodLevel ?? this.moodLevel,
      content: content ?? this.content,
      photoPath: photoPath ?? this.photoPath,
      audioPath: audioPath ?? this.audioPath,
      tags: tags ?? this.tags,
      isPinnedForTherapy: isPinnedForTherapy ?? this.isPinnedForTherapy,
    );
  }
}
