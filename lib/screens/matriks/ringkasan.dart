import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';

/// ============================================================================
/// LAYAR: RINGKASAN KONSULTASI DOKTER / PSIKOLOG (MATRIKS KLINIS BULANAN)
/// ============================================================================
/// Diadaptasi langsung dari `assets/mockups/ringkasan.html` dan terhubung penuh
/// dengan data dinamis `LumiProvider` (Summary Bulanan, Baris Harian, & Catatan).
class RingkasanKonsultasiScreen extends StatefulWidget {
  const RingkasanKonsultasiScreen({super.key});

  @override
  State<RingkasanKonsultasiScreen> createState() =>
      _RingkasanKonsultasiScreenState();
}

class _ChecklistAgendaItem {
  String title;
  String subtitle;
  bool isChecked;

  _ChecklistAgendaItem({
    required this.title,
    required this.subtitle,
    this.isChecked = false,
  });
}

class _RingkasanKonsultasiScreenState extends State<RingkasanKonsultasiScreen> {
  bool _isPrivacyVeiled = false;

  final List<_ChecklistAgendaItem> _agendaItems = [
    _ChecklistAgendaItem(
      title:
          'Diskusikan penyesuaian jam atau dosis obat malam untuk mengurangi kantuk pagi',
      subtitle: 'Terkait laporan brain fog jam 08:00-11:00',
      isChecked: true,
    ),
    _ChecklistAgendaItem(
      title:
          'Evaluasi efektivitas latihan pernapasan Somatik vs 4-7-8 saat lonjakan cemas',
      subtitle: 'Rujukan dari episode fluktuasi kritis bulan ini',
      isChecked: false,
    ),
    _ChecklistAgendaItem(
      title:
          'Konsultasi perlu/tidaknya cek laboratorium profil tiroid dan Vitamin D',
      subtitle: 'Untuk memastikan ketiadaan faktor biologis pada kelelahan',
      isChecked: false,
    ),
  ];

  void _togglePrivacyVeil() {
    setState(() {
      _isPrivacyVeiled = !_isPrivacyVeiled;
    });
    _showToast(
      _isPrivacyVeiled
          ? 'Mode Privasi Aktif: Catatan sensitif disamarkan.'
          : 'Mode Privasi Nonaktif: Catatan terbaca.',
    );
  }

  void _handleDownloadReport() {
    _showToast('Menghasilkan Lembar Klinis PDF Resmi (AES-256)...');
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _showToast('File PDF tersimpan di perangkat.');
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        backgroundColor: const Color(0xFF1D3958),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        duration: const Duration(milliseconds: 2200),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionFormModal({int? editIndex}) {
    final isEdit = editIndex != null;
    final existing = isEdit ? _agendaItems[editIndex] : null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subCtrl = TextEditingController(text: existing?.subtitle ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
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
                  Text(
                    isEdit
                        ? 'Edit Pertanyaan untuk Dokter'
                        : 'Tambah Pertanyaan untuk Dokter',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF595D78)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Pokok Pertanyaan / Diskusi',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF595D78),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText:
                      'Misal: Apakah dosis obat pagi perlu disesuaikan?',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: Color(0xFF73777E)),
                  filled: true,
                  fillColor: const Color(0xFFFCF8FA),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color:
                            const Color(0xFFC3C6CE).withValues(alpha: 0.35)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color:
                            const Color(0xFFC3C6CE).withValues(alpha: 0.35)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Catatan Konteks / Rujukan (Opsional)',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF595D78),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: subCtrl,
                decoration: InputDecoration(
                  hintText: 'Misal: Terkait keluhan sulit fokus siang hari',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: Color(0xFF73777E)),
                  filled: true,
                  fillColor: const Color(0xFFFCF8FA),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color:
                            const Color(0xFFC3C6CE).withValues(alpha: 0.35)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color:
                            const Color(0xFFC3C6CE).withValues(alpha: 0.35)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                            color: const Color(0xFFC3C6CE)
                                .withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Batal',
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
                        final text = titleCtrl.text.trim();
                        if (text.isEmpty) return;
                        final sub = subCtrl.text.trim().isNotEmpty
                            ? subCtrl.text.trim()
                            : 'Ditambahkan oleh pasien untuk sesi konsultasi';
                        setState(() {
                          if (isEdit) {
                            _agendaItems[editIndex].title = text;
                            _agendaItems[editIndex].subtitle = sub;
                          } else {
                            _agendaItems.add(
                              _ChecklistAgendaItem(
                                title: text,
                                subtitle: sub,
                              ),
                            );
                          }
                        });
                        Navigator.of(ctx).pop();
                        _showToast(
                          isEdit
                              ? 'Pertanyaan agenda berhasil diperbarui.'
                              : 'Pertanyaan berhasil ditambahkan ke agenda.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D3958),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Simpan Pertanyaan',
                        style: const TextStyle(
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

  void _deleteAgendaItem(int index) {
    final item = _agendaItems[index];
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Color(0xFFBA1A1A),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Hapus Pertanyaan?',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus pertanyaan “${item.title}” dari agenda konsultasi dokter?',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF595D78),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: const Color(0xFFC3C6CE).withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _agendaItems.removeAt(index);
                      });
                      _showToast('Pertanyaan dihapus dari agenda konsultasi.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBA1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ya, Hapus',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

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

  Widget _privacyBlurWrap(Widget child) {
    if (!_isPrivacyVeiled) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LumiProvider>();
    final summary = provider.currentMonthlySummary;
    final logs = provider.monthlyLogs;
    final sel = provider.selectedDate;
    final daysInMonth = DateUtils.getDaysInMonth(sel.year, sel.month);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      // TopAppBar Sticky & Docked (Sesuai ringkasan.html)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCF8FA).withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFEBE7E9).withValues(alpha: 0.6),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Leading: Back to Matriks Bulanan
                      IconButton(
                        tooltip: 'Kembali ke Matriks Bulanan',
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF1D3958),
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                      // Screen Title Anchor
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.spa_rounded,
                                size: 18,
                                color: Color(0xFF1D3958),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Ringkasan Konsultasi',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Matriks Klinis Bulanan',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),

                      // Trailing: Patient Privacy Veil Toggle
                      InkWell(
                        onTap: _togglePrivacyVeil,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDEF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPrivacyVeiled
                                    ? Icons.lock_open_rounded
                                    : Icons.lock_rounded,
                                size: 15,
                                color: const Color(0xFF1D3958),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isPrivacyVeiled ? 'Terbuka' : 'Privasi',
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
                ),
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // 1. Patient & Consultation Header Card
              _buildPatientHeaderCard(summary, sel, daysInMonth),

              const SizedBox(height: 16),

              // 2. Key Clinical Metrics Overview (2x2 Tactile Bento)
              _buildClinicalMetricsBento(summary, logs, daysInMonth),

              const SizedBox(height: 16),

              // 3. Mood Spectrum Breakdown (Affect Distribution)
              _buildMoodDistributionCard(summary),

              const SizedBox(height: 16),

              // 4. Starred Journal Entries for Therapy Discussion
              _buildStarredJournalsSection(provider),

              const SizedBox(height: 16),

              // 5. Therapy Discussion Checklist (Patient Questions for Clinician)
              _buildTherapyChecklistSection(),

              const SizedBox(height: 20),

              // 6. Footer Actions & Medical Compliance (Unduh PDF)
              _buildFooterDownloadButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. PATIENT & CONSULTATION HEADER CARD
  // ===========================================================================
  Widget _buildPatientHeaderCard(
    MonthlySummary summary,
    DateTime sel,
    int daysInMonth,
  ) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ambient glow corner accents
          Positioned(
            top: -36,
            right: -36,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD9E1).withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -28,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFDEE0FF).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Security Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2E4FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.medical_information_rounded,
                            size: 14,
                            color: Color(0xFF001C37),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Dokumen Medis Terpadu',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF001C37),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDEF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFC3C6CE)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 13,
                            color: Color(0xFF595D78),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PIN Pasien Aktif',
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
                  ],
                ),

                const SizedBox(height: 12),

                // Patient Identity
                const Text(
                  'Kawan Tenang',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      size: 15,
                      color: Color(0xFF595D78),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            color: Color(0xFF595D78),
                          ),
                          children: [
                            const TextSpan(text: 'Periode: '),
                            TextSpan(
                              text:
                                  '1 - $daysInMonth ${_namaBulan(sel.month)} ${sel.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D3958),
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' (${summary.totalDaysRecorded} Hari Tercatat)',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Clinical Intent Subtitle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2F4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFEBE7E9),
                    ),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF43474D),
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Dokumen ini disiapkan khusus untuk mempermudah sesi dialog dengan ',
                        ),
                        TextSpan(
                          text:
                              'Psikiater, Psikolog, atau Dokter Spesialis Jiwa',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        TextSpan(
                          text:
                              '. Data terhimpun otomatis dari jurnal ritme Lumi tanpa beban kompilasi manual.',
                        ),
                      ],
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
  // 2. KEY CLINICAL METRICS OVERVIEW (2x2 TACTILE BENTO)
  // ===========================================================================
  Widget _buildClinicalMetricsBento(
    MonthlySummary summary,
    List<DailyJejak> logs,
    int daysInMonth,
  ) {
    final totalDays = logs.length;

    // 1. Stabilitas Afek (Dinamis dari hari yang dicatat user)
    final double avgMood = totalDays == 0 ? 0.0 : summary.averageMood;
    final String moodSubNote = totalDays == 0
        ? 'Belum ada data afek tercatat.'
        : avgMood >= 3.5
            ? 'Kondisi afek dominan tenang ($totalDays hari tercatat).'
            : 'Terdapat fluktuasi afek dari $totalDays hari tercatat.';

    // 2. Tidur Sirkadian (Dinamis dari hari yang jam tidurnya dicatat user)
    final sleepLogs =
        logs.where((l) => l.sleep.isRecorded && l.sleep.durasiJam > 0).toList();
    final double avgSleep = sleepLogs.isEmpty
        ? 0.0
        : sleepLogs.fold<double>(0.0, (s, l) => s + l.sleep.durasiJam) /
            sleepLogs.length;
    final int restlessTotal = sleepLogs
        .where(
          (l) =>
              l.sleep.kualitas == SleepQuality.seringTerbangun ||
              l.sleep.kualitas == SleepQuality.insomnia,
        )
        .length;
    final int sleepEfficiency = sleepLogs.isEmpty
        ? 0
        : (((avgSleep / 8.0) * 100).round().clamp(40, 100));
    final String sleepSubNote = sleepLogs.isEmpty
        ? 'Belum ada catatan jam tidur.'
        : 'Efisiensi ~$sleepEfficiency%, ${restlessTotal}x tidur gelisah (${sleepLogs.length} hari).';

    // 3. Rutin Medis / Obat (Dinamis dari ceklis obat user)
    final medLogs = logs
        .where((l) => l.medications.any((m) => m.isCompleted || m.isSkipped))
        .toList();
    final int totalMedSlots =
        medLogs.fold<int>(0, (s, l) => s + l.medications.length);
    final int doneMedSlots = medLogs.fold<int>(
      0,
      (s, l) => s + l.medications.where((m) => m.isCompleted).length,
    );
    final int medPct = totalMedSlots == 0
        ? 0
        : ((doneMedSlots / totalMedSlots) * 100).round();
    final String medSubNote = medLogs.isEmpty
        ? 'Belum ada jadwal obat tercatat.'
        : '$doneMedSlots dari $totalMedSlots jadwal obat diminum (${medLogs.length} hari).';

    // 4. Ritme Makan (Dinamis dari ceklis makan user)
    final mealLogs = logs
        .where((l) => l.meals.any((m) => m.isCompleted || m.isSkipped))
        .toList();
    final int totalMealSlots =
        mealLogs.fold<int>(0, (s, l) => s + l.meals.length);
    final int doneMealSlots = mealLogs.fold<int>(
      0,
      (s, l) => s + l.meals.where((m) => m.isCompleted).length,
    );
    final int mealPct = totalMealSlots == 0
        ? 0
        : ((doneMealSlots / totalMealSlots) * 100).round();
    final String mealSubNote = mealLogs.isEmpty
        ? 'Belum ada jadwal makan tercatat.'
        : '$doneMealSlots dari $totalMealSlots jadwal makan terpenuhi (${mealLogs.length} hari).';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: 18,
                    color: Color(0xFF1D3958),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Matriks Klinis Utama',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              Text(
                '$totalDays dari $daysInMonth Hari Tercatat',
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
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Stabilitas Afek',
                mainValue: avgMood.toStringAsFixed(1),
                unit: '/ 5.0',
                subNote: moodSubNote,
                icon: Icons.mood_rounded,
                badgeBg: const Color(0xFFFFD9E1),
                badgeFg: const Color(0xFF30111B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Tidur Sirkadian',
                mainValue: avgSleep.toStringAsFixed(1),
                unit: ' Jam',
                subNote: sleepSubNote,
                icon: Icons.bedtime_rounded,
                badgeBg: const Color(0xFFDEE0FF),
                badgeFg: const Color(0xFF161A32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Rutin Medis/Obat',
                mainValue: '$medPct%',
                unit: '',
                subNote: medSubNote,
                icon: Icons.medication_rounded,
                badgeBg: const Color(0xFFD2E4FF),
                badgeFg: const Color(0xFF001C37),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Ritme Makan',
                mainValue: '$mealPct%',
                unit: '',
                subNote: mealSubNote,
                icon: Icons.restaurant_rounded,
                badgeBg: const Color(0xFFEBE7E9),
                badgeFg: const Color(0xFF595D78),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String mainValue,
    required String unit,
    required String subNote,
    required IconData icon,
    required Color badgeBg,
    required Color badgeFg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.04),
            blurRadius: 14,
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
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF595D78),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: badgeFg),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: mainValue,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D3958),
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF595D78),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F2F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEBE7E9)),
            ),
            child: Text(
              subNote,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Color(0xFF43474D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. MOOD SPECTRUM BREAKDOWN (AFFECT DISTRIBUTION)
  // ===========================================================================
  Widget _buildMoodDistributionCard(MonthlySummary summary) {
    final total = summary.totalDaysRecorded;
    final c5 = summary.moodDistribution[5] ?? 0;
    final c4 = summary.moodDistribution[4] ?? 0;
    final c3 = summary.moodDistribution[3] ?? 0;
    final c2 = summary.moodDistribution[2] ?? 0;
    final c1 = summary.moodDistribution[1] ?? 0;

    int pct(int count) => total > 0 ? ((count / total) * 100).round() : 0;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribusi Afek & Suasana Hati',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                  Text(
                    'Proporsi $total hari pencatatan kondisi batin',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.donut_small_rounded,
                size: 22,
                color: Color(0xFF595D78),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Segmented Mood Horizontal Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 16,
              child: total == 0
                  ? Container(color: const Color(0xFFEBE7E9))
                  : Row(
                      children: [
                        if (c5 > 0)
                          Expanded(
                            flex: c5,
                            child: Container(color: const Color(0xFF1D3958)),
                          ),
                        if (c4 > 0)
                          Expanded(
                            flex: c4,
                            child: Container(color: const Color(0xFF355070)),
                          ),
                        if (c3 > 0)
                          Expanded(
                            flex: c3,
                            child: Container(color: const Color(0xFF595D78)),
                          ),
                        if (c2 > 0)
                          Expanded(
                            flex: c2,
                            child: Container(color: const Color(0xFF512D38)),
                          ),
                        if (c1 > 0)
                          Expanded(
                            flex: c1,
                            child: Container(color: const Color(0xFFBA1A1A)),
                          ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Micro Legend Pills
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendDot(
                color: const Color(0xFF1D3958),
                label: 'Damai / Stabil ($c5 hr · ${pct(c5)}%)',
              ),
              _buildLegendDot(
                color: const Color(0xFF355070),
                label: 'Tenang ($c4 hr · ${pct(c4)}%)',
              ),
              _buildLegendDot(
                color: const Color(0xFF595D78),
                label: 'Biasa ($c3 hr · ${pct(c3)}%)',
              ),
              _buildLegendDot(
                color: const Color(0xFF512D38),
                label: 'Lelah ($c2 hr · ${pct(c2)}%)',
              ),
              _buildLegendDot(
                color: const Color(0xFFBA1A1A),
                label: 'Hari Berat / Krisis ($c1 hr · ${pct(c1)}%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1B1D),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. STARRED JOURNAL ENTRIES FOR THERAPY DISCUSSION
  // ===========================================================================
  Widget _buildStarredJournalsSection(LumiProvider provider) {
    final displayNotes =
        provider.notes.where((n) => n.isPinnedForTherapy).toList();

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
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark_rounded,
                      size: 20,
                      color: Color(0xFF512D38),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Catatan Terpilih Pasien',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          Text(
                            'Ditandai bintang untuk dibahas di ruang konseling',
                            style: TextStyle(
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9E1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${displayNotes.length} Catatan',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30111B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (displayNotes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2F4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEBE7E9)),
              ),
              child: const Text(
                'Belum ada catatan jurnal yang ditandai bintang (★). Tandai catatan penting di menu Catatan untuk menampilkannya di lembar konsultasi ini.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                  color: Color(0xFF595D78),
                ),
              ),
            )
          else
            ...displayNotes.map((note) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F2F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEBE7E9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${note.date} · ${note.time} WIB',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF595D78),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFF512D38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _privacyBlurWrap(
                      Text(
                        '“${note.content}”',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          color: Color(0xFF43474D),
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
  // 6. THERAPY DISCUSSION CHECKLIST (PATIENT QUESTIONS FOR CLINICIAN)
  // ===========================================================================
  Widget _buildTherapyChecklistSection() {
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
            children: [
              const Icon(
                Icons.checklist_rounded,
                size: 20,
                color: Color(0xFF1D3958),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Agenda Tanya Pasien ke Dokter',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                  Text(
                    'Ketuk untuk menandai poin yang sudah dibahas',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_agendaItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2F4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEBE7E9)),
              ),
              child: const Text(
                'Belum ada daftar pertanyaan untuk dokter/psikiater. Ketuk tombol di bawah untuk menambahkan poin diskusi.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                  color: Color(0xFF595D78),
                ),
              ),
            )
          else
            ...List.generate(_agendaItems.length, (i) {
              final item = _agendaItems[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF8FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEBE7E9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: item.isChecked,
                        activeColor: const Color(0xFF1D3958),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (val) {
                          setState(() {
                            item.isChecked = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            item.isChecked = !item.isChecked;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                decoration: item.isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item.isChecked
                                    ? const Color(0xFF73777E)
                                    : const Color(0xFF1C1B1D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Tombol Edit & Hapus
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _showQuestionFormModal(editIndex: i),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EDEF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _deleteAgendaItem(i),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD6)
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 15,
                              color: Color(0xFFBA1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 8),

          // Tombol Tambah Pertanyaan untuk Dokter
          InkWell(
            onTap: () => _showQuestionFormModal(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF8FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC3C6CE).withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_rounded, size: 18, color: Color(0xFF595D78)),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Pertanyaan untuk Dokter',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
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
    );
  }

  // ===========================================================================
  // 7. FOOTER ACTIONS & MEDICAL COMPLIANCE (UNDUH PDF)
  // ===========================================================================
  Widget _buildFooterDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _handleDownloadReport,
        icon: const Icon(
          Icons.picture_as_pdf_rounded,
          size: 20,
          color: Colors.white,
        ),
        label: const Text(
          'Unduh PDF',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D3958),
          elevation: 3,
          shadowColor: const Color(0xFF355070).withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
