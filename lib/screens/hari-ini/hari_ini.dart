import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';
import 'catat_tidur_modal.dart';
import 'routine_input_modal.dart';
import 'mood_input_modal.dart';

/// ============================================================================
/// LAYAR TAB 1: HARI INI (Dinamis, Real-Time WIB, Reset Otomatis 00:00)
/// ============================================================================
/// 1. Kalender: Tanggal & hari elegan, pemilih tanggal lengkap, & strip mingguan geser
/// 2. Grid JEJAK HARI INI: 4 kartu dinamis (Obat, Makan, Tidur, Mood)
/// 3. Jadwal & Riwayat: ✓ sudah / ✗ silang (lembut & feminim) + popup input obat & makan
class HariIniScreen extends StatelessWidget {
  const HariIniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LumiProvider>();
    final jejak = provider.currentJejak;

    return Container(
      color: const Color(0xFFFBF8FA),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarCard(context, provider),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildJejakHariIniGrid(context, jejak),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildTimelineSection(context, provider, jejak),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. KALENDER (Header Tanggal Elegan + Strip Mingguan Geser Kanan-Kiri)
  // ===========================================================================
  Widget _buildCalendarCard(BuildContext context, LumiProvider provider) {
    final sel = provider.selectedDate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 24, color: Color(0xFF595D78)),
                onPressed: () => provider.loadDataForDate(sel.subtract(const Duration(days: 1))),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              InkWell(
                onTap: () => _pickFullDate(context, provider),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 15, color: Color(0xFF355070)),
                      const SizedBox(width: 8),
                      Text(
                        '${_namaHariLengkap(sel.weekday)}, ${sel.day} ${_namaBulan(sel.month)} ${sel.year}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF595D78)),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFF595D78)),
                onPressed: () => provider.loadDataForDate(sel.add(const Duration(days: 1))),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WeekStrip(
            selected: sel,
            today: provider.today,
            onSelect: provider.loadDataForDate,
          ),
          const SizedBox(height: 4),
          const Text(
            'Geser kiri / kanan untuk pindah minggu',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: Color(0xFF73777E),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFullDate(BuildContext context, LumiProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2099, 12, 31),
      helpText: 'Pilih Tanggal Jejak',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) provider.loadDataForDate(picked);
  }

  // ===========================================================================
  // 2. GRID JEJAK HARI INI (4 KARTU DINAMIS, RESET TIAP HARI BARU)
  // ===========================================================================
  Widget _buildJejakHariIniGrid(BuildContext context, DailyJejak jejak) {
    // Obat
    final doneMeds = jejak.medications
        .where((m) => m.isCompleted)
        .map((m) => m.title.replaceFirst('Obat ', ''))
        .toList();
    String medsSubtitle;
    if (doneMeds.isNotEmpty) {
      medsSubtitle = '${doneMeds.join(' & ')} diminum';
    } else {
      medsSubtitle = 'Belum diminum';
    }

    // Makan
    final doneMeals = jejak.meals
        .where((m) => m.isCompleted)
        .map((m) => m.title.replaceFirst('Makan ', ''))
        .toList();
    String mealsSubtitle;
    if (doneMeals.isNotEmpty) {
      mealsSubtitle = doneMeals.join(' & ');
    } else {
      mealsSubtitle = 'Belum dicatat';
    }

    // Tidur
    final sleep = jejak.sleep;
    final sleepTitle = sleep.isRecorded ? '${sleep.durasiJam.toStringAsFixed(1)}j Tidur' : 'Tidur';
    final sleepSubtitle = sleep.isRecorded
        ? (sleep.alasan.isNotEmpty ? sleep.alasan : sleep.kualitas.label)
        : 'Belum dicatat';

    // Mood (Sesuai Gambar 1 & Gambar 2)
    const moodNames = ['', 'Berat', 'Cemas', 'Tenang', 'Lega', 'Hangat'];
    final mName = jejak.moodLevel >= 1 && jejak.moodLevel <= 5 ? moodNames[jejak.moodLevel] : 'Tenang';
    final energyStr = jejak.energyLevel == 'penuh'
        ? 'Energi Penuh'
        : (jejak.energyLevel == 'cukup' ? 'Energi Cukup' : 'Energi Rendah');
    final moodTitle = 'Mood: $mName';
    final moodSubtitle = 'Skala ${jejak.moodLevel}/5 • $energyStr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'JEJAK HARI INI',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFF595D78),
              ),
            ),
            Text(
              'Ringkasan Otomatis',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: Color(0xFF595D78),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildJejakCard(
              icon: Icons.medication_rounded,
              bgColor: const Color(0xFFE0F7F6), // Tosca
              iconColor: const Color(0xFF00897B),
              title: 'Obat',
              subtitle: medsSubtitle,
              onTap: () => showRoutineInputModal(context, type: RoutineType.obat),
            ),
            const SizedBox(width: 8),
            _buildJejakCard(
              icon: Icons.restaurant_rounded,
              bgColor: const Color(0xFFFFE4E8), // Pink
              iconColor: const Color(0xFFD81B60),
              title: 'Makan',
              subtitle: mealsSubtitle,
              onTap: () => showRoutineInputModal(context, type: RoutineType.makan),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildJejakCard(
              icon: Icons.nightlight_round,
              bgColor: const Color(0xFF355070), // Dusty Indigo
              iconColor: Colors.white,
              title: sleepTitle,
              subtitle: sleepSubtitle,
              onTap: () => showHariIniInputModal(context),
            ),
            const SizedBox(width: 8),
            _buildJejakCard(
              icon: Icons.cloud_rounded,
              bgColor: const Color(0xFFFFD9E1),
              iconColor: const Color(0xFF30111B),
              title: moodTitle,
              subtitle: moodSubtitle,
              onTap: () => showMoodAndEnergyModal(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJejakCard({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF355070).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3958),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: Color(0xFF595D78),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. TIMELINE JADWAL & RIWAYAT (Menyesuaikan warna grid, hanya muncul jika manual)
  // ===========================================================================
  Widget _buildTimelineSection(BuildContext context, LumiProvider provider, DailyJejak jejak) {
    final List<Widget> timelineChildren = [];

    // 1. Tidur (Hanya muncul jika dicatat secara manual)
    if (jejak.sleep.isRecorded) {
      timelineChildren.add(
        _timelineItem(
          nodeColor: const Color(0xFF355070), // Dusty Indigo
          child: _bangunTidurCard(context, provider, jejak.sleep),
        ),
      );
    }

    // 2. Rutinitas Obat & Makan (Hanya yang dicatat/diselesaikan secara manual)
    final completedMeals = jejak.meals.where((m) => m.isCompleted || m.isSkipped).toList();
    final completedMeds = jejak.medications.where((m) => m.isCompleted || m.isSkipped).toList();

    final List<RoutineItem> activeRoutines = [...completedMeals, ...completedMeds];

    int phaseOrder(RoutineItem r) {
      if (r.id.contains('pagi')) return 1;
      if (r.id.contains('siang')) return 2;
      if (r.id.contains('malam')) return 3;
      return 4;
    }

    activeRoutines.sort((a, b) {
      final pA = phaseOrder(a);
      final pB = phaseOrder(b);
      if (pA != pB) return pA.compareTo(pB);
      if (a.type != b.type) {
        return a.type == RoutineType.makan ? -1 : 1;
      }
      return a.id.compareTo(b.id);
    });

    for (int i = 0; i < activeRoutines.length; i++) {
      final item = activeRoutines[i];
      final isLast = (i == activeRoutines.length - 1);
      final isObat = item.type == RoutineType.obat;
      // Warna Obat: Tosca, Warna Makan: Pink
      final nodeColor = isObat ? const Color(0xFF00897B) : const Color(0xFFD81B60);

      String defaultTime;
      if (item.id.contains('pagi')) {
        defaultTime = isObat ? '08:20' : '08:00';
      } else if (item.id.contains('siang')) {
        defaultTime = isObat ? '14:00' : '13:00';
      } else {
        defaultTime = isObat ? '21:00' : '19:00';
      }

      timelineChildren.add(
        _timelineItem(
          nodeColor: nodeColor,
          isLast: isLast,
          child: _routineCard(
            context: context,
            provider: provider,
            item: item,
            time: defaultTime,
            title: item.title,
            subtitle: item.note.isNotEmpty
                ? item.note
                : (isObat ? 'Catatan obat' : 'Catatan makan'),
            doneLabel: isObat ? 'Diminum' : 'Tercatat',
            accentColor: nodeColor,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'JADWAL & RIWAYAT HARI INI',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFF595D78),
              ),
            ),
            Text(
              'Aktivitas Manual',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: Color(0xFF595D78),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (timelineChildren.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF355070).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: const [
                Icon(Icons.spa_outlined, size: 32, color: Color(0xFFC3C6CE)),
                SizedBox(height: 8),
                Text(
                  'Belum Ada Riwayat Tercatat',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Riwayat aktivitas akan otomatis muncul di sini setelah kamu mencatat tidur, obat, atau makan di atas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: Color(0xFF73777E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          ...timelineChildren,
      ],
    );
  }

  Widget _bangunTidurCard(BuildContext context, LumiProvider provider, SleepRecord sleep) {
    final recorded = sleep.isRecorded;
    final durasiLabel =
        '${sleep.jamMulai} - ${sleep.jamBangun} (${sleep.durasiJam.toStringAsFixed(1)} Jam)';

    return InkWell(
      onTap: () => showHariIniInputModal(context),
      borderRadius: BorderRadius.circular(16),
      child: _baseCard(
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF355070),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tidur',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            recorded ? sleep.jamBangun : '07:00',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A4E69),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Bangun Tidur',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D3958),
                          decoration: sleep.isSkipped ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusButtons(
                  done: sleep.isRecorded,
                  skipped: sleep.isSkipped,
                  onDone: provider.toggleSleepDone,
                  onSkip: provider.toggleSleepSkipped,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recorded) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _smallChip(Icons.schedule, durasiLabel, const Color(0xFFF1EDEF), const Color(0xFF595D78)),
                  _smallChip(Icons.circle, sleep.kualitas.label, const Color(0xFFFEF3C7), const Color(0xFF73510D), isDot: true),
                  if (sleep.catatanJam.isNotEmpty)
                    _smallChip(Icons.access_time_rounded, 'Catatan ${sleep.catatanJam}', const Color(0xFFFFE8EE), const Color(0xFF512D38)),
                ],
              ),
              if (sleep.alasan.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2F4).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '“${sleep.alasan}”',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ),
              ],
            ] else
              const Text(
                'Belum dicatat — ketuk untuk mengisi jejak tidur.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: Color(0xFF73777E),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _routineCard({
    required BuildContext context,
    required LumiProvider provider,
    required RoutineItem item,
    required String time,
    required String title,
    required String subtitle,
    required String doneLabel,
    Color? accentColor,
  }) {
    String status;
    if (item.isCompleted) {
      status = '$doneLabel ${item.completedTime ?? time} • ${item.note.isNotEmpty ? item.note : subtitle}';
    } else if (item.isSkipped) {
      status = 'Terlewat / tidak dilakukan';
    } else {
      status = item.note.isNotEmpty ? item.note : subtitle;
    }

    final isObat = item.type == RoutineType.obat;
    final tagLabel = isObat ? 'Obat' : 'Makan';
    final tagBg = isObat ? const Color(0xFFE0F7F6) : const Color(0xFFFFE4E8);
    final tagFg = accentColor ?? (isObat ? const Color(0xFF00897B) : const Color(0xFFD81B60));

    return InkWell(
      onTap: () => showRoutineInputModal(context, type: item.type, initialItem: item),
      borderRadius: BorderRadius.circular(16),
      child: _baseCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tagLabel,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tagFg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.completedTime ?? time,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D3958),
                      decoration: item.isSkipped ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _statusButtons(
              done: item.isCompleted,
              skipped: item.isSkipped,
              onDone: () => provider.toggleRoutineItem(item),
              onSkip: () => provider.toggleSkipRoutineItem(item),
            ),
          ],
        ),
      ),
    );
  }

  /// Dua tombol: ✓ (sudah) dan ✗ (silang). Desain lembut, simpel & feminim.
  Widget _statusButtons({
    required bool done,
    required bool skipped,
    required VoidCallback onDone,
    required VoidCallback onSkip,
  }) {
    Widget btn({
      required IconData icon,
      required bool active,
      required Color activeBg,
      required Color activeBorder,
      required Color activeFg,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? activeBg : const Color(0xFFFCF8FA),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? activeBorder : const Color(0xFFEADBDF),
              width: active ? 1.4 : 1.0,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: activeBorder.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 17,
            color: active ? activeFg : const Color(0xFFB0A8B0),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(
          icon: Icons.check_rounded,
          active: done,
          activeBg: const Color(0xFFE8F8F2),
          activeBorder: const Color(0xFFB5EAD7),
          activeFg: const Color(0xFF1D6B4F),
          onTap: onDone,
        ),
        const SizedBox(width: 8),
        btn(
          icon: Icons.close_rounded,
          active: skipped,
          activeBg: const Color(0xFFFFF0F3),
          activeBorder: const Color(0xFFF7CAD0),
          activeFg: const Color(0xFF8B4F58),
          onTap: onSkip,
        ),
      ],
    );
  }

  Widget _timelineItem({
    required Color nodeColor,
    required Widget child,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: nodeColor, width: 2.5),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFC3C6CE).withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _smallChip(IconData icon, String label, Color bg, Color textCol, {bool isDot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDot)
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(color: Color(0xFFEAB308), shape: BoxShape.circle),
            )
          else
            Icon(icon, size: 12, color: textCol),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPER NAMA HARI / BULAN
  // ===========================================================================
  static String _namaHariLengkap(int weekday) {
    const names = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return names[weekday];
  }

  static String _namaBulan(int month) {
    const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return bulan[month];
  }
}

/// ============================================================================
/// STRIP MINGGUAN: geser kiri/kanan antar minggu, ketuk untuk pilih hari
/// ============================================================================
class _WeekStrip extends StatefulWidget {
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip({
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  // Senin, 3 Januari 2000 sebagai jangkar halaman 0
  static final DateTime _anchor = DateTime.utc(2000, 1, 3);
  late final PageController _controller;

  int _pageFor(DateTime d) {
    final days = DateTime.utc(d.year, d.month, d.day).difference(_anchor).inDays;
    return (days / 7).floor();
  }

  DateTime _dateFor(int page, int dayIndex) {
    final d = _anchor.add(Duration(days: page * 7 + dayIndex));
    return DateTime(d.year, d.month, d.day);
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _pageFor(widget.selected));
  }

  @override
  void didUpdateWidget(covariant _WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _pageFor(widget.selected);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final current = _controller.page?.round() ?? target;
      if (current != target) {
        _controller.jumpToPage(target);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: PageView.builder(
        controller: _controller,
        itemCount: 5400, // ±100 tahun
        onPageChanged: (page) {
          if (_pageFor(widget.selected) == page) return;
          final sameWeekday = widget.selected.weekday - 1;
          widget.onSelect(_dateFor(page, sameWeekday));
        },
        itemBuilder: (context, page) {
          return Row(
            children: List.generate(7, (i) {
              final date = _dateFor(page, i);
              final isSelected = DateUtils.isSameDay(date, widget.selected);
              final isToday = DateUtils.isSameDay(date, widget.today);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => widget.onSelect(date),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2C3E55) : const Color(0xFFF6F2F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _hari[i],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : const Color(0xFF595D78),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF1C1B1D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isToday ? const Color(0xFFB5EAD7) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
