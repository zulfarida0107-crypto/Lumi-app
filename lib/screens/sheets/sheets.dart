import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';

/// ============================================================================
/// LAYAR TAB 4: CHART (VISUALISASI BAR CHART & TREN DINAMIS)
/// ============================================================================
/// Menampilkan grafik batang (Bar Chart) yang 100% dinamis mengikuti data
/// yang dimasukkan pengguna pada LumiProvider:
/// 1. Header & Navigasi Bulan/Tahun Dinamis + Ringkasan Cepat
/// 2. Bar Chart 1: Durasi Tidur & Suasana Hati Harian (dengan filter Minggu)
/// 3. Bar Chart 2: Kepatuhan Rutinitas per Waktu (Obat vs Makan: Pagi, Siang, Malam)
/// 4. Bar Chart 3: Frekuensi Level Suasana Hati (Level 1 Berat s/d 5 Damai)
/// 5. Bar Chart 4: Distribusi Kualitas Tidur Bulanan
class SheetsScreen extends StatefulWidget {
  const SheetsScreen({super.key});

  @override
  State<SheetsScreen> createState() => _SheetsScreenState();
}

class _SheetsScreenState extends State<SheetsScreen> {
  /// Filter rentang hari untuk Bar Chart Harian:
  /// 0 = Minggu 1 (1-7), 1 = Minggu 2 (8-14), 2 = Minggu 3 (15-21), 3 = Minggu 4+ (22-akhir), 4 = Sebulan Penuh
  int _selectedWeekFilter = 1; // Default Minggu 2 (mengikuti tanggal 11-15)
  int? _selectedBarDay;

  static String _namaBulan(int month) {
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

  static String _namaBulanShort(int month) {
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

  static Color _moodColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF355070); // 1 Berat
      case 2:
        return const Color(0xFF6D597A); // 2 Lelah
      case 3:
        return const Color(0xFFB56576); // 3 Biasa
      case 4:
        return const Color(0xFFE56B6F); // 4 Tenang
      case 5:
        return const Color(0xFF84A98C); // 5 Damai
      default:
        return const Color(0xFFC3C6CE);
    }
  }

  static String _moodLabelShort(int level) {
    switch (level) {
      case 1:
        return '1 Berat';
      case 2:
        return '2 Lelah';
      case 3:
        return '3 Biasa';
      case 4:
        return '4 Tenang';
      case 5:
        return '5 Damai';
      default:
        return '-';
    }
  }

  void _changeMonth(LumiProvider provider, DateTime current, int deltaMonths) {
    final target = DateTime(current.year, current.month + deltaMonths, 1);
    final maxDays = DateUtils.getDaysInMonth(target.year, target.month);
    final newDay = current.day.clamp(1, maxDays);
    final nextDate = DateTime(target.year, target.month, newDay);

    setState(() {
      _selectedBarDay = null;
    });
    provider.loadDataForDate(nextDate);
    provider.loadMonthlyData(nextDate.year, nextDate.month);
    provider.loadYearlyData(nextDate.year);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LumiProvider>();
    final sel = provider.selectedDate;
    final summary = provider.currentMonthlySummary;
    final logs = provider.monthlyLogs;
    final daysInMonth = DateUtils.getDaysInMonth(sel.year, sel.month);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              // 1. Header & Month Selector
              _buildHeaderSection(provider, sel, summary, daysInMonth),

              const SizedBox(height: 16),

              // 2. Bar Chart 1: Durasi Tidur & Mood Harian
              _buildDailySleepAndMoodBarChart(
                provider,
                sel,
                logs,
                daysInMonth,
              ),

              const SizedBox(height: 16),

              // 3. Bar Chart 2: Kepatuhan Rutinitas Pagi, Siang, Malam (Obat vs Makan)
              _buildRoutineTimeSlotBarChart(logs),

              const SizedBox(height: 16),

              // 4. Bar Chart 3: Frekuensi Level Suasana Hati (Level 1 - 5)
              _buildMoodFrequencyBarChart(summary, logs),

              const SizedBox(height: 16),

              // 5. Bar Chart 4: Distribusi Kualitas Tidur
              _buildSleepQualityBarChart(logs),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER & NAVIGASI BULAN + RINGKASAN CEPAT
  // ===========================================================================
  Widget _buildHeaderSection(
    LumiProvider provider,
    DateTime sel,
    MonthlySummary summary,
    int daysInMonth,
  ) {
    final totalDays = provider.monthlyLogs.length;
    final sleepLogs = provider.monthlyLogs
        .where((l) => l.sleep.isRecorded && l.sleep.durasiJam > 0)
        .toList();
    final avgSleep = sleepLogs.isEmpty
        ? 0.0
        : sleepLogs.fold<double>(0.0, (s, l) => s + l.sleep.durasiJam) /
            sleepLogs.length;
    final avgMood = totalDays == 0 ? 0.0 : summary.averageMood;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.3),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Visualisasi Grafik & Tren',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D3958),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Bar chart dinamis dari catatan harianmu',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ],
                ),
              ),
              // Pemilih Bulan Cepat
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F2F4),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFEBE7E9)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 28, minHeight: 28),
                      color: const Color(0xFF1D3958),
                      onPressed: () => _changeMonth(provider, sel, -1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${_namaBulanShort(sel.month)} ${sel.year}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 28, minHeight: 28),
                      color: const Color(0xFF1D3958),
                      onPressed: () => _changeMonth(provider, sel, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3 Mini Stat Pills
          Row(
            children: [
              Expanded(
                child: _buildMiniStatBox(
                  label: 'Hari Tercatat',
                  value: '$totalDays/$daysInMonth',
                  unit: 'hr',
                  icon: Icons.calendar_today_rounded,
                  bgColor: const Color(0xFFF6F2F4),
                  iconColor: const Color(0xFF1D3958),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatBox(
                  label: 'Rata-rata Mood',
                  value: totalDays > 0 ? avgMood.toStringAsFixed(1) : '-',
                  unit: totalDays > 0 ? '/5.0' : '',
                  icon: Icons.mood_rounded,
                  bgColor: const Color(0xFFFFD9E1).withValues(alpha: 0.45),
                  iconColor: const Color(0xFF512D38),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatBox(
                  label: 'Rata-rata Tidur',
                  value: sleepLogs.isNotEmpty
                      ? avgSleep.toStringAsFixed(1)
                      : '-',
                  unit: sleepLogs.isNotEmpty ? 'jam' : '',
                  icon: Icons.bedtime_rounded,
                  bgColor: const Color(0xFFDEE0FF).withValues(alpha: 0.5),
                  iconColor: const Color(0xFF1D3958),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF595D78),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D3958),
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF595D78),
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
  // 2. BAR CHART 1: DURASI TIDUR & SUASANA HATI HARIAN (DENGAN FILTER MINGGU)
  // ===========================================================================
  Widget _buildDailySleepAndMoodBarChart(
    LumiProvider provider,
    DateTime sel,
    List<DailyJejak> logs,
    int daysInMonth,
  ) {
    final Map<int, DailyJejak> logByDay = {};
    for (final l in logs) {
      final parsed = DateTime.tryParse(l.date);
      if (parsed != null) {
        logByDay[parsed.day] = l;
      }
    }

    int startDay = 1;
    int endDay = daysInMonth;
    if (_selectedWeekFilter == 0) {
      startDay = 1;
      endDay = 7;
    } else if (_selectedWeekFilter == 1) {
      startDay = 8;
      endDay = 14;
    } else if (_selectedWeekFilter == 2) {
      startDay = 15;
      endDay = 21;
    } else if (_selectedWeekFilter == 3) {
      startDay = 22;
      endDay = daysInMonth;
    }

    final visibleDays = <int>[
      for (int d = startDay; d <= endDay; d++) d,
    ];

    final selectedLog =
        _selectedBarDay != null ? logByDay[_selectedBarDay!] : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.25),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 19,
                          color: Color(0xFF1D3958),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Bar Chart Jam Tidur & Mood Harian',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tinggi batang = jam tidur · Warna batang = level mood (ketuk batang untuk detail)',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter Minggu Kapsul
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWeekFilterChip(0, 'Minggu 1 (1-7)'),
                const SizedBox(width: 6),
                _buildWeekFilterChip(1, 'Minggu 2 (8-14)'),
                const SizedBox(width: 6),
                _buildWeekFilterChip(2, 'Minggu 3 (15-21)'),
                const SizedBox(width: 6),
                _buildWeekFilterChip(3, 'Minggu 4 (22-$daysInMonth)'),
                const SizedBox(width: 6),
                _buildWeekFilterChip(4, 'Sebulan Penuh'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Area Bar Chart Vertikal
          Container(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF8FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEBE7E9)),
            ),
            child: Column(
              children: [
                // Info garis referensi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Skala: 0 - 10 Jam',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF73777E),
                      ),
                    ),
                    Text(
                      'Target Ideal: 7.0 - 8.0 Jam',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF355070),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 165,
                  child: _selectedWeekFilter == 4
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: visibleDays.map((d) {
                              return SizedBox(
                                width: 28,
                                child: _buildSingleDayBar(
                                  dayNum: d,
                                  log: logByDay[d],
                                  isSelected: _selectedBarDay == d,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: visibleDays.map((d) {
                            return Expanded(
                              child: _buildSingleDayBar(
                                dayNum: d,
                                log: logByDay[d],
                                isSelected: _selectedBarDay == d,
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),

          // Detail Bar yang Diketuk
          if (_selectedBarDay != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2F4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEBE7E9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: selectedLog != null
                          ? _moodColor(selectedLog.moodLevel)
                          : const Color(0xFFC3C6CE),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_selectedBarDay',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: selectedLog == null
                        ? Text(
                            'Tanggal $_selectedBarDay ${_namaBulan(sel.month)} ${sel.year}: - (Belum ada data masuk)',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF595D78),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tgl $_selectedBarDay ${_namaBulanShort(sel.month)} · Mood ${_moodLabelShort(selectedLog.moodLevel)} · Tidur ${selectedLog.sleep.isRecorded && selectedLog.sleep.durasiJam > 0 ? '${selectedLog.sleep.durasiJam.toStringAsFixed(1)} jam (${selectedLog.sleep.kualitas.label})' : '-'}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedLog.feelingsNote.trim().isNotEmpty
                                    ? '“${selectedLog.feelingsNote}”'
                                    : 'Obat: ${selectedLog.medications.any((m) => m.isCompleted || m.isSkipped) ? selectedLog.ringkasanObatTeks : '-'} · Makan: ${selectedLog.meals.any((m) => m.isCompleted || m.isSkipped) ? selectedLog.ringkasanMakanTeks : '-'}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  color: Color(0xFF595D78),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Legenda Warna Mood
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (int lvl = 1; lvl <= 5; lvl++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _moodColor(lvl),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _moodLabelShort(lvl),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekFilterChip(int index, String label) {
    final isSelected = _selectedWeekFilter == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWeekFilter = index;
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D3958) : const Color(0xFFF1EDEF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF595D78),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleDayBar({
    required int dayNum,
    required DailyJejak? log,
    required bool isSelected,
  }) {
    final bool hasData = log != null;
    final double sleepHours =
        (log != null && log.sleep.isRecorded && log.sleep.durasiJam > 0)
            ? log.sleep.durasiJam
            : 0.0;
    // Maksimal 10 jam = 110 px tinggi bar; jika sudah ada data mood tapi belum catat jam tidur, beri tinggi minimal 18 px
    final double barHeight = !hasData
        ? 6.0
        : (sleepHours > 0
            ? ((sleepHours / 10.0).clamp(0.12, 1.0) * 110.0)
            : 18.0);

    final Color barColor =
        hasData ? _moodColor(log.moodLevel) : const Color(0xFFE2DEE0);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBarDay = dayNum;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              sleepHours > 0
                  ? '${sleepHours.toStringAsFixed(1)}j'
                  : (hasData ? 'M${log.moodLevel}' : '-'),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: hasData
                    ? const Color(0xFF1D3958)
                    : const Color(0xFFB0B3BC),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: barHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(4),
                ),
                border: isSelected
                    ? Border.all(color: const Color(0xFF1D3958), width: 2)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1D3958)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$dayNum',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF595D78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. BAR CHART 2: KEPATUHAN RUTINITAS PER WAKTU (OBAT VS MAKAN: PAGI/SIANG/MALAM)
  // ===========================================================================
  Widget _buildRoutineTimeSlotBarChart(List<DailyJejak> logs) {
    final totalRecordedDays = logs.length;

    int countSlotDone(bool isMed, String slotKey) {
      int count = 0;
      for (final l in logs) {
        final list = isMed ? l.medications : l.meals;
        if (list.any((m) => m.id.contains(slotKey) && m.isCompleted)) {
          count++;
        }
      }
      return count;
    }

    final medPagi = countSlotDone(true, 'pagi');
    final medSiang = countSlotDone(true, 'siang');
    final medMalam = countSlotDone(true, 'malam');

    final mealPagi = countSlotDone(false, 'pagi');
    final mealSiang = countSlotDone(false, 'siang');
    final mealMalam = countSlotDone(false, 'malam');

    int pct(int count) =>
        totalRecordedDays > 0 ? ((count / totalRecordedDays) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.25),
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
            children: const [
              Icon(
                Icons.equalizer_rounded,
                size: 19,
                color: Color(0xFF1D3958),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bar Chart Rutinitas: Obat vs Makan',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            totalRecordedDays > 0
                ? 'Perbandingan pemenuhan jadwal Pagi, Siang, dan Malam dari $totalRecordedDays hari tercatat'
                : 'Belum ada data rutinitas obat & makan yang dicatat bulan ini (-)',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: Color(0xFF595D78),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF8FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEBE7E9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildGroupedSlotBars(
                    slotLabel: 'Pagi',
                    medCount: medPagi,
                    medPct: pct(medPagi),
                    mealCount: mealPagi,
                    mealPct: pct(mealPagi),
                    hasAnyData: totalRecordedDays > 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGroupedSlotBars(
                    slotLabel: 'Siang',
                    medCount: medSiang,
                    medPct: pct(medSiang),
                    mealCount: mealSiang,
                    mealPct: pct(mealSiang),
                    hasAnyData: totalRecordedDays > 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGroupedSlotBars(
                    slotLabel: 'Malam',
                    medCount: medMalam,
                    medPct: pct(medMalam),
                    mealCount: mealMalam,
                    mealPct: pct(mealMalam),
                    hasAnyData: totalRecordedDays > 0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendBadge(
                color: const Color(0xFF355070),
                label: 'Minum Obat',
              ),
              const SizedBox(width: 18),
              _buildLegendBadge(
                color: const Color(0xFFB56576),
                label: 'Jadwal Makan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSlotBars({
    required String slotLabel,
    required int medCount,
    required int medPct,
    required int mealCount,
    required int mealPct,
    required bool hasAnyData,
  }) {
    final double medHeight =
        !hasAnyData ? 6.0 : ((medPct / 100.0).clamp(0.06, 1.0) * 105.0);
    final double mealHeight =
        !hasAnyData ? 6.0 : ((mealPct / 100.0).clamp(0.06, 1.0) * 105.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 135,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bar Obat
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      hasAnyData ? '$medPct%' : '-',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF355070),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: medHeight,
                      decoration: BoxDecoration(
                        color: hasAnyData
                            ? const Color(0xFF355070)
                            : const Color(0xFFE2DEE0),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                          bottom: Radius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Bar Makan
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      hasAnyData ? '$mealPct%' : '-',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF512D38),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: mealHeight,
                      decoration: BoxDecoration(
                        color: hasAnyData
                            ? const Color(0xFFB56576)
                            : const Color(0xFFE2DEE0),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                          bottom: Radius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slotLabel,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        Text(
          hasAnyData ? 'Obat ${medCount}hr · Makan ${mealCount}hr' : '-',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 9.5,
            color: Color(0xFF595D78),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendBadge({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D3958),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. BAR CHART 3: FREKUENSI LEVEL SUASANA HATI (LEVEL 1 S/D 5)
  // ===========================================================================
  Widget _buildMoodFrequencyBarChart(
    MonthlySummary summary,
    List<DailyJejak> logs,
  ) {
    final total = logs.length;
    final counts = {
      1: summary.moodDistribution[1] ?? 0,
      2: summary.moodDistribution[2] ?? 0,
      3: summary.moodDistribution[3] ?? 0,
      4: summary.moodDistribution[4] ?? 0,
      5: summary.moodDistribution[5] ?? 0,
    };
    final maxCount = counts.values.fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.25),
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
            children: const [
              Icon(
                Icons.insert_chart_outlined_rounded,
                size: 19,
                color: Color(0xFF1D3958),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bar Chart Frekuensi Suasana Hati',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            total > 0
                ? 'Jumlah hari pada tiap tingkatan afek dari $total hari tercatat'
                : 'Belum ada data suasana hati tercatat bulan ini (-)',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: Color(0xFF595D78),
            ),
          ),
          const SizedBox(height: 14),

          ...List.generate(5, (idx) {
            final level = 5 - idx; // Urut dari 5 Damai ke 1 Berat
            final count = counts[level] ?? 0;
            final pct = total > 0 ? ((count / total) * 100).round() : 0;
            final ratio = total > 0 && count > 0 ? (count / maxCount) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _moodLabelShort(level),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      Text(
                        total > 0 ? '$count Hari ($pct%)' : '-',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      color: const Color(0xFFF1EDEF),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ratio.clamp(0.0, 1.0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: _moodColor(level),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. BAR CHART 4: DISTRIBUSI KUALITAS TIDUR BULANAN
  // ===========================================================================
  Widget _buildSleepQualityBarChart(List<DailyJejak> logs) {
    final sleepLogs =
        logs.where((l) => l.sleep.isRecorded && l.sleep.durasiJam > 0).toList();
    final totalSleepDays = sleepLogs.length;

    final Map<SleepQuality, int> qualityCounts = {
      for (final q in SleepQuality.values) q: 0,
    };
    for (final l in sleepLogs) {
      qualityCounts[l.sleep.kualitas] =
          (qualityCounts[l.sleep.kualitas] ?? 0) + 1;
    }

    final maxQ = qualityCounts.values.fold<int>(1, (a, b) => a > b ? a : b);

    final items = [
      (SleepQuality.nyenyak, 'Tidur Pulas', const Color(0xFF355070)),
      (SleepQuality.biasa, 'Tidur Biasa', const Color(0xFF595D78)),
      (SleepQuality.seringTerbangun, 'Sering Terbangun', const Color(0xFFB56576)),
      (SleepQuality.insomnia, 'Susah Tidur / Insomnia', const Color(0xFFBA1A1A)),
      (SleepQuality.hypersomnia, 'Tidur Berlebih', const Color(0xFF6D597A)),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.25),
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
            children: const [
              Icon(
                Icons.nights_stay_rounded,
                size: 19,
                color: Color(0xFF1D3958),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bar Chart Kualitas Tidur',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            totalSleepDays > 0
                ? 'Rincian kualitas tidur dari $totalSleepDays malam yang dicatat'
                : 'Belum ada data kualitas tidur tercatat bulan ini (-)',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: Color(0xFF595D78),
            ),
          ),
          const SizedBox(height: 14),

          ...items.map((entry) {
            final q = entry.$1;
            final label = entry.$2;
            final color = entry.$3;
            final count = qualityCounts[q] ?? 0;
            final pct = totalSleepDays > 0
                ? ((count / totalSleepDays) * 100).round()
                : 0;
            final ratio =
                totalSleepDays > 0 && count > 0 ? (count / maxQ) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      Text(
                        totalSleepDays > 0 ? '$count Malam ($pct%)' : '-',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 11,
                      width: double.infinity,
                      color: const Color(0xFFF1EDEF),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ratio.clamp(0.0, 1.0),
                        child: Container(
                          height: 11,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
