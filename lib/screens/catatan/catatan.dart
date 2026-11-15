import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';
import 'catatan_input_modal.dart';

/// ============================================================================
/// LAYAR TAB 2: CATATAN (JURNAL, MEMORI, & MODE SIAP KONSULTASI)
/// ============================================================================
/// Mengadopsi arsitektur visual HTML/Tailwind Lumi:
/// 1. Top Prompt Bar & Tombol Mata Teduh (Discreet View / Privacy Veil Blur)
/// 2. Pencarian Tactile Pill & Dropdown Filter Fleksibel
/// 3. Banner Mode Siap Konsultasi Aktif (Ringkasan Rapi untuk Dokter/Psikolog)
/// 4. Feed Kartu Jurnal Harian (Multimedia: Foto, Audio Memo Waveform, Low-Energy)
/// 5. Floating Action Button: "Tulis Jurnal Teduh" (Tanpa ikon pensil dan +)
class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  // 0: Semua Catatan, 1: ⭐ Siap Konsultasi, 2: Low Energy, 3: Dokumentasi, 4: Memo Suara
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isPlayingAudio = false; // Simulasi Pemutaran Memo Suara
  bool _isMataTeduh = false; // Blurring untuk Privasi Mata Teduh

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LumiProvider>();
    final notes = provider.notes;

    // Filter data berdasarkan chip dan pencarian
    final filteredNotes = notes.where((n) {
      // 1. Filter Pencarian
      if (_searchQuery.isNotEmpty &&
          !n.content.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // 2. Filter Kategori
      switch (_selectedFilterIndex) {
        case 1: // ⭐ Siap Konsultasi / Pinned
          return n.isPinnedForTherapy;
        case 2: // Low Energy / Berat (Level 1 atau 2)
          return n.moodLevel <= 2;
        case 3: // Dokumentasi Foto
          return n.photoPath != null && n.photoPath!.isNotEmpty;
        case 4: // Memo Suara
          return n.audioPath != null && n.audioPath!.isNotEmpty;
        default:
          return true;
      }
    }).toList();

    // Hitung badge counter untuk masing-masing filter
    final totalCount = notes.length;
    final pinnedCount = notes.where((n) => n.isPinnedForTherapy).length;
    final lowEnergyCount = notes.where((n) => n.moodLevel <= 2).length;
    final photoCount =
        notes.where((n) => n.photoPath != null && n.photoPath!.isNotEmpty).length;
    final voiceCount =
        notes.where((n) => n.audioPath != null && n.audioPath!.isNotEmpty).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      // 5. FLOATING ACTION BUTTON (Tanpa ikon pensil dan +)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCatatanInputModal(context),
        backgroundColor: const Color(0xFFFFD9E1), // tertiary-fixed
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        label: const Text(
          'Tulis Jurnal Teduh',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            color: Color(0xFF1D3958), // primary
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // 1. TOP HEADER & PROMPT AREA
          _buildHeaderSection(),

          const SizedBox(height: 14),

          // 2. SEARCH & FILTER CEPAT (DROPDOWN)
          _buildSearchAndFilters(
            totalCount: totalCount,
            pinnedCount: pinnedCount,
            lowEnergyCount: lowEnergyCount,
            photoCount: photoCount,
            voiceCount: voiceCount,
          ),

          const SizedBox(height: 14),

          // 3. KARTU RINGKASAN TERAPI CEPAT (Mode Siap Konsultasi)
          if (pinnedCount > 0 && (_selectedFilterIndex == 0 || _selectedFilterIndex == 1))
            _buildConsultationBanner(pinnedCount, notes.where((n) => n.isPinnedForTherapy).toList()),

          // 4. DAFTAR FEED CATATAN / JURNAL HARIAN
          if (filteredNotes.isEmpty)
            _buildEmptyState()
          else
            ...filteredNotes.map((note) => _buildJournalCard(note)),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER PROMPT & TOMBOL MATA TEDUH (BLURRING PRIVASI)
  // ===========================================================================
  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Catatan & Jejak Perasaan',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: Color(0xFF1D3958), // primary
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Tuliskan apa saja yang melintas tanpa harus sempurna.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  color: Color(0xFF595D78), // secondary
                ),
              ),
            ],
          ),
        ),
        // Tombol Mata Teduh (Blurring Privasi)
        InkWell(
          onTap: () {
            setState(() {
              _isMataTeduh = !_isMataTeduh;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: _isMataTeduh ? const Color(0xFFFFD9E1) : const Color(0xFFF6F2F4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isMataTeduh
                    ? const Color(0xFFEEB8C6)
                    : const Color(0xFFE5E1E3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isMataTeduh ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 15,
                  color: _isMataTeduh ? const Color(0xFF30111B) : const Color(0xFF595D78),
                ),
                const SizedBox(width: 5),
                Text(
                  _isMataTeduh ? 'Buka Tirai' : 'Mata Teduh',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _isMataTeduh ? const Color(0xFF30111B) : const Color(0xFF595D78),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. SEARCH BAR & DROPDOWN FILTER
  // ===========================================================================
  Widget _buildSearchAndFilters({
    required int totalCount,
    required int pinnedCount,
    required int lowEnergyCount,
    required int photoCount,
    required int voiceCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tactile Pill Search Field
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEBE7E9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF355070).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13.5,
              color: Color(0xFF1C1B1D),
            ),
            decoration: InputDecoration(
              hintText: 'Cari dalam kenangan & catatan...',
              hintStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF73777E),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xFF595D78),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF595D78)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Dropdown Filterisasi
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEBE7E9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF355070).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedFilterIndex,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFF355070),
                size: 26,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(20),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3958),
              ),
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 17, color: Color(0xFF595D78)),
                      const SizedBox(width: 8),
                      Text('Semua Catatan ($totalCount)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 17, color: Color(0xFF6B434E)),
                      const SizedBox(width: 8),
                      Text('Siap Konsultasi/ Pin ($pinnedCount)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 17, color: Color(0xFF595D78)),
                      const SizedBox(width: 8),
                      Text('Low Energy / Berat ($lowEnergyCount)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      const Icon(Icons.photo_camera_outlined, size: 17, color: Color(0xFF595D78)),
                      const SizedBox(width: 8),
                      Text('Dokumentasi Foto ($photoCount)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      const Icon(Icons.mic_none_outlined, size: 17, color: Color(0xFF595D78)),
                      const SizedBox(width: 8),
                      Text('Memo Suara ($voiceCount)'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFilterIndex = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. KARTU RINGKASAN TERAPI CEPAT (BANNER MODE SIAP KONSULTASI)
  // ===========================================================================
  Widget _buildConsultationBanner(int count, List<NoteMemory> pinnedNotes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD9E1), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.05),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD9E1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      size: 16,
                      color: Color(0xFF30111B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mode Siap Konsultasi Aktif',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count Catatan Pilihan',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF595D78),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Catatan penting ditandai untuk dibagikan secara tenang saat sesi bersama dokter/psikiater terdekat.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF595D78),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showRingkasanRapiModal(context, pinnedNotes),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF355070), // primary-container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Buka Ringkasan Rapi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.shield_outlined, size: 14, color: Color(0xFF73777E)),
                  SizedBox(width: 4),
                  Text(
                    'Aman & Terenkripsi',
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
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. DAFTAR FEED CATATAN / JURNAL HARIAN
  // ===========================================================================
  Widget _buildJournalCard(NoteMemory note) {
    final bool isLowEnergy = note.moodLevel == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLowEnergy
            ? const Border(
                left: BorderSide(color: Color(0xFF595D78), width: 4),
                top: BorderSide(color: Color(0xFFEBE7E9)),
                right: BorderSide(color: Color(0xFFEBE7E9)),
                bottom: BorderSide(color: Color(0xFFEBE7E9)),
              )
            : Border.all(
                color: note.isPinnedForTherapy
                    ? const Color(0xFFEEB8C6).withValues(alpha: 0.7)
                    : const Color(0xFFEBE7E9),
                width: note.isPinnedForTherapy ? 1.4 : 1.0,
              ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => showCatatanInputModal(context, noteToEdit: note),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Header: Tanggal, Waktu, Mood Level Tag, dan Opsi Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          note.date,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text('•', style: TextStyle(color: Color(0xFF73777E), fontSize: 11)),
                        const SizedBox(width: 5),
                        Text(
                          note.time,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.5,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    _buildMoodBadge(note.moodLevel),
                  ],
                ),
              ),

              // Bagian Kanan: Pin Badge / Low-Energy Badge & Menu Titik Tiga
              Row(
                children: [
                  if (note.isPinnedForTherapy) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD9E1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star_rounded, size: 14, color: Color(0xFF6B434E)),
                          SizedBox(width: 3),
                          Text(
                            'Catatan',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF30111B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else if (isLowEnergy) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF595D78)),
                          SizedBox(width: 3),
                          Text(
                            '1-Tap Low-Energy',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10.5,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Tombol Edit Cepat
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 17, color: Color(0xFF595D78)),
                    tooltip: 'Edit Catatan',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    splashRadius: 16,
                    onPressed: () => showCatatanInputModal(context, noteToEdit: note),
                  ),

                  // Popup Menu Opsi Catatan
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF73777E)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (val) {
                      final provider = context.read<LumiProvider>();
                      if (val == 'edit') {
                        showCatatanInputModal(context, noteToEdit: note);
                      } else if (val == 'pin') {
                        provider.togglePinNote(note.id);
                      } else if (val == 'hapus') {
                        _showDeleteConfirmDialog(context, note);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1D3958)),
                            SizedBox(width: 8),
                            Text(
                              'Edit Catatan',
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              note.isPinnedForTherapy ? Icons.star_border_rounded : Icons.star_rounded,
                              size: 18,
                              color: const Color(0xFF355070),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              note.isPinnedForTherapy ? 'Lepas Pin Konsultasi' : 'Tandai Siap Konsultasi',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'hapus',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFBA1A1A)),
                            SizedBox(width: 8),
                            Text(
                              'Hapus Catatan',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFFBA1A1A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Teks Konten Jurnal (Mendukung Blurring Mata Teduh)
          _isMataTeduh
              ? ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13.5,
                      height: 1.5,
                      fontStyle: isLowEnergy ? FontStyle.italic : FontStyle.normal,
                      color: isLowEnergy ? const Color(0xFF595D78) : const Color(0xFF1C1B1D),
                    ),
                  ),
                )
              : Text(
                  note.content,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13.5,
                    height: 1.5,
                    fontStyle: isLowEnergy ? FontStyle.italic : FontStyle.normal,
                    color: isLowEnergy ? const Color(0xFF595D78) : const Color(0xFF1C1B1D),
                  ),
                ),

          // Baris Multimedia (Thumbnail Foto & Memo Suara Waveform)
          if ((note.photoPath != null && note.photoPath!.isNotEmpty) ||
              (note.audioPath != null && note.audioPath!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Thumbnail Foto Kecil
                if (note.photoPath != null && note.photoPath!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F2F4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE7E9)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 26,
                            height: 26,
                            color: const Color(0xFFFFD9E1),
                            child: const Icon(Icons.image_outlined, size: 16, color: Color(0xFF512D38)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Dokumentasi Foto',
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

                // Audio Memo Row (Voice Log dengan Tiny Waveform)
                if (note.audioPath != null && note.audioPath!.isNotEmpty)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isPlayingAudio = !_isPlayingAudio;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isPlayingAudio
                              ? 'Memutar memo suara harian...'
                              : 'Memo suara dijeda.'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: const Color(0xFF355070),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F2F4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEBE7E9)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFF355070),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tiny visual waveform bars
                          Row(
                            children: const [
                              _WaveBar(height: 10, isActive: false),
                              _WaveBar(height: 16, isActive: true),
                              _WaveBar(height: 8, isActive: false),
                              _WaveBar(height: 18, isActive: true),
                              _WaveBar(height: 12, isActive: false),
                              _WaveBar(height: 6, isActive: false),
                              _WaveBar(height: 14, isActive: true),
                              _WaveBar(height: 8, isActive: false),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '01:24',
                            style: TextStyle(
                              fontFamily: 'monospace',
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
          ],

          // Footer Penenang (Khusus Kartu Mode Low-Energy / Level 1)
          if (isLowEnergy) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEBE7E9), width: 0.8),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.favorite_rounded, size: 14, color: Color(0xFF1D3958)),
                  SizedBox(width: 6),
                  Text(
                    'Sudah aman sekarang. Tarik napas perlahan.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  ),
),
);
  }

  // ===========================================================================
  // WIDGET HELPER: MOOD BADGE
  // ===========================================================================
  Widget _buildMoodBadge(int level) {
    String label;
    Color bg;
    Color fg;

    switch (level) {
      case 1:
        label = 'Level 1: Sangat Berat';
        bg = const Color(0xFFDBDEFF).withValues(alpha: 0.6);
        fg = const Color(0xFF414560);
        break;
      case 2:
        label = 'Level 2: Lelah';
        bg = const Color(0xFFF6F2F4);
        fg = const Color(0xFF595D78);
        break;
      case 3:
        label = 'Level 3: Biasa / Tenang';
        bg = const Color(0xFFF6F2F4);
        fg = const Color(0xFF595D78);
        break;
      case 4:
        label = 'Level 4: Ringan & Lega';
        bg = const Color(0xFFF6F2F4);
        fg = const Color(0xFF595D78);
        break;
      case 5:
        label = 'Level 5: Hangat & Baik';
        bg = const Color(0xFFFFD9E1);
        fg = const Color(0xFF512D38);
        break;
      default:
        label = 'Level 3: Tenang';
        bg = const Color(0xFFF6F2F4);
        fg = const Color(0xFF595D78);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
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
  // EMPTY STATE (TAMPILAN JIKA BELUM ADA CATATAN)
  // ===========================================================================
  Widget _buildEmptyState() {
    return InkWell(
      onTap: () => showCatatanInputModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1EDEF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa_rounded, size: 28, color: Color(0xFF355070)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ruang Teduhmu Masih Hening',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3958),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ketuk tombol "Tulis Jurnal Teduh" untuk menuangkan apa saja yang kamu rasakan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Color(0xFF595D78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MODAL RINGKASAN RAPI SIAP KONSULTASI
  // ===========================================================================
  void _showRingkasanRapiModal(BuildContext context, List<NoteMemory> notes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E1E3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.bookmark_rounded, color: Color(0xFF355070), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Ringkasan Konsultasi Psikiater / Dokter',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Daftar catatan penting yang telah kamu tandai bintang untuk sesi konseling.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Color(0xFF595D78),
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: notes.length,
                separatorBuilder: (context, index) => const Divider(height: 18),
                itemBuilder: (ctx, i) {
                  final n = notes[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${n.date} • ${n.time}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF355070),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                NoteMemory.moodLabel(n.moodLevel),
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF595D78),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF595D78)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                splashRadius: 14,
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  showCatatanInputModal(context, noteToEdit: n);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.content,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.5,
                          height: 1.45,
                          color: Color(0xFF1C1B1D),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DIALOG KONFIRMASI HAPUS
  // ===========================================================================
  void _showDeleteConfirmDialog(BuildContext context, NoteMemory note) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Catatan?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        content: const Text(
          'Catatan ini akan dihapus dari memori jejak perasaanmu.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12.5,
            color: Color(0xFF595D78),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF595D78))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LumiProvider>().deleteNote(note.id);
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan berhasil dihapus.'),
                  backgroundColor: Color(0xFF355070),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Helper Widget: Tiny Audio Waveform Bar
class _WaveBar extends StatelessWidget {
  final double height;
  final bool isActive;

  const _WaveBar({required this.height, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 2.5,
      height: height,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF355070) : const Color(0xFF595D78).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
