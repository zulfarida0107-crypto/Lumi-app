import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';
import 'ringkasan.dart';

/// ============================================================================
/// LAYAR TAB 3: MATRIKS BULANAN & PERKEMBANGAN
/// ============================================================================
/// Mengadopsi arsitektur visual HTML/Tailwind Lumi:
/// 1. Title & Subtitle: "Matriks Bulanan" + Badge Tanggal
/// 2. Segmented Tab Switcher Kapsul: [ Bulanan | Tahunan ]
/// 3. Month Navigation Pill: < NOVEMBER 2026 >
/// 4. Monthly Summary Bento Card:
///    - Rangkuman Bulan & Badge Hari Tercatat
///    - Metric Island Grid: Rata-rata Suasana & Durasi Tidur
///    - Progress Trackers: Kepatuhan Obat (Linear Bar) & Jadwal Makan (Linear Bar)
///    - Mood Spectrum Legend (1 Berat s/d 5 Stabil)
/// 5. Daily Matrix Table Section:
///    - Header & Hint Banner: "Ketuk baris tanggal untuk membaca catatan..."
///    - Horizontal Scrollable Table: Tgl, Suasana Hati, Tidur, Kualitas, Obat, Makan, Aksi
///    - Interaktif: Ketuk baris untuk membuka teks jurnal harian
/// 6. Bento Card Pola Teridentifikasi Bulan Ini (Insights)
/// 7. Tombol Aksi: "Lihat Ringkasan Konsultasi Dokter" (Popup Modal Konsultasi)
/// 8. Sub-tab Tahunan: "Year in Pixels" (Grid 12 Bulan x 31 Hari)
class MatriksScreen extends StatefulWidget {
  const MatriksScreen({super.key});

  @override
  State<MatriksScreen> createState() => _MatriksScreenState();
}

class _MatriksScreenState extends State<MatriksScreen> {
  // 0: Bulanan, 1: Tahunan
  int _activeTabIndex = 0;

  // Mode Tampilan di Tab Tahunan (0: Year in Pixels, 1: Kalender 12 Bulan)
  int _tahunanViewMode = 0;

  // Tanggal hari yang dipilih di Kalender Bulanan
  int? _selectedCalendarDay;

  void _changeYear(LumiProvider provider, int delta) {
    final cur = provider.selectedDate;
    final next = DateTime(cur.year + delta, cur.month, 1);
    provider.loadDataForDate(next);
    provider.loadMonthlyData(next.year, next.month);
    provider.loadYearlyData(next.year);
  }

  void _setMonthAndYear(LumiProvider provider, int year, int month) {
    final next = DateTime(year, month, 1);
    provider.loadDataForDate(next);
    provider.loadMonthlyData(next.year, next.month);
    provider.loadYearlyData(next.year);
  }

  static String _namaHariLengkap(int weekday) {
    const names = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    if (weekday >= 1 && weekday <= 7) return names[weekday];
    return '';
  }

  String _namaBulan(int month) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) return bulan[month];
    return '';
  }

  String _namaBulanShort(int month) {
    const bulanShort = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) return bulanShort[month];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LumiProvider>();
    final summary = provider.currentMonthlySummary;
    final rows = provider.monthlyMatrixRows;
    final sel = provider.selectedDate;

    // Default hari yang dipilih di kalender bulanan
    final daysInCurrentMonth = DateUtils.getDaysInMonth(sel.year, sel.month);
    if (_selectedCalendarDay == null || _selectedCalendarDay! > daysInCurrentMonth) {
      if (sel.year == provider.today.year && sel.month == provider.today.month) {
        _selectedCalendarDay = provider.today.day;
      } else {
        _selectedCalendarDay = 1;
      }
    }

    return Container(
      color: const Color(0xFFFCF8FA), // background
      child: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            // 1. TITLE & SUBTITLE SECTION
            _buildTitleSection(),

            const SizedBox(height: 12),

            // 2. SEGMENTED TAB SWITCHER (Bulanan vs Tahunan)
            _buildSegmentedSwitcher(),

            const SizedBox(height: 14),

            if (_activeTabIndex == 0) ...[
              // 4. MONTHLY SUMMARY BENTO CARD
              _buildMonthlySummaryCard(summary, sel, rows),

              const SizedBox(height: 14),

              // KALENDER BULANAN DINAMIS (KETUK TANGGAL -> MUNCUL DETAIL DARI BAWAH)
              _buildMonthlyCalendarSection(provider, sel, rows),

              const SizedBox(height: 14),

              // 6. MONTHLY INSIGHTS & HIGHLIGHTS BENTO CARD (DINAMIS DARI DATA USER)
              _buildInsightsSection(summary, rows, sel),

              const SizedBox(height: 16),

              // 7. CONSULTATION SUMMARY CALLOUT BUTTON
              _buildConsultationCalloutButton(context, provider),
            ] else ...[
              // SUB-TAB TAHUNAN (Year Navigation Pill + Switcher [Year in Pixels | Kalender 12 Bulan])
              _buildTahunanContent(provider, sel),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TITLE & SUBTITLE SECTION
  // ===========================================================================
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _activeTabIndex == 0 ? 'Matriks Bulanan' : 'Year in Pixels',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Color(0xFF1D3958), // primary
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _activeTabIndex == 0
              ? 'Pola ritme tubuh & suasana hati harian'
              : 'Setiap kotak merefleksikan 1 hari tanpa penghakiman',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12.5,
            color: Color(0xFF595D78), // secondary
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. SEGMENTED TAB SWITCHER (Bulanan vs Tahunan)
  // ===========================================================================
  Widget _buildSegmentedSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDEF), // surface-container
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFEBE7E9).withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Tab Bulanan
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTabIndex = 0),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTabIndex == 0
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _activeTabIndex == 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFF355070).withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Bulanan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      fontWeight: _activeTabIndex == 0
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _activeTabIndex == 0
                          ? const Color(0xFF1D3958)
                          : const Color(0xFF595D78),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab Tahunan
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTabIndex = 1),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTabIndex == 1
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _activeTabIndex == 1
                      ? [
                          BoxShadow(
                            color: const Color(0xFF355070).withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Tahunan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      fontWeight: _activeTabIndex == 1
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _activeTabIndex == 1
                          ? const Color(0xFF1D3958)
                          : const Color(0xFF595D78),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. MONTHLY SUMMARY BENTO CARD
  // ===========================================================================
  Widget _buildMonthlySummaryCard(
    MonthlySummary summary,
    DateTime sel,
    List<MonthlyMatrixRow> rows,
  ) {
    final int goodRestDays = rows.where((r) => r.sleepDuration >= 7.0).length;
    final String moodStatusText = summary.totalDaysRecorded == 0
        ? 'Belum ada jejak tercatat'
        : summary.averageMood >= 4.0
            ? 'Suasana hati sangat tenang'
            : summary.averageMood >= 3.0
                ? 'Kondisi terpantau stabil'
                : 'Perlu waktu istirahat ekstra';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bento: Rekapitulasi & Rangkuman Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REKAPITULASI ${summary.totalDaysRecorded} HARI',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF595D78),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rangkuman ${_namaBulan(sel.month)}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9E1), // tertiary-fixed
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${summary.totalDaysRecorded} Hari Tercatat',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30111B), // on-tertiary-fixed
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Metric Island Grid (Mood & Tidur)
          Row(
            children: [
              // Island 1: Rata-rata Suasana
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2F4), // surface-container-low
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE7E9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.sentiment_satisfied_rounded,
                            size: 15,
                            color: Color(0xFF512D38),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Rata-rata Suasana',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            summary.averageMood.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            '/ 5.0',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 13,
                            color: Color(0xFF1D3958),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              moodStatusText,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D3958),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Island 2: Durasi Tidur
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE7E9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.bedtime_rounded,
                            size: 15,
                            color: Color(0xFF1D3958),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Durasi Tidur',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            summary.averageSleepDuration.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Jam/hari',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$goodRestDays hari cukup rest (≥7j)',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1EDEF)),
          const SizedBox(height: 12),

          // Routine & Therapy Progress Trackers (Linear Progress Bars)
          Column(
            children: [
              // Obat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.medication_rounded,
                        size: 15,
                        color: Color(0xFF1D3958),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Kepatuhan Rutin Obat',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${summary.medAdherencePercentage.toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (summary.medAdherencePercentage / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF1EDEF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D3958)),
                ),
              ),

              const SizedBox(height: 12),

              // Makan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.restaurant_rounded,
                        size: 15,
                        color: Color(0xFF595D78),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Jadwal Makan Teratur',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${summary.mealRegularityPercentage.toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (summary.mealRegularityPercentage / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF1EDEF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF595D78)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1EDEF)),
          const SizedBox(height: 12),

          // Mood Spectrum Legend (Indikator Tingkat Mood 1-5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Indikator Tingkat Mood',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF595D78),
                ),
              ),
              Text(
                'Skala 1 (Berat) — 5 (Damai)',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  color: Color(0xFF73777E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildSpectrumChip('1 Berat', const Color(0xFF355070)),
              const SizedBox(width: 6),
              _buildSpectrumChip('2 Lelah', const Color(0xFF6D597A)),
              const SizedBox(width: 6),
              _buildSpectrumChip('3 Biasa', const Color(0xFFB56576)),
              const SizedBox(width: 6),
              _buildSpectrumChip('4 Tenang', const Color(0xFFE56B6F)),
              const SizedBox(width: 6),
              _buildSpectrumChip('5 Stabil', const Color(0xFF84A98C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumChip(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER TOMBOL SUB-SWITCHER (DIGUNAKAN PADA TAB TAHUNAN)
  // ===========================================================================
  Widget _subViewSwitchButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF355070).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFF1D3958)
                  : const Color(0xFF595D78),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1D3958)
                    : const Color(0xFF595D78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // KALENDER BULANAN & ALUR JEJAK HARIAN (KETUK TANGGAL -> POPUP DARI BAWAH)
  // ===========================================================================
  Widget _buildMonthlyCalendarSection(
    LumiProvider provider,
    DateTime sel,
    List<MonthlyMatrixRow> rows,
  ) {
    final daysInMonth = DateUtils.getDaysInMonth(sel.year, sel.month);
    final firstDayOfMonth = DateTime(sel.year, sel.month, 1);
    // startOffset: 0 untuk Senin s/d 6 untuk Minggu
    final startOffset = firstDayOfMonth.weekday - 1;
    final prevMonthDate = DateTime(sel.year, sel.month - 1, 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(prevMonthDate.year, prevMonthDate.month);

    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final totalSlots = rowCount * 7;

    final Map<int, MonthlyMatrixRow> rowMap = {
      for (var r in rows) r.dayNumber: r,
    };
    final Set<String> recordedDates = {
      for (final log in provider.monthlyLogs) log.date,
    };

    const weekHeaders = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kalender Bulanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD9E1).withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: Color(0xFF512D38),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kalender & Alur Jejak Harian',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          Text(
                            '${_namaBulan(sel.month)} ${sel.year}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showMonthYearPickerModal(context, provider, sel),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EDEF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.tune_rounded, size: 13, color: Color(0xFF595D78)),
                      SizedBox(width: 4),
                      Text(
                        'Pilih Bulan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Baris Nama Hari (Sen - Min)
          Row(
            children: List.generate(7, (i) {
              final isWeekend = i >= 5;
              return Expanded(
                child: Center(
                  child: Text(
                    weekHeaders[i],
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isWeekend
                          ? const Color(0xFFB56576)
                          : const Color(0xFF595D78),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1EDEF)),
          const SizedBox(height: 10),

          // Grid Kotak Tanggal (Ketuk Tanggal -> Muncul Bottom Sheet dari Bawah)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 6,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, slot) {
              // Di luar bulan ini (sebelum tgl 1)
              if (slot < startOffset) {
                final prevDay = daysInPrevMonth - startOffset + slot + 1;
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$prevDay',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFFC3C6CE),
                    ),
                  ),
                );
              }

              final dayNum = slot - startOffset + 1;

              // Di luar bulan ini (setelah akhir bulan)
              if (dayNum > daysInMonth) {
                final nextDay = dayNum - daysInMonth;
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$nextDay',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFFC3C6CE),
                    ),
                  ),
                );
              }

              // HARI DI DALAM BULAN INI
              final r = rowMap[dayNum];
              final isToday = DateUtils.isSameDay(
                DateTime(sel.year, sel.month, dayNum),
                provider.today,
              );
              final isSelected = _selectedCalendarDay == dayNum;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCalendarDay = dayNum;
                  });
                  _showDayDetailBottomSheet(context, provider, sel, dayNum, r);
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF6F2F4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1D3958)
                          : isToday
                              ? const Color(0xFF355070)
                              : const Color(0xFFEBE7E9),
                      width: isSelected ? 2.0 : (isToday ? 1.5 : 1.0),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1D3958).withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isToday
                                  ? const Color(0xFF1D3958)
                                  : const Color(0xFF1C1B1D),
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF355070),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (r != null && recordedDates.contains(r.dateString)) ...[
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: r.moodColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${r.moodLevel}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Text(
                          '-',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC3C6CE),
                          ),
                        ),
                      ],

                      if (r != null && r.sleepDuration > 0)
                        Text(
                          '${r.sleepDuration.toStringAsFixed(1)}j',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF595D78),
                          ),
                        )
                      else
                        const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Info Petunjuk Interaktif
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC3C6CE).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF355070)),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Ketuk tanggal pada kalender untuk menampilkan rincian jejak harian',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // POPUP BOTTOM SHEET DETAIL JEJAK HARIAN (MUNCUL DARI BAWAH SEPERTI MODAL MAKAN)
  // ===========================================================================
  void _showDayDetailBottomSheet(
    BuildContext context,
    LumiProvider provider,
    DateTime sel,
    int dayNum,
    MonthlyMatrixRow? r,
  ) {
    final dayDate = DateTime(sel.year, sel.month, dayNum);
    final isToday = DateUtils.isSameDay(dayDate, provider.today);
    final moodInfo = _getMoodInfo(r?.moodLevel ?? 3);

    final isRecordedDay =
        r != null && provider.monthlyLogs.any((l) => l.date == r.dateString);
    final hasMed = r != null &&
        (r.medSummary.contains('✅') ||
            r.medSummary.contains('❌') ||
            r.medSummary.contains('✓') ||
            r.medSummary.toLowerCase().contains('diminum') ||
            r.medSummary.contains('1') ||
            r.medSummary.contains('2'));
    final hasMeal = r != null &&
        (r.mealSummary.contains('✅') ||
            r.mealSummary.contains('❌') ||
            r.mealSummary.contains('✓') ||
            r.mealSummary.toLowerCase().contains('tercatat') ||
            r.mealSummary.contains('1') ||
            r.mealSummary.contains('2') ||
            r.mealSummary.contains('3'));
    final hasSleep = r != null && r.sleepDuration > 0;
    final hasNote = r != null && r.notePreview.trim().isNotEmpty;
    final hasMood = isRecordedDay || hasNote || hasSleep || hasMed || hasMeal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.86,
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC3C6CE).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header (Mirip Popup Makan: Ikon Bulat Pink, Judul, Subjudul, Tombol X)
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC0CB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      size: 22,
                      color: Color(0xFF512D38),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${_namaHariLengkap(dayDate.weekday)}, $dayNum ${_namaBulan(sel.month)} ${sel.year}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDEE0FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Hari Ini',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF161A32),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Text(
                          'Ringkasan jejak suasana hati, tidur, obat & makan',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF595D78)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Konten Scrollable agar catatan panjang tidak pernah terpotong
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Status Ritme Harian (3 Kartu Sejajar seperti Pagi, Siang, Malam)
                      const Text(
                        'Status Ritme Harian',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595D78),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // Kartu 1: Mood
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCF8FA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.wb_sunny_outlined,
                                    size: 20,
                                    color: hasMood
                                        ? (moodInfo['dot'] as Color)
                                        : const Color(0xFF73777E),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hasMood ? (moodInfo['name'] as String) : '-',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: hasMood
                                          ? (moodInfo['fg'] as Color)
                                          : const Color(0xFF1D3958),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Mood',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10.5,
                                      color: Color(0xFF73777E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Kartu 2: Tidur
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCF8FA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.nightlight_round,
                                    size: 20,
                                    color: Color(0xFF355070),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hasSleep
                                        ? '${r.sleepDuration.toStringAsFixed(1)} Jam'
                                        : '-',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D3958),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  hasSleep
                                      ? _buildSleepQualityPill(r.sleepQuality)
                                      : const Text(
                                          'Tidur',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10.5,
                                            color: Color(0xFF73777E),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Kartu 3: Obat & Makan
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCF8FA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.restaurant_rounded,
                                    size: 20,
                                    color: Color(0xFF512D38),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hasMed ? 'Obat ✓' : 'Obat -',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D3958),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hasMeal ? 'Makan ✓' : 'Makan -',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF595D78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. Rincian Tidur, Obat & Makan
                      const Text(
                        'Rincian Aktivitas & Tidur',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595D78),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF8FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.bedtime_outlined, size: 15, color: Color(0xFF355070)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasSleep
                                        ? 'Tidur: ${r.sleepDuration.toStringAsFixed(1)} jam${r.sleepReason.isNotEmpty && r.sleepReason != '-' ? ' (${r.sleepReason})' : ''}'
                                        : 'Tidur: -',
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Color(0xFF1D3958),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.medication_outlined, size: 15, color: Color(0xFF355070)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasMed ? 'Obat: ${r.medSummary}' : 'Obat: -',
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Color(0xFF1D3958),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.restaurant_outlined, size: 15, color: Color(0xFF355070)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasMeal ? 'Makan: ${r.mealSummary}' : 'Makan: -',
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Color(0xFF1D3958),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Catatan Perasaan & Jurnal Harian (Utuh Tanpa Terpotong)
                      const Text(
                        'Catatan Perasaan & Jurnal Harian',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595D78),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF8FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          hasNote ? '“${r.notePreview}”' : '-',
                          softWrap: true,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontStyle: FontStyle.normal,
                            height: 1.5,
                            color: hasNote
                                ? const Color(0xFF1D3958)
                                : const Color(0xFF73777E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Tombol Aksi (Mirip Tombol Batal & Simpan Catatan di Gambar)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: const Color(0xFFC3C6CE).withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        provider.loadDataForDate(dayDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tanggal $dayNum ${_namaBulan(sel.month)} ${sel.year} aktif di Garis Waktu.',
                            ),
                            backgroundColor: const Color(0xFF1D3958),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D3958),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Buka di Garis Waktu',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODAL PEMILIH BULAN & TAHUN (DYNAMIC MONTH-YEAR PICKER)
  // ===========================================================================
  void _showMonthYearPickerModal(
    BuildContext context,
    LumiProvider provider,
    DateTime sel,
  ) {
    int tempYear = sel.year;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC3C6CE).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Bulan & Tahun',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EDEF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              color: const Color(0xFF1D3958),
                              onPressed: () {
                                setModalState(() => tempYear--);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '$tempYear',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              color: const Color(0xFF1D3958),
                              onPressed: () {
                                setModalState(() => tempYear++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.3,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, idx) {
                      final m = idx + 1;
                      final isSelected = (m == sel.month && tempYear == sel.year);
                      final isCurrentMonth = (m == provider.today.month && tempYear == provider.today.year);

                      return InkWell(
                        onTap: () {
                          _setMonthAndYear(provider, tempYear, m);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1D3958)
                                : isCurrentMonth
                                    ? const Color(0xFFDEE0FF).withValues(alpha: 0.5)
                                    : const Color(0xFFF6F2F4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1D3958)
                                  : isCurrentMonth
                                      ? const Color(0xFF355070)
                                      : const Color(0xFFEBE7E9),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _namaBulan(m),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12.5,
                              fontWeight: isSelected || isCurrentMonth
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1D3958),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        _setMonthAndYear(provider, provider.today.year, provider.today.month);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.today_rounded, size: 16, color: Color(0xFF1D3958)),
                      label: Text(
                        'Lompat ke Bulan Ini (${_namaBulanShort(provider.today.month)} ${provider.today.year})',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1EDEF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _getMoodInfo(int level) {
    switch (level) {
      case 1:
        return {
          'name': '1 Berat',
          'dot': const Color(0xFF355070),
          'bg': const Color(0xFF355070).withValues(alpha: 0.18),
          'fg': const Color(0xFF172433),
        };
      case 2:
        return {
          'name': '2 Lelah',
          'dot': const Color(0xFF6D597A),
          'bg': const Color(0xFF6D597A).withValues(alpha: 0.18),
          'fg': const Color(0xFF302237),
        };
      case 3:
        return {
          'name': '3 Biasa',
          'dot': const Color(0xFFB56576),
          'bg': const Color(0xFFB56576).withValues(alpha: 0.18),
          'fg': const Color(0xFF542730),
        };
      case 4:
        return {
          'name': '4 Tenang',
          'dot': const Color(0xFFE56B6F),
          'bg': const Color(0xFFE56B6F).withValues(alpha: 0.18),
          'fg': const Color(0xFF6B2A2D),
        };
      case 5:
      default:
        return {
          'name': '5 Damai',
          'dot': const Color(0xFF84A98C),
          'bg': const Color(0xFF84A98C).withValues(alpha: 0.20),
          'fg': const Color(0xFF2D5A38),
        };
    }
  }

  Widget _buildSleepQualityPill(SleepQuality q) {
    Color bg;
    Color fg;
    String text;

    switch (q) {
      case SleepQuality.nyenyak:
        bg = const Color(0xFFDEE0FF); // secondary-fixed
        fg = const Color(0xFF161A32);
        text = 'Pulas';
        break;
      case SleepQuality.biasa:
        bg = const Color(0xFFF1EDEF); // surface-container
        fg = const Color(0xFF595D78);
        text = 'Biasa';
        break;
      case SleepQuality.seringTerbangun:
        bg = const Color(0xFFFFD9E1); // tertiary-fixed
        fg = const Color(0xFF30111B);
        text = 'Bangun';
        break;
      case SleepQuality.insomnia:
        bg = const Color(0xFFFFDAD6); // error-container
        fg = const Color(0xFF93000A);
        text = 'Susah';
        break;
      case SleepQuality.hypersomnia:
        bg = const Color(0xFFDBDEFF); // secondary-container
        fg = const Color(0xFF161A32);
        text = 'Berlebih';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. MONTHLY INSIGHTS & HIGHLIGHTS BENTO CARD (DINAMIS DARI DATA USER)
  // ===========================================================================
  Widget _buildInsightsSection(
    MonthlySummary summary,
    List<MonthlyMatrixRow> rows,
    DateTime sel,
  ) {
    // 1. Analisis Dinamis Pola Tidur vs Suasana Hati
    final sleepRows = rows.where((r) => r.sleepDuration > 0).toList();
    final goodSleepRows = sleepRows.where((r) => r.sleepDuration >= 7.0).toList();
    final shortSleepRows = sleepRows.where((r) => r.sleepDuration < 7.0).toList();

    List<InlineSpan> sleepInsightSpans;
    if (summary.totalDaysRecorded == 0) {
      sleepInsightSpans = [
        TextSpan(
          text: 'Belum ada data tidur di ${_namaBulan(sel.month)} ${sel.year}. ',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        const TextSpan(
          text: 'Catat jam tidur harianmu agar Lumi dapat menghitung dampak tidur terhadap kestabilan suasana hatimu.',
        ),
      ];
    } else if (sleepRows.isEmpty) {
      sleepInsightSpans = [
        TextSpan(
          text: 'Tercatat ${summary.totalDaysRecorded} hari jejak aktif ',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        const TextSpan(text: 'dengan rata-rata mood '),
        TextSpan(
          text: '${summary.averageMood.toStringAsFixed(1)}/5.0. ',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D3958),
          ),
        ),
        const TextSpan(
          text: 'Tambahkan durasi tidur harian untuk melihat korelasi tidur dan suasana hati.',
        ),
      ];
    } else if (goodSleepRows.isNotEmpty && shortSleepRows.isNotEmpty) {
      final avgGood = goodSleepRows.fold<double>(0, (s, r) => s + r.moodLevel) / goodSleepRows.length;
      final avgShort = shortSleepRows.fold<double>(0, (s, r) => s + r.moodLevel) / shortSleepRows.length;
      final diffPct = avgShort > 0 ? (((avgGood - avgShort) / avgShort) * 100).round() : 0;

      if (diffPct > 0) {
        sleepInsightSpans = [
          TextSpan(
            text: 'Tidur cukup (≥7 jam pada ${goodSleepRows.length} hari) ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3958),
            ),
          ),
          const TextSpan(
            text: 'meningkatkan rata-rata ketenangan suasana hati sebesar ',
          ),
          TextSpan(
            text: '+$diffPct% ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3958),
            ),
          ),
          TextSpan(
            text: '(mood ${avgGood.toStringAsFixed(1)} vs ${avgShort.toStringAsFixed(1)} saat tidur <7 jam).',
          ),
        ];
      } else {
        sleepInsightSpans = [
          TextSpan(
            text: 'Rata-rata tidur ${summary.averageSleepDuration.toStringAsFixed(1)} jam/hari ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3958),
            ),
          ),
          TextSpan(
            text: '(${goodSleepRows.length} hari ≥7 jam, ${shortSleepRows.length} hari <7 jam) disertai rata-rata mood ',
          ),
          TextSpan(
            text: '${summary.averageMood.toStringAsFixed(1)}/5.0 ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3958),
            ),
          ),
          const TextSpan(text: 'bulan ini.'),
        ];
      }
    } else if (goodSleepRows.isNotEmpty) {
      final avgGood = goodSleepRows.fold<double>(0, (s, r) => s + r.moodLevel) / goodSleepRows.length;
      sleepInsightSpans = [
        TextSpan(
          text: 'Tidur cukup (≥7 jam selama ${goodSleepRows.length} hari) ',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        const TextSpan(text: 'dengan rata-rata '),
        TextSpan(
          text: '${summary.averageSleepDuration.toStringAsFixed(1)} jam/hari ',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D3958),
          ),
        ),
        TextSpan(
          text: 'menjaga rata-rata suasana hati tetap stabil di level ${avgGood.toStringAsFixed(1)}/5.0.',
        ),
      ];
    } else {
      final avgShort = shortSleepRows.fold<double>(0, (s, r) => s + r.moodLevel) / shortSleepRows.length;
      sleepInsightSpans = [
        TextSpan(
          text: 'Durasi tidur rata-rata ${summary.averageSleepDuration.toStringAsFixed(1)} jam/hari ',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        TextSpan(
          text: '(di bawah 7 jam pada ${shortSleepRows.length} hari tercatat) disertai rata-rata mood ',
        ),
        TextSpan(
          text: '${avgShort.toStringAsFixed(1)}/5.0. ',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D3958),
          ),
        ),
        const TextSpan(text: 'Cobalah beristirahat lebih awal malam ini.'),
      ];
    }

    // 2. Analisis Dinamis Hari Terbaik & Kepatuhan Rutinitas (Obat & Makan)
    final activeRows = rows.where((r) {
      final hasMed = r.medSummary.contains('✓') ||
          r.medSummary.contains('✅') ||
          r.medSummary.toLowerCase().contains('diminum') ||
          r.medSummary.contains('1') ||
          r.medSummary.contains('2');
      final hasMeal = r.mealSummary.contains('✓') ||
          r.mealSummary.contains('✅') ||
          r.mealSummary.toLowerCase().contains('tercatat') ||
          r.mealSummary.contains('1') ||
          r.mealSummary.contains('2') ||
          r.mealSummary.contains('3');
      return r.sleepDuration > 0 ||
          r.notePreview.trim().isNotEmpty ||
          hasMed ||
          hasMeal ||
          r.moodLevel != 3;
    }).toList();

    List<InlineSpan> weekdayInsightSpans;
    if (summary.totalDaysRecorded == 0 && activeRows.isEmpty) {
      weekdayInsightSpans = const [
        TextSpan(
          text: 'Pola hari & rutinitas belum terbentuk. ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF512D38),
          ),
        ),
        TextSpan(
          text: 'Setelah kamu mengisi mood, jadwal obat, atau makan, Lumi akan menampilkan hari paling tenang dan persentase rutinitasmu di sini.',
        ),
      ];
    } else {
      final sourceRows = activeRows.isNotEmpty ? activeRows : rows;
      final Map<int, List<double>> weekdayScores = {};
      final Map<int, List<int>> weekdayMoods = {};

      for (final r in sourceRows) {
        final d = DateTime(sel.year, sel.month, r.dayNumber);
        final wd = d.weekday;
        final hasMed = r.medSummary.contains('✓') ||
            r.medSummary.contains('✅') ||
            r.medSummary.toLowerCase().contains('diminum') ||
            r.medSummary.contains('1') ||
            r.medSummary.contains('2');
        final hasMeal = r.mealSummary.contains('✓') ||
            r.mealSummary.contains('✅') ||
            r.mealSummary.toLowerCase().contains('tercatat') ||
            r.mealSummary.contains('1') ||
            r.mealSummary.contains('2') ||
            r.mealSummary.contains('3');
        final score = r.moodLevel + (hasMed ? 0.5 : 0.0) + (hasMeal ? 0.5 : 0.0);
        weekdayScores.putIfAbsent(wd, () => []).add(score);
        weekdayMoods.putIfAbsent(wd, () => []).add(r.moodLevel);
      }

      final sortedWeekdays = weekdayScores.keys.toList()
        ..sort((a, b) {
          final avgA = weekdayScores[a]!.reduce((x, y) => x + y) / weekdayScores[a]!.length;
          final avgB = weekdayScores[b]!.reduce((x, y) => x + y) / weekdayScores[b]!.length;
          return avgB.compareTo(avgA);
        });

      String bestDaysText;
      double bestMoodAvg = summary.averageMood;
      if (sortedWeekdays.length >= 2) {
        final w1 = sortedWeekdays[0];
        final w2 = sortedWeekdays[1];
        bestDaysText = 'Hari ${_namaHariLengkap(w1)} & ${_namaHariLengkap(w2)} ';
        final combinedMoods = [...weekdayMoods[w1]!, ...weekdayMoods[w2]!];
        bestMoodAvg = combinedMoods.reduce((a, b) => a + b) / combinedMoods.length;
      } else if (sortedWeekdays.length == 1) {
        final w1 = sortedWeekdays[0];
        bestDaysText = 'Hari ${_namaHariLengkap(w1)} ';
        final moods = weekdayMoods[w1]!;
        bestMoodAvg = moods.reduce((a, b) => a + b) / moods.length;
      } else {
        bestDaysText = 'Bulan ${_namaBulan(sel.month)} ';
      }

      weekdayInsightSpans = [
        TextSpan(
          text: bestDaysText,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF512D38),
          ),
        ),
        TextSpan(
          text: 'mencatat tingkat ketenangan tertinggi (rata-rata mood ${bestMoodAvg.toStringAsFixed(1)}/5.0), didukung kepatuhan obat ',
        ),
        TextSpan(
          text: '${summary.medAdherencePercentage.round()}% ',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF512D38),
          ),
        ),
        const TextSpan(text: 'dan keteraturan makan '),
        TextSpan(
          text: '${summary.mealRegularityPercentage.round()}%.',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF512D38),
          ),
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 20,
                    color: Color(0xFF1D3958),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pola Teridentifikasi Bulan Ini',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.totalDaysRecorded} Hari Data',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF595D78),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Highlight 1: Korelasi Tidur & Mood Dinamis
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDEE0FF).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC1C4E5).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.hotel_rounded,
                  size: 18,
                  color: Color(0xFF1D3958),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF1C1B1D),
                      ),
                      children: sleepInsightSpans,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Highlight 2: Pola Hari Terbaik & Kepatuhan Rutinitas Dinamis
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD9E1).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEEB8C6).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.weekend_rounded,
                  size: 18,
                  color: Color(0xFF512D38),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF1C1B1D),
                      ),
                      children: weekdayInsightSpans,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Highlight 3: Dynamic Recovery Insight dari Provider
          if (summary.recoveryInsight.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDEF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBE7E9)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Color(0xFF1D3958),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      summary.recoveryInsight,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D3958),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. CONSULTATION SUMMARY CALLOUT BUTTON
  // ===========================================================================
  Widget _buildConsultationCalloutButton(
    BuildContext context,
    LumiProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RingkasanKonsultasiScreen(),
            ),
          );
        },
        icon: const Icon(Icons.stars_rounded, size: 20, color: Colors.white),
        label: const Text(
          'Lihat Ringkasan Konsultasi Dokter',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF355070), // primary-container
          elevation: 3,
          shadowColor: const Color(0xFF355070).withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 8. SUB-TAB TAHUNAN (TAHUN DINAMIS & KALENDER 12 BULAN)
  // ===========================================================================
  Widget _buildTahunanContent(LumiProvider provider, DateTime sel) {
    return Column(
      children: [
        // Year Navigation Pill
        _buildYearNavigationPill(provider, sel),

        const SizedBox(height: 14),

        // Sub-switcher Tab Tahunan
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EDEF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFEBE7E9).withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _subViewSwitchButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Year in Pixels',
                  isSelected: _tahunanViewMode == 0,
                  onTap: () => setState(() => _tahunanViewMode = 0),
                ),
              ),
              Expanded(
                child: _subViewSwitchButton(
                  icon: Icons.calendar_today_rounded,
                  label: 'Kalender 12 Bulan',
                  isSelected: _tahunanViewMode == 1,
                  onTap: () => setState(() => _tahunanViewMode = 1),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (_tahunanViewMode == 0)
          _buildYearInPixelsContent(provider)
        else
          _buildYearly12MonthsCalendarGrid(provider, sel),
      ],
    );
  }

  Widget _buildYearNavigationPill(LumiProvider provider, DateTime sel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 22,
              color: Color(0xFF595D78),
            ),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _changeYear(provider, -1),
          ),
          InkWell(
            onTap: () => _showMonthYearPickerModal(context, provider, sel),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Color(0xFF1D3958),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TAHUN ${sel.year}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20,
                    color: Color(0xFF595D78),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF595D78),
            ),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _changeYear(provider, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildYearly12MonthsCalendarGrid(LumiProvider provider, DateTime sel) {
    final grid = provider.yearInPixelsGrid;
    final mode = provider.pixelGridMode;

    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    const weekHeadersShort = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Column(
      children: [
        // Mode filter: Mood vs Tidur
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EDEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _modeFilterButton(
                  label: 'Pola Mood',
                  isSelected: mode == PixelGridColorMode.mood,
                  onTap: () => provider.setPixelGridMode(PixelGridColorMode.mood),
                ),
              ),
              Expanded(
                child: _modeFilterButton(
                  label: 'Kualitas Tidur',
                  isSelected: mode == PixelGridColorMode.sleepQuality,
                  onTap: () =>
                      provider.setPixelGridMode(PixelGridColorMode.sleepQuality),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Grid 12 Kartu Bulan (2 Kolom)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, mIdx) {
            final monthNum = mIdx + 1;
            final daysInM = DateUtils.getDaysInMonth(sel.year, monthNum);
            final firstDay = DateTime(sel.year, monthNum, 1);
            final startOff = firstDay.weekday - 1;
            final totalMonthCells = ((startOff + daysInM) / 7).ceil() * 7;
            final isCurrentMonth = (monthNum == provider.today.month && sel.year == provider.today.year);

            return InkWell(
              onTap: () {
                _setMonthAndYear(provider, sel.year, monthNum);
                setState(() => _activeTabIndex = 0);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentMonth
                        ? const Color(0xFF355070)
                        : const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                    width: isCurrentMonth ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF355070).withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthNames[mIdx],
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isCurrentMonth
                                ? const Color(0xFF1D3958)
                                : const Color(0xFF355070),
                          ),
                        ),
                        if (isCurrentMonth)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEE0FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Aktif',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF161A32),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: List.generate(7, (h) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              weekHeadersShort[h],
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF73777E),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 4),

                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalMonthCells,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemBuilder: (ctx, s) {
                          if (s < startOff || s >= startOff + daysInM) {
                            return const SizedBox.shrink();
                          }
                          final d = s - startOff; // 0..daysInM - 1
                          final cell = grid[mIdx][d];
                          final dayNumber = d + 1;
                          final isToday = DateUtils.isSameDay(
                            DateTime(sel.year, monthNum, dayNumber),
                            provider.today,
                          );

                          return Container(
                            decoration: BoxDecoration(
                              color: cell.getColor(mode),
                              borderRadius: BorderRadius.circular(2.5),
                              border: isToday
                                  ? Border.all(color: const Color(0xFF1D3958), width: 1.0)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        _buildColorLegend(mode),
      ],
    );
  }

  // ===========================================================================
  // 8. SUB-TAB TAHUNAN: YEAR IN PIXELS
  // ===========================================================================
  Widget _buildYearInPixelsContent(LumiProvider provider) {
    final grid = provider.yearInPixelsGrid;
    final mode = provider.pixelGridMode;

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return Column(
      children: [
        // Filter Switcher: Pola Mood vs Kualitas Tidur
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EDEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _modeFilterButton(
                  label: 'Pola Mood',
                  isSelected: mode == PixelGridColorMode.mood,
                  onTap: () => provider.setPixelGridMode(PixelGridColorMode.mood),
                ),
              ),
              Expanded(
                child: _modeFilterButton(
                  label: 'Kualitas Tidur',
                  isSelected: mode == PixelGridColorMode.sleepQuality,
                  onTap: () =>
                      provider.setPixelGridMode(PixelGridColorMode.sleepQuality),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Grid 2 Dimensi: 12 Kolom Bulan x 31 Baris Tanggal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF355070).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Bulan (Jan s/d Des)
              Row(
                children: [
                  const SizedBox(width: 24), // Ruang label tanggal
                  ...List.generate(12, (m) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          monthNames[m],
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 6),

              // Baris Tanggal 1 s/d 31
              ...List.generate(31, (dayIdx) {
                int dayNum = dayIdx + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          dayNum % 5 == 1 || dayNum == 31 ? '$dayNum' : '',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 8.5,
                            color: Color(0xFF73777E),
                          ),
                        ),
                      ),
                      ...List.generate(12, (monthIdx) {
                        final cell = grid[monthIdx][dayIdx];
                        return Expanded(
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: cell.getColor(mode),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Legenda Warna
        _buildColorLegend(mode),
      ],
    );
  }

  Widget _modeFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF1D3958)
                  : const Color(0xFF595D78),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorLegend(PixelGridColorMode mode) {
    List<Map<String, dynamic>> legends;

    if (mode == PixelGridColorMode.mood) {
      legends = [
        {'color': const Color(0xFF84A98C), 'label': 'Level 5 (Damai)'},
        {'color': const Color(0xFFE56B6F), 'label': 'Level 4 (Tenang)'},
        {'color': const Color(0xFFB56576), 'label': 'Level 3 (Biasa)'},
        {'color': const Color(0xFF6D597A), 'label': 'Level 2 (Lelah)'},
        {'color': const Color(0xFF355070), 'label': 'Level 1 (Berat)'},
      ];
    } else {
      legends = [
        {'color': SleepQuality.nyenyak.color, 'label': 'Nyenyak / Pulas'},
        {'color': SleepQuality.biasa.color, 'label': 'Biasa / Cukup'},
        {'color': SleepQuality.seringTerbangun.color, 'label': 'Sering Terbangun'},
        {'color': SleepQuality.insomnia.color, 'label': 'Susah (Insomnia)'},
        {'color': SleepQuality.hypersomnia.color, 'label': 'Tidur Berlebih (>10j)'},
      ];
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Warna:',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3958),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: legends.map((l) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: l['color'] as Color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10.5,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
