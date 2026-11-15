import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sleep_record.dart';
import '../../providers/lumi_provider.dart';

/// ============================================================================
/// MODAL CATAT TIDUR (MUNCUL DARI BAWAH SENDIRI SAAT KARTU TIDUR DITEKAN)
/// ============================================================================
/// 1. Handle bar & Header ('Catat Tidur')
/// 2. SECTION 1: Waktu Istirahat (Mulai Terlelap, Terbangun, Total Durasi)
/// 3. SECTION 2: Kualitas Tidur (Skala 5 turun ke 1, Level 1 Tidur Berlebihan)
/// 4. SECTION 3: Catatan / Alasan Singkat (Opsional)
/// 5. Footer Action: 'Simpan Jejak Tidur'
void showHariIniInputModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const CatatTidurModalSheet(),
  );
}

// Alias agar kompatibel dengan pemanggilan fungsi sebelumnya
void showCatatTidurModal(BuildContext context) =>
    showHariIniInputModal(context);

class CatatTidurModalSheet extends StatefulWidget {
  const CatatTidurModalSheet({super.key});

  @override
  State<CatatTidurModalSheet> createState() => _CatatTidurModalSheetState();
}

class _CatatTidurModalSheetState extends State<CatatTidurModalSheet> {
  // Waktu Mulai & Bangun Sesuai Desain (23:00 - 06:30)
  TimeOfDay _mulaiTidur = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _bangunPagi = const TimeOfDay(hour: 6, minute: 30);

  SleepQuality _selectedQuality = SleepQuality.nyenyak;
  late final TextEditingController _alasanController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<LumiProvider>();
    final currentSleep = provider.currentJejak.sleep;

    if (currentSleep.isRecorded) {
      _selectedQuality = currentSleep.kualitas;
      _alasanController = TextEditingController(text: currentSleep.alasan);
    } else {
      _alasanController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  double get _durasiJam {
    return SleepRecord.hitungDurasi(_mulaiTidur, _bangunPagi);
  }

  String get _durasiFormatted {
    final totalMinutes = (_durasiJam * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours Jam';
    }
    return '$hours Jam $minutes Menit';
  }

  String get _durasiCategory {
    if (_durasiJam >= 7.0 && _durasiJam <= 8.5) return 'Ideal & Segar';
    if (_durasiJam < 6.0) return 'Kurang';
    if (_durasiJam > 9.0) return 'Tidur Berlebihan';
    return 'Cukup';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h : $m';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _mulaiTidur : _bangunPagi;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'Pilih Jam Mulai Terlelap' : 'Pilih Jam Terbangun',
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _mulaiTidur = picked;
        } else {
          _bangunPagi = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x66D8A4B1), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x24355070),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber Handle Bar Area
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC3C6CE).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Modal Header: 'Catat Tidur'
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.nightlight_round,
                          size: 22,
                          color: Color(0xFF355070),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Catat Tidur',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Color(0xFF595D78),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E1E3)),

              // Scrollable Form Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: Waktu Istirahat (Jam)
                      _buildTimeSection(),
                      const SizedBox(height: 20),

                      // SECTION 2: Kualitas Tidur (Skala 5 turun ke 1)
                      _buildQualitySection(),
                      const SizedBox(height: 20),

                      // SECTION 3: Catatan / Alasan Singkat (Opsional)
                      const Text(
                        'Alasan / Catatan Tidur (Opsional)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _alasanController,
                        maxLines: 2,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.5,
                          color: Color(0xFF1C1B1D),
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: Suhu kamar dingin, minum teh hangat...',
                          hintStyle: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF73777E),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFCF8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: const Color(
                                0xFFC3C6CE,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: const Color(
                                0xFFC3C6CE,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF1C1B1D),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Action Footer ('Simpan Jejak Tidur')
              _buildFooterActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 1: Waktu Istirahat (Jam)
  // ===========================================================================
  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF1D3958)),
            SizedBox(width: 8),
            Text(
              'Waktu Istirahat (Jam)',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3958),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Mulai Terlelap
            Expanded(
              child: InkWell(
                onTap: () => _pickTime(isStart: true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC3C6CE).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mulai Terlelap',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF595D78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.bedtime_outlined,
                            size: 18,
                            color: Color(0xFF595D78),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_mulaiTidur),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Terbangun
            Expanded(
              child: InkWell(
                onTap: () => _pickTime(isStart: false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC3C6CE).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terbangun',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF595D78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny_outlined,
                            size: 18,
                            color: Color(0xFF595D78),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_bangunPagi),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Highlighted Total Duration Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EDEF).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD8A4B1).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: Color(0xFF1D3958),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Istirahat: $_durasiFormatted',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF355070),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _durasiCategory,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION 2: Kualitas Tidur (5 Tingkat: Level 5 turun ke Level 1)
  // ===========================================================================
  Widget _buildQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.star_outline_rounded,
              size: 18,
              color: Color(0xFF1D3958),
            ),
            SizedBox(width: 8),
            Text(
              'Kualitas Tidur Semalam',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3958),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List 5 Kualitas Tidur (Skala 5 turun ke 1)
        Column(
          children: SleepQuality.values.map((q) {
            final isSelected = _selectedQuality == q;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => setState(() => _selectedQuality = q),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFFBF8FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF355070)
                          : const Color(0xFFE5E1E3),
                      width: isSelected ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF355070)
                              : const Color(0xFFE5E1E3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${q.level}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF595D78),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q.label,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF1D3958)
                                : const Color(0xFF1D3958),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: Color(0xFF355070),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===========================================================================
  // Action Footer: Simpan Jejak Tidur
  // ===========================================================================
  Widget _buildFooterActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E1E3).withValues(alpha: 0.7),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            final provider = context.read<LumiProvider>();
            provider.saveSleepRecord(
              jamMulai: _formatTime(_mulaiTidur).replaceAll(' ', ''),
              jamBangun: _formatTime(_bangunPagi).replaceAll(' ', ''),
              durasiJam: _durasiJam,
              kualitas: _selectedQuality,
              alasan: _alasanController.text.trim(),
            );

            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jejak tidur berhasil disimpan.'),
                backgroundColor: Color(0xFF355070),
              ),
            );
          },
          icon: const Icon(Icons.check_rounded, size: 20, color: Colors.white),
          label: const Text(
            'Simpan Jejak Tidur',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF355070),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );
  }
}
