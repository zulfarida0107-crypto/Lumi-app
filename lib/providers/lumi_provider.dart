import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../core/database/lumi_database.dart';

/// ============================================================================
/// STATE MANAGEMENT PROVIDER: LUMI PROVIDER
/// ============================================================================
/// Pusat kendali yang menghubungkan seluruh layar (Timeline Harian, Catatan,
/// Matriks Bulanan & Tahunan, serta Spreadsheet).
class LumiProvider extends ChangeNotifier {
  final LumiDatabase _db = LumiDatabase.instance;

  /// Waktu real-time WIB (UTC+7), terlepas dari zona waktu perangkat.
  static DateTime wibNow() => DateTime.now().toUtc().add(const Duration(hours: 7));

  /// Tanggal hari ini (WIB) tanpa jam.
  static DateTime wibToday() {
    final n = wibNow();
    return DateTime(n.year, n.month, n.day);
  }

  static String formatWibTime() => DateFormat('HH:mm').format(wibNow());

  DateTime _today = wibToday();
  late DateTime _selectedDate = _today;
  late DailyJejak _currentJejak = DailyJejak.initialForDate(
    DateFormat('yyyy-MM-dd').format(_today),
  );
  Timer? _clock;

  final Map<String, DailyJejak> _memoryLogs = {};
  List<DailyJejak> _monthlyLogs = [];
  List<DailyJejak> _yearlyLogs = [];
  List<NoteMemory> _notes = [];
  bool _isLoading = true;

  static bool _hasAnyUserRecord(DailyJejak j) {
    return j.sleep.isRecorded ||
        j.sleep.isSkipped ||
        j.isMoodRecorded ||
        j.hasImportantPin ||
        j.meals.any((m) => m.isCompleted || m.isSkipped) ||
        j.medications.any((m) => m.isCompleted || m.isSkipped);
  }

  static DailyJejak _normalizeForMatrix(DailyJejak j) {
    if (!j.sleep.isRecorded) {
      return j.copyWith(sleep: j.sleep.copyWith(durasiJam: 0.0));
    }
    return j;
  }

  void _syncMemoryCollections(int year, int month) {
    final monthPrefix = '$year-${month.toString().padLeft(2, '0')}-';
    final yearPrefix = '$year-';

    _monthlyLogs = _memoryLogs.values
        .where((j) => j.date.startsWith(monthPrefix) && _hasAnyUserRecord(j))
        .map(_normalizeForMatrix)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _yearlyLogs = _memoryLogs.values
        .where((j) => j.date.startsWith(yearPrefix) && _hasAnyUserRecord(j))
        .map(_normalizeForMatrix)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  PixelGridColorMode _pixelGridMode = PixelGridColorMode.mood;

  // Getters
  DateTime get today => _today;
  DateTime get selectedDate => _selectedDate;
  DailyJejak get currentJejak => _currentJejak;
  List<DailyJejak> get monthlyLogs => _monthlyLogs;
  List<DailyJejak> get yearlyLogs => _yearlyLogs;
  List<NoteMemory> get notes => _notes;
  bool get isLoading => _isLoading;
  PixelGridColorMode get pixelGridMode => _pixelGridMode;

  String get selectedDateFormatted {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  /// Jalankan operasi database tanpa menjatuhkan UI jika penyimpanan gagal
  /// (misal platform tanpa SQLite). State di memori tetap tersimpan.
  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Lumi DB warning: $e');
    }
  }

  /// Inisialisasi awal saat aplikasi dibuka
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _safe(() async {
      await loadDataForDate(_selectedDate);
      await loadMonthlyData(_selectedDate.year, _selectedDate.month);
      await loadYearlyData(_selectedDate.year);
      await loadNotes();
    });

    _isLoading = false;
    notifyListeners();

    // Pantau pergantian hari WIB (reset otomatis tepat pukul 00:00 WIB)
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 20), (_) => _checkRollover());
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  /// Jika hari WIB berganti dan pengguna sedang melihat "hari ini",
  /// pindah otomatis ke hari baru dengan kondisi awal (tanpa ceklis).
  Future<void> _checkRollover() async {
    final now = wibToday();
    if (now == _today) return;

    final wasViewingToday = DateUtils.isSameDay(_selectedDate, _today);
    _today = now;
    if (wasViewingToday) {
      await loadDataForDate(now);
      await _safe(() async {
        await loadMonthlyData(now.year, now.month);
        await loadYearlyData(now.year);
      });
    }
    notifyListeners();
  }

  /// Memuat data untuk tanggal terpilih
  Future<void> loadDataForDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Tampilkan data memori jika sudah pernah diisi user, atau kondisi awal
    _currentJejak =
        _memoryLogs[dateStr] ?? DailyJejak.initialForDate(dateStr);
    notifyListeners();

    await _safe(() async {
      final existing = await _db.getDailyJejak(dateStr);
      if (existing != null) {
        _currentJejak = existing;
        _memoryLogs[dateStr] = existing;
      }
    });
    _syncMemoryCollections(_selectedDate.year, _selectedDate.month);
    notifyListeners();
  }

  /// Memuat data bulanan untuk Matriks Bulanan
  Future<void> loadMonthlyData(int year, int month) async {
    await _safe(() async {
      final dbLogs = await _db.getMonthlyLogs(year, month);
      for (final log in dbLogs) {
        _memoryLogs[log.date] = log;
      }
    });
    _syncMemoryCollections(year, month);
    notifyListeners();
  }

  /// Memuat data tahunan untuk Year in Pixels
  Future<void> loadYearlyData(int year) async {
    await _safe(() async {
      final dbLogs = await _db.getYearlyLogs(year);
      for (final log in dbLogs) {
        _memoryLogs[log.date] = log;
      }
    });
    _syncMemoryCollections(year, _selectedDate.month);
    notifyListeners();
  }

  /// Memuat seluruh catatan perasaan
  Future<void> loadNotes() async {
    await _safe(() async {
      _notes = await _db.getAllNotes();
    });
    notifyListeners();
  }

  /// Simpan jejak saat ini lalu segarkan matriks (tanpa memblokir UI)
  Future<void> _persistCurrent() async {
    if (_hasAnyUserRecord(_currentJejak)) {
      _memoryLogs[_currentJejak.date] = _currentJejak;
    } else {
      _memoryLogs.remove(_currentJejak.date);
    }
    _syncMemoryCollections(_selectedDate.year, _selectedDate.month);
    notifyListeners();

    await _safe(() async {
      await _db.saveDailyJejak(_currentJejak);
      await loadMonthlyData(_selectedDate.year, _selectedDate.month);
      await loadYearlyData(_selectedDate.year);
    });
  }

  // ===========================================================================
  // FITUR 1: Ceklis ✓ / Silang ✗ Rutinitas (Makan & Obat) - Tidak Wajib
  // ===========================================================================
  List<RoutineItem> _mapRoutine(List<RoutineItem> list, RoutineItem item, RoutineItem Function(RoutineItem) f) {
    return list.map((m) => m.id == item.id ? f(m) : m).toList();
  }

  void _applyRoutine(RoutineItem item, RoutineItem Function(RoutineItem) f) {
    if (item.type == RoutineType.makan) {
      _currentJejak = _currentJejak.copyWith(meals: _mapRoutine(_currentJejak.meals, item, f));
    } else {
      _currentJejak = _currentJejak.copyWith(medications: _mapRoutine(_currentJejak.medications, item, f));
    }
  }

  /// Memperbarui detail rutinitas (jam, status selesai/skip, catatan/menu)
  Future<void> updateRoutineItem(RoutineItem updatedItem) async {
    _applyRoutine(updatedItem, (_) => updatedItem);
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  /// Tombol ✓ : sudah dilakukan. Ketuk lagi untuk membatalkan (kembali default).
  Future<void> toggleRoutineItem(RoutineItem item) async {
    final nowTime = formatWibTime();
    final becomesDone = !item.isCompleted;

    _applyRoutine(item, (m) => becomesDone
        ? m.copyWith(isCompleted: true, isSkipped: false, completedTime: nowTime)
        : m.copyWith(isCompleted: false, clearTime: true));
    notifyListeners(); // UI langsung berubah
    await _persistCurrent();
    notifyListeners();
  }

  /// Tombol ✗ : disilang / terlewat. Ketuk lagi untuk membatalkan.
  Future<void> toggleSkipRoutineItem(RoutineItem item) async {
    final becomesSkipped = !item.isSkipped;

    _applyRoutine(item, (m) => becomesSkipped
        ? m.copyWith(isSkipped: true, isCompleted: false, clearTime: true)
        : m.copyWith(isSkipped: false));
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  /// Ceklis ✓ untuk kartu Bangun Tidur
  Future<void> toggleSleepDone() async {
    final s = _currentJejak.sleep;
    _currentJejak = _currentJejak.copyWith(
      sleep: s.copyWith(isRecorded: !s.isRecorded, isSkipped: false),
    );
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  /// Silang ✗ untuk kartu Bangun Tidur
  Future<void> toggleSleepSkipped() async {
    final s = _currentJejak.sleep;
    _currentJejak = _currentJejak.copyWith(
      sleep: s.copyWith(isSkipped: !s.isSkipped, isRecorded: false),
    );
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  // ===========================================================================
  // FITUR 2: Simpan Jejak Tidur, Kualitas, & Alasan
  // ===========================================================================
  Future<void> saveSleepRecord({
    required String jamMulai,
    required String jamBangun,
    required double durasiJam,
    required SleepQuality kualitas,
    required String alasan,
    String catatanJam = '',
  }) async {
    final newSleep = SleepRecord(
      jamMulai: jamMulai,
      jamBangun: jamBangun,
      durasiJam: durasiJam,
      kualitas: kualitas,
      alasan: alasan,
      isRecorded: true,
      catatanJam: catatanJam,
    );

    _currentJejak = _currentJejak.copyWith(sleep: newSleep);
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  // ===========================================================================
  // FITUR 3: Tombol Darurat "Lagi Sangat Lelah" (1-Tap Low-Energy Mode)
  // ===========================================================================
  /// Perbarui jadwal Pagi, Siang, Malam sekaligus untuk Makan atau Obat
  Future<void> saveRoutinesForType({
    required RoutineType type,
    required bool pagi,
    required bool siang,
    required bool malam,
    String? note,
  }) async {
    final nowTime = formatWibTime();
    List<RoutineItem> updateList(List<RoutineItem> items) {
      return items.map((item) {
        bool isTarget = false;
        if (item.id.contains('pagi')) isTarget = pagi;
        if (item.id.contains('siang')) isTarget = siang;
        if (item.id.contains('malam')) isTarget = malam;

        if (isTarget) {
          return item.copyWith(
            isCompleted: true,
            isSkipped: false,
            completedTime: item.completedTime ?? nowTime,
            note: (note != null && note.isNotEmpty) ? note : item.note,
          );
        } else {
          return item.copyWith(
            isCompleted: false,
            clearTime: true,
          );
        }
      }).toList();
    }

    if (type == RoutineType.obat) {
      _currentJejak = _currentJejak.copyWith(medications: updateList(_currentJejak.medications));
    } else {
      _currentJejak = _currentJejak.copyWith(meals: updateList(_currentJejak.meals));
    }

    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  /// Perbarui Mood Level (1-5) dan Kapasitas Energi (Rendah, Cukup, Penuh)
  Future<void> setMoodAndEnergy(int level, String energy) async {
    const moodNames = ['', 'Berat', 'Cemas', 'Tenang', 'Lega', 'Hangat'];
    final mName = level >= 1 && level <= 5 ? moodNames[level] : 'Tenang';
    final energyLabel = energy == 'penuh' ? 'Energi Penuh' : (energy == 'cukup' ? 'Energi Cukup' : 'Energi Rendah');

    _currentJejak = _currentJejak.copyWith(
      moodLevel: level,
      energyLevel: energy,
      feelingsNote: '$mName • $energyLabel',
    );
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  /// Untuk episode depresi berat: pengguna tidak dipaksa mengisi formulir.
  /// Otomatis menandai jejak hari ini agar tidak ada "lubang amnesia".
  Future<void> triggerLowEnergyMode() async {
    _currentJejak = _currentJejak.copyWith(
      moodLevel: 1, // Sangat Berat
      feelingsNote: '[Mode Lagi Lelah] Hari ini terasa sangat berat, energi minim. Istirahat sejenak.',
      isLowEnergySaved: true,
    );
    notifyListeners();
    await _persistCurrent();
    notifyListeners();
  }

  // ===========================================================================
  // FITUR 4: Tambah Catatan & Dokumentasi
  // ===========================================================================
  Future<void> addNote({
    required int moodLevel,
    required String content,
    String? photoPath,
    bool isPinnedForTherapy = false,
    String? time,
  }) async {
    final note = NoteMemory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: selectedDateFormatted,
      time: time ?? formatWibTime(),
      moodLevel: moodLevel,
      content: content,
      photoPath: photoPath,
      isPinnedForTherapy: isPinnedForTherapy,
    );

    // Perbarui mood jejak hari yang sedang dilihat
    _currentJejak = _currentJejak.copyWith(
      moodLevel: moodLevel,
      feelingsNote: content,
      hasImportantPin: isPinnedForTherapy ? true : _currentJejak.hasImportantPin,
    );
    _notes = [note, ..._notes];
    notifyListeners();

    await _safe(() async {
      await _db.insertNote(note);
    });
    await _persistCurrent();
    await loadNotes();
    notifyListeners();
  }

  /// Perbarui catatan perasaan yang sudah ada
  Future<void> updateNote({
    required String id,
    required int moodLevel,
    required String content,
    String? photoPath,
    bool isPinnedForTherapy = false,
  }) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final updated = _notes[idx].copyWith(
        moodLevel: moodLevel,
        content: content,
        photoPath: photoPath,
        isPinnedForTherapy: isPinnedForTherapy,
      );
      _notes[idx] = updated;
      notifyListeners();

      await _safe(() async {
        await _db.insertNote(updated);
      });
      await loadNotes();
      notifyListeners();
    }
  }

  /// Toggle Pin Terapi untuk konsultasi
  Future<void> togglePinNote(String noteId) async {
    final idx = _notes.indexWhere((n) => n.id == noteId);
    if (idx != -1) {
      final updated = _notes[idx].copyWith(
        isPinnedForTherapy: !_notes[idx].isPinnedForTherapy,
      );
      _notes[idx] = updated;
      notifyListeners();
      await _safe(() async {
        await _db.insertNote(updated);
      });
    }
  }

  /// Hapus catatan perasaan
  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
    await _safe(() async {
      final db = await _db.database;
      await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
    });
  }

  // ===========================================================================
  // FITUR 5: Generator Matriks Bulanan (Tabel Harian + Summary Card)
  // ===========================================================================
  /// Menghitung ringkasan skor dan wawasan otomatis bulan berjalan
  MonthlySummary get currentMonthlySummary {
    return MonthlySummary.calculate(
      _selectedDate.year,
      _selectedDate.month,
      _monthlyLogs,
    );
  }

  /// Membuat baris lengkap 1 s/d 30/31 untuk Tabel Matriks Bulanan
  List<MonthlyMatrixRow> get monthlyMatrixRows {
    int daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    Map<String, DailyJejak> logMap = {for (var log in _monthlyLogs) log.date: log};

    List<MonthlyMatrixRow> rows = [];
    for (int day = 1; day <= daysInMonth; day++) {
      String dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      if (logMap.containsKey(dateStr)) {
        rows.add(MonthlyMatrixRow.fromDailyJejak(logMap[dateStr]!));
      } else {
        // Baris kosong belum tercatat
        rows.add(MonthlyMatrixRow(
          dayNumber: day,
          dateString: dateStr,
          moodLevel: 3,
          sleepDuration: 0.0,
          sleepQuality: SleepQuality.nyenyak,
          sleepReason: '-',
          mealSummary: '⬜/⬜/⬜',
          medSummary: '⬜/⬜',
          notePreview: '',
        ));
      }
    }
    return rows;
  }

  // ===========================================================================
  // FITUR 6: Generator Grid "Year in Pixels" (Tahunan: 12 Bulan x 31 Hari)
  // ===========================================================================
  /// Menghasilkan matriks 2 dimensi (12 x 31) yang diwarnai sesuai pola mood/tidur
  List<List<YearPixelCell>> get yearInPixelsGrid {
    Map<String, DailyJejak> yearlyMap = {for (var log in _yearlyLogs) log.date: log};
    int currentYear = _selectedDate.year;

    List<List<YearPixelCell>> grid = [];

    // 12 Bulan (Baris atau Kolom)
    for (int month = 1; month <= 12; month++) {
      int daysInMonth = DateUtils.getDaysInMonth(currentYear, month);
      List<YearPixelCell> monthCells = [];

      for (int day = 1; day <= 31; day++) {
        if (day <= daysInMonth) {
          String dateStr = '$currentYear-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          if (yearlyMap.containsKey(dateStr)) {
            final log = yearlyMap[dateStr]!;
            monthCells.add(YearPixelCell(
              month: month,
              day: day,
              dateString: dateStr,
              moodLevel: log.moodLevel,
              sleepQuality: log.sleep.kualitas,
              hasData: true,
            ));
          } else {
            monthCells.add(YearPixelCell(
              month: month,
              day: day,
              dateString: dateStr,
              hasData: false,
            ));
          }
        } else {
          // Tanggal di luar jumlah hari bulan (misal tgl 31 di bulan Februari)
          monthCells.add(YearPixelCell(
            month: month,
            day: day,
            dateString: '',
            hasData: false,
          ));
        }
      }
      grid.add(monthCells);
    }
    return grid;
  }

  /// Ganti filter warna grid (Mood vs Kualitas Tidur)
  void setPixelGridMode(PixelGridColorMode mode) {
    _pixelGridMode = mode;
    notifyListeners();
  }
}
