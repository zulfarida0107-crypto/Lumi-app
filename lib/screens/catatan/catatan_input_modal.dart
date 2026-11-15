import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';

/// ============================================================================
/// POPUP / BOTTOM SHEET: TULIS & EDIT JURNAL TEDUH (CATATAN & MEMORI)
/// ============================================================================
void showCatatanInputModal(
  BuildContext context, {
  NoteMemory? noteToEdit,
  VoidCallback? onSaved,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => CatatanInputModalSheet(
      noteToEdit: noteToEdit,
      onSaved: onSaved,
    ),
  );
}

class CatatanInputModalSheet extends StatefulWidget {
  final NoteMemory? noteToEdit;
  final VoidCallback? onSaved;

  const CatatanInputModalSheet({
    super.key,
    this.noteToEdit,
    this.onSaved,
  });

  @override
  State<CatatanInputModalSheet> createState() => _CatatanInputModalSheetState();
}

class _CatatanInputModalSheetState extends State<CatatanInputModalSheet> {
  // 1: Berat, 2: Cemas, 3: Tenang (default), 4: Lega, 5: Hangat
  int _selectedMood = 3;
  String _selectedEnergy = 'rendah'; // 'rendah', 'cukup', 'penuh'
  bool _hasVoice = false;
  bool _hasPhoto = false;
  bool _isPinned = false; // Tandai untuk Konsultasi

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  late final DateTime _currentTime;

  bool get _isEditing => widget.noteToEdit != null;

  @override
  void initState() {
    super.initState();
    _currentTime = LumiProvider.wibNow();

    if (widget.noteToEdit != null) {
      final n = widget.noteToEdit!;
      _selectedMood = n.moodLevel;
      if (n.content.contains('\n\n')) {
        final split = n.content.split('\n\n');
        _titleController.text = split.first;
        _contentController.text = split.sublist(1).join('\n\n');
      } else {
        _contentController.text = n.content;
      }
      _isPinned = n.isPinnedForTherapy;
      _hasPhoto = n.photoPath != null && n.photoPath!.isNotEmpty;
      _hasVoice = n.audioPath != null && n.audioPath!.isNotEmpty;
    }

    _contentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  String _formatDateHeader(DateTime d) {
    const hari = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${hari[d.weekday]}, ${d.day} ${bulan[d.month]} ${d.year} • $h:$m';
  }

  void _saveJurnal() {
    final body = _contentController.text.trim();
    final title = _titleController.text.trim();

    if (body.isEmpty && title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan sedikit pikiranmu.'),
          backgroundColor: Color(0xFF355070),
        ),
      );
      return;
    }

    final fullContent = title.isNotEmpty ? '$title\n\n$body' : body;
    final provider = context.read<LumiProvider>();

    if (_isEditing) {
      provider.updateNote(
        id: widget.noteToEdit!.id,
        moodLevel: _selectedMood,
        content: fullContent,
        photoPath: _hasPhoto ? (widget.noteToEdit!.photoPath ?? 'assets/public/lumi_app_icon.jpg') : null,
        isPinnedForTherapy: _isPinned,
      );
    } else {
      provider.addNote(
        moodLevel: _selectedMood,
        content: fullContent,
        photoPath: _hasPhoto ? 'assets/public/lumi_app_icon.jpg' : null,
        isPinnedForTherapy: _isPinned,
      );
    }

    Navigator.of(context).pop();

    if (widget.onSaved != null) {
      widget.onSaved!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Catatan teduh berhasil diperbarui.'
              : 'Jejak teduh berhasil disimpan ke Catatan.',
        ),
        backgroundColor: const Color(0xFF355070),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFCF8FA), // surface/background
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            children: [
              // 1. TOP APP BAR (Batal, Judul Jurnal Teduh, Tanggal)
              _buildTopAppBar(context),

              // SCROLLABLE FORM BODY
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  children: [
                    // GENTLE WELCOME BANNER WITH LUMI MASCOT
                    _buildWelcomeBanner(),

                    const SizedBox(height: 14),

                    // SECTION 1: MOOD & ENERGY SELECTOR
                    _buildMoodAndEnergySection(),

                    const SizedBox(height: 14),

                    // SECTION 2: PRIMARY JOURNAL WRITING CANVAS
                    _buildJournalCanvasSection(),

                    const SizedBox(height: 14),

                    // SECTION 3: TAMBAHAN TEDUH (REKAM SUARA & FOTO)
                    _buildAttachmentsSection(),

                    const SizedBox(height: 14),

                    // SECTION 4: CLINICAL / THERAPY CONSULTATION TOGGLE
                    _buildConsultationToggleSection(),

                    const SizedBox(height: 20),

                    // BOTTOM PRIMARY ACTION
                    _buildSaveAction(),
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
  // 1. TOP APP BAR (FOCUSED TASK: BACK + CONTEXT + DIRECT)
  // ===========================================================================
  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF8FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF355070).withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Batal
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF595D78)),
                  SizedBox(width: 4),
                  Text(
                    'Batal',
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

          // Judul & Waktu Metadata
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa_rounded, size: 16, color: Color(0xFF1D3958)),
                  const SizedBox(width: 4),
                  Text(
                    _isEditing ? 'Edit Jurnal Teduh' : 'Jurnal Teduh',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _formatDateHeader(_currentTime),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10.5,
                  color: Color(0xFF73777E),
                ),
              ),
            ],
          ),

          // Spacer pengimbang tombol kiri agar judul tetap presisi di tengah
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  // ===========================================================================
  // GENTLE WELCOME BANNER WITH LUMI MASCOT
  // ===========================================================================
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.28),
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
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD9E1).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEEB8C6).withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/public/lumi_app_icon.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF355070),
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Hai, pelan-pelan saja...',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3958),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.favorite_rounded, size: 13, color: Color(0xFF512D38)),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tidak perlu kata puitis atau cerita panjang. Tarik napas, dan tuangkan sebisamu.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    height: 1.35,
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
  // SECTION 1: MOOD & ENERGY SELECTOR
  // ===========================================================================
  Widget _buildMoodAndEnergySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.28),
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
                      'Bagaimana rasanya tubuh & pikiranmu?',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3958),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pilih salah satu yang paling mendekati hatimu saat ini.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.wb_sunny_outlined, size: 20, color: Color(0xFFC3C6CE)),
            ],
          ),
          const SizedBox(height: 12),

          // 5 Mood Gradient Levels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _moodButton(level: 1, label: 'Berat', icon: Icons.cloud_outlined),
              _moodButton(level: 2, label: 'Cemas', icon: Icons.air_rounded),
              _moodButton(level: 3, label: 'Tenang', icon: Icons.spa_rounded),
              _moodButton(level: 4, label: 'Lega', icon: Icons.eco_outlined),
              _moodButton(level: 5, label: 'Hangat', icon: Icons.star_rounded),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1EDEF)),
          const SizedBox(height: 12),

          // Energy Level Quick Chips
          Row(
            children: const [
              Icon(Icons.battery_charging_full_rounded, size: 15, color: Color(0xFF595D78)),
              SizedBox(width: 5),
              Text(
                'Kapasitas Energi Saat Ini:',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3958),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _energyChip(
                keyName: 'rendah',
                label: 'Energi Rendah (Low Energy)',
                showDot: true,
              ),
              _energyChip(
                keyName: 'cukup',
                label: 'Energi Cukup',
              ),
              _energyChip(
                keyName: 'penuh',
                label: 'Energi Penuh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moodButton({
    required int level,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedMood == level;

    return InkWell(
      onTap: () => setState(() => _selectedMood = level),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF6F2F4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF355070) : const Color(0xFFE5E1E3),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF355070).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF355070) : const Color(0xFFF1EDEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF595D78),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3958) : const Color(0xFF595D78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyChip({
    required String keyName,
    required String label,
    bool showDot = false,
  }) {
    final bool isSelected = _selectedEnergy == keyName;

    return InkWell(
      onTap: () => setState(() => _selectedEnergy = keyName),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD9E1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFEEB8C6) : const Color(0xFFC3C6CE).withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF512D38),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF30111B) : const Color(0xFF595D78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 3: PRIMARY JOURNAL WRITING CANVAS
  // ===========================================================================
  Widget _buildJournalCanvasSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8A4B1).withValues(alpha: 0.28),
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
          const Text(
            'Ruang Aman Pribadi (Enkripsi Perangkat)',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.5,
              color: Color(0xFF73777E),
            ),
          ),
          const SizedBox(height: 8),

          // Judul Opsional
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D3958),
            ),
            decoration: InputDecoration(
              hintText: 'Beri judul kecil jika ingin (bisa dilewati)...',
              hintStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: const Color(0xFF595D78).withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1EDEF)),
          const SizedBox(height: 8),

          // Main Textarea
          TextField(
            controller: _contentController,
            minLines: 6,
            maxLines: 12,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFF1C1B1D),
            ),
            decoration: InputDecoration(
              hintText:
                  'Tuliskan apa saja yang melintas di benakmu, tanpa harus teratur atau sempurna. Ruang ini aman dan sepenuhnya milikmu...',
              hintStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                height: 1.45,
                color: const Color(0xFF73777E).withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: const Color(0xFFFCF8FA).withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),

          // Word Count & Compassionate Guidance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_wordCount kata tersimpan',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: Color(0xFF73777E),
                ),
              ),
              const Text(
                'Tidak ada batas, tidak ada tuntutan',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: Color(0xFF73777E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 4: TAMBAHAN TEDUH (REKAM SUARA & FOTO)
  // ===========================================================================
  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tambahan Teduh (Opsional)',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3958),
            ),
          ),
        ),
        Row(
          children: [
            // Voice Record Pill
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _hasVoice = !_hasVoice);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_hasVoice
                          ? 'Memo suara dilampirkan ke jurnal.'
                          : 'Memo suara dilepas.'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF355070),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _hasVoice
                          ? const Color(0xFFEEB8C6)
                          : const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                      width: _hasVoice ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF355070).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD9E1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, size: 18, color: Color(0xFF30111B)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasVoice ? 'Terlampir' : 'Rekam Suara',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D3958),
                              ),
                            ),
                            const Text(
                              'Jika lelah mengetik',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10.5,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Photo Pill
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _hasPhoto = !_hasPhoto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_hasPhoto
                          ? 'Dokumentasi foto dilampirkan.'
                          : 'Dokumentasi foto dilepas.'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF355070),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _hasPhoto
                          ? const Color(0xFFEEB8C6)
                          : const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                      width: _hasPhoto ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF355070).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDEE0FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, size: 18, color: Color(0xFF161A32)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasPhoto ? 'Terlampir' : 'Sudut Tenang',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D3958),
                              ),
                            ),
                            const Text(
                              'Foto lampu/langit',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10.5,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION 5: CLINICAL / THERAPY CONSULTATION TOGGLE
  // ===========================================================================
  Widget _buildConsultationToggleSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2F4).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF355070).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF1D3958),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tandai untuk Sesi Konsultasi',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Catatan ini akan otomatis disorot di tab Catatan & siap diekspor ke rangkuman PDF agar tidak terlupa saat sesi konsultasi.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    height: 1.35,
                    color: Color(0xFF595D78),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPinned,
            activeTrackColor: const Color(0xFF355070),
            onChanged: (val) => setState(() => _isPinned = val),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM PRIMARY ACTIONS
  // ===========================================================================
  Widget _buildSaveAction() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _saveJurnal,
            icon: const Icon(Icons.favorite_rounded, size: 20, color: Color(0xFF30111B)),
            label: Text(
              _isEditing ? 'Perbarui Jejak Teduh' : 'Simpan Jejak Teduh Hari Ini',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF30111B), // on-tertiary-fixed
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD9E1), // tertiary-fixed
              elevation: 2,
              shadowColor: const Color(0xFFFFC0CB).withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Semua catatan tersimpan aman secara offline di gawaimu.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            color: Color(0xFF73777E),
          ),
        ),
      ],
    );
  }
}
