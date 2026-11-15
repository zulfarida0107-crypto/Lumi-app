import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../models/models.dart';

/// ============================================================================
/// DATABASE LOKAL: LUMI DATABASE (Offline-First)
/// ============================================================================
/// Mengelola penyimpanan lokal di memori HP menggunakan SQLite.
/// Aplikasi 100% dapat berjalan tanpa internet sehingga privasi pengguna
/// tetap terjaga penuh.
class LumiDatabase {
  static final LumiDatabase instance = LumiDatabase._init();
  static Database? _database;

  LumiDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lumi_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE daily_jejak ADD COLUMN sleep_isSkipped INTEGER DEFAULT 0');
          await db.execute("ALTER TABLE daily_jejak ADD COLUMN sleep_catatanJam TEXT DEFAULT ''");
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel Jejak Harian (Tidur, Kualitas, Alasan, Makan, Obat, Mood)
    await db.execute('''
      CREATE TABLE daily_jejak (
        date TEXT PRIMARY KEY,
        sleep_jamMulai TEXT,
        sleep_jamBangun TEXT,
        sleep_durasiJam REAL,
        sleep_kualitas TEXT,
        sleep_alasan TEXT,
        sleep_isRecorded INTEGER,
        sleep_isSkipped INTEGER DEFAULT 0,
        sleep_catatanJam TEXT DEFAULT '',
        moodLevel INTEGER,
        feelingsNote TEXT,
        isLowEnergySaved INTEGER,
        hasImportantPin INTEGER,
        meals_completed TEXT,
        meds_completed TEXT
      )
    ''');

    // 2. Tabel Catatan Perasaan & Dokumentasi Memori
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        date TEXT,
        time TEXT,
        moodLevel INTEGER,
        content TEXT,
        photoPath TEXT,
        audioPath TEXT,
        tags TEXT,
        isPinnedForTherapy INTEGER
      )
    ''');

    // Seed data contoh awal agar tabel matriks langsung terisi indah
    await _seedInitialData(db);
  }

  /// Menyiapkan data riwayat contoh untuk November 2026
  Future<void> _seedInitialData(Database db) async {
    final sampleLogs = [
      DailyJejak(
        date: '2026-11-15',
        sleep: const SleepRecord(
          jamMulai: '00:30',
          jamBangun: '07:00',
          durasiJam: 6.5,
          kualitas: SleepQuality.seringTerbangun,
          alasan: 'Kebangun jam 3 pagi karena cemas & haus',
          isRecorded: true,
        ),
        moodLevel: 2,
        feelingsNote: 'Badan lemas, siang sempat lupa makan.',
        hasImportantPin: true,
      ),
      DailyJejak(
        date: '2026-11-14',
        sleep: const SleepRecord(
          jamMulai: '22:45',
          jamBangun: '06:30',
          durasiJam: 7.75,
          kualitas: SleepQuality.nyenyak,
          alasan: 'Mandi air hangat & minum obat tepat waktu',
          isRecorded: true,
        ),
        moodLevel: 4,
        feelingsNote: 'Hari ini pikiran cukup jernih dan tenang.',
      ),
      DailyJejak(
        date: '2026-11-13',
        sleep: const SleepRecord(
          jamMulai: '01:15',
          jamBangun: '06:15',
          durasiJam: 5.0,
          kualitas: SleepQuality.insomnia,
          alasan: 'Overthinking pekerjaan tugas akhir',
          isRecorded: true,
        ),
        moodLevel: 2,
        feelingsNote: 'Kepala penat, butuh istirahat.',
      ),
      DailyJejak(
        date: '2026-11-12',
        sleep: const SleepRecord(
          jamMulai: '23:30',
          jamBangun: '07:30',
          durasiJam: 8.0,
          kualitas: SleepQuality.nyenyak,
          alasan: 'Jalan santai sore hari',
          isRecorded: true,
        ),
        moodLevel: 5,
        feelingsNote: 'Bisa tersenyum lepas saat bertemu teman.',
      ),
      DailyJejak(
        date: '2026-11-11',
        sleep: const SleepRecord(
          jamMulai: '02:00',
          jamBangun: '06:30',
          durasiJam: 4.5,
          kualitas: SleepQuality.insomnia,
          alasan: 'Susah terlelap dan gelisah',
          isRecorded: true,
        ),
        moodLevel: 1,
        feelingsNote: 'Hari sangat berat, menggunakan Mode Lagi Lelah.',
        isLowEnergySaved: true,
      ),
    ];

    for (var log in sampleLogs) {
      await db.insert(
        'daily_jejak',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Simpan atau perbarui log harian
  Future<void> saveDailyJejak(DailyJejak jejak) async {
    final db = await database;
    await db.insert(
      'daily_jejak',
      jejak.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ambil log hari tertentu
  Future<DailyJejak?> getDailyJejak(String date) async {
    final db = await database;
    final results = await db.query(
      'daily_jejak',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (results.isNotEmpty) {
      return DailyJejak.fromMap(results.first);
    }
    return null;
  }

  /// Ambil log untuk 1 bulan penuh (misal: 2026-11-%)
  Future<List<DailyJejak>> getMonthlyLogs(int year, int month) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year-$monthStr-%';

    final results = await db.query(
      'daily_jejak',
      where: 'date LIKE ?',
      whereArgs: [pattern],
      orderBy: 'date ASC',
    );

    return results.map((m) => DailyJejak.fromMap(m)).toList();
  }

  /// Ambil seluruh log tahunan untuk "Year in Pixels"
  Future<List<DailyJejak>> getYearlyLogs(int year) async {
    final db = await database;
    final pattern = '$year-%';

    final results = await db.query(
      'daily_jejak',
      where: 'date LIKE ?',
      whereArgs: [pattern],
      orderBy: 'date ASC',
    );

    return results.map((m) => DailyJejak.fromMap(m)).toList();
  }

  /// Tambah catatan perasaan
  Future<void> insertNote(NoteMemory note) async {
    final db = await database;
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Ambil semua catatan bertanda ⭐ Pin Terapi
  Future<List<NoteMemory>> getPinnedNotes() async {
    final db = await database;
    final results = await db.query(
      'notes',
      where: 'isPinnedForTherapy = 1',
      orderBy: 'date DESC, time DESC',
    );
    return results.map((m) => NoteMemory.fromMap(m)).toList();
  }

  /// Ambil seluruh catatan perasaan
  Future<List<NoteMemory>> getAllNotes() async {
    final db = await database;
    final results = await db.query('notes', orderBy: 'date DESC, time DESC');
    if (results.isEmpty) {
      final initialNotes = [
        const NoteMemory(
          id: 'note_1',
          date: 'Kemarin, 14 Nov',
          time: '21:15',
          moodLevel: 2,
          content: 'Badan terasa sangat berat sejak jam 3 sore. Sempat lupa sudah minum obat siang atau belum, lalu cemas berlebih. Mencoba grounding teknik 5-4-3-2-1 di kamar sampai detak jantung kembali melambat...',
          photoPath: 'assets/public/lumi_app_icon.jpg',
          audioPath: 'audio_memo_1.m4a',
          isPinnedForTherapy: true,
          tags: ['Grounding', 'Terapi'],
        ),
        const NoteMemory(
          id: 'note_2',
          date: '12 Nov',
          time: '10:30',
          moodLevel: 3,
          content: 'Mulai mencoba jalan kaki 10 menit di sekitar teras. Sinar matahari pagi membantu sedikit mengurangi rasa hampa. Menanam tanaman sirih gading di pot kecil.',
          isPinnedForTherapy: false,
          tags: ['Jalan Kaki', 'Tanaman'],
        ),
        const NoteMemory(
          id: 'note_3',
          date: '10 Nov',
          time: '02:15 (Tengah Malam)',
          moodLevel: 1,
          content: 'Pikiran bising sekali, insomnia kambuh. Tidak sanggup mengetik banyak, hanya butuh menandai bahwa malam ini terlewati.',
          isPinnedForTherapy: false,
          tags: ['1-Tap Low-Energy', 'Insomnia'],
        ),
        const NoteMemory(
          id: 'note_4',
          date: '08 Nov',
          time: '16:40',
          moodLevel: 4,
          content: 'Sesi mengobrol singkat dengan teman lama lewat telepon. Senang rasanya bisa tertawa tanpa merasa bersalah. Semoga energi ini bisa menetap sampai esok.',
          isPinnedForTherapy: false,
          tags: ['Teman', 'Lega'],
        ),
      ];
      for (final n in initialNotes) {
        await db.insert('notes', n.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return initialNotes;
    }
    return results.map((m) => NoteMemory.fromMap(m)).toList();
  }
}
