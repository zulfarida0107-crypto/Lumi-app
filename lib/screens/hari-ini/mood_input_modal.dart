import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lumi_provider.dart';

/// ============================================================================
/// POPUP / BOTTOM SHEET: INPUT MOOD & KAPASITAS ENERGI
/// ============================================================================
/// Muncul dari bawah saat kartu Mood pada grid JEJAK HARI INI ditekan.
/// Memungkinkan memilih suasana hati (Lv 1-5) & kapasitas energi (Rendah, Cukup, Penuh).
void showMoodAndEnergyModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const MoodAndEnergyModalSheet(),
  );
}

class MoodAndEnergyModalSheet extends StatefulWidget {
  const MoodAndEnergyModalSheet({super.key});

  @override
  State<MoodAndEnergyModalSheet> createState() => _MoodAndEnergyModalSheetState();
}

class _MoodAndEnergyModalSheetState extends State<MoodAndEnergyModalSheet> {
  late int _selectedMood;
  late String _selectedEnergy;

  @override
  void initState() {
    super.initState();
    final provider = context.read<LumiProvider>();
    _selectedMood = provider.currentJejak.moodLevel;
    _selectedEnergy = provider.currentJejak.energyLevel;
  }

  void _save() {
    final provider = context.read<LumiProvider>();
    provider.setMoodAndEnergy(_selectedMood, _selectedEnergy);
    Navigator.of(context).pop();

    const moodNames = ['', 'Berat', 'Cemas', 'Tenang', 'Lega', 'Hangat'];
    final mName = _selectedMood >= 1 && _selectedMood <= 5 ? moodNames[_selectedMood] : 'Tenang';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mood ($mName) berhasil disimpan ke Jejak Hari Ini.'),
        backgroundColor: const Color(0xFF355070),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moods = [
      {'level': 1, 'name': 'Berat', 'icon': Icons.cloud_outlined},
      {'level': 2, 'name': 'Cemas', 'icon': Icons.air_rounded},
      {'level': 3, 'name': 'Tenang', 'icon': Icons.park_outlined},
      {'level': 4, 'name': 'Lega', 'icon': Icons.eco_outlined},
      {'level': 5, 'name': 'Hangat', 'icon': Icons.auto_awesome_outlined},
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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

            // Header: Judul + Tombol Tutup (ikon matahari sudah dihapus)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bagaimana rasanya tubuh &\npikiranmu?',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pilih salah satu yang paling mendekati hatimu saat ini.',
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
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Grid Penjelasan Skala Level (Tanpa dot warna)
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _levelExplanationCard(
                      width: itemWidth,
                      level: 'Lv 1',
                      title: 'Berat',
                      desc: 'Beban emosi intens, energi minim & butuh jeda',
                      isSelected: _selectedMood == 1,
                      onTap: () => setState(() => _selectedMood = 1),
                    ),
                    _levelExplanationCard(
                      width: itemWidth,
                      level: 'Lv 2',
                      title: 'Cemas',
                      desc: 'Pikiran penat, gelisah, atau lelah berlebih',
                      isSelected: _selectedMood == 2,
                      onTap: () => setState(() => _selectedMood = 2),
                    ),
                    _levelExplanationCard(
                      width: itemWidth,
                      level: 'Lv 3',
                      title: 'Biasa',
                      desc: 'Kondisi netral, beraktivitas seperti biasa',
                      isSelected: _selectedMood == 3,
                      onTap: () => setState(() => _selectedMood = 3),
                    ),
                    _levelExplanationCard(
                      width: itemWidth,
                      level: 'Lv 4',
                      title: 'Lega',
                      desc: 'Hati terasa lapang, tenang & beban berkurang',
                      isSelected: _selectedMood == 4,
                      onTap: () => setState(() => _selectedMood = 4),
                    ),
                    _levelExplanationCard(
                      width: constraints.maxWidth,
                      level: 'Lv 5',
                      title: 'Hangat',
                      desc: 'Damai, stabil, segar & penuh energi positif',
                      isSelected: _selectedMood == 5,
                      onTap: () => setState(() => _selectedMood = 5),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),

          // 5 Pilihan Tombol Mood (Sesuai Gambar 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((m) {
              final lvl = m['level'] as int;
              final name = m['name'] as String;
              final icon = m['icon'] as IconData;
              final isSel = _selectedMood == lvl;

              return InkWell(
                onTap: () => setState(() => _selectedMood = lvl),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFF6F8FB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel ? const Color(0xFF2C3E55) : Colors.transparent,
                      width: 1.6,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF2C3E55) : const Color(0xFFF1EDEF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSel ? Colors.white : const Color(0xFF595D78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? const Color(0xFF1D3958) : const Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // Kapasitas Energi Saat Ini (Sesuai Gambar 2)
          Row(
            children: const [
              Icon(Icons.battery_2_bar_rounded, size: 16, color: Color(0xFF1D3958)),
              SizedBox(width: 6),
              Text(
                'Kapasitas Energi Saat Ini:',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3958),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 1. Energi Rendah (Low Energy)
              _energyPill(
                label: 'Energi Rendah (Low Energy)',
                isSelected: _selectedEnergy == 'rendah',
                selectedBg: const Color(0xFFFFD9E1),
                selectedBorder: const Color(0xFFFFB6C1),
                selectedDot: const Color(0xFF6B1D2F),
                selectedFg: const Color(0xFF30111B),
                onTap: () => setState(() => _selectedEnergy = 'rendah'),
              ),
              // 2. Energi Cukup
              _energyPill(
                label: 'Energi Cukup',
                isSelected: _selectedEnergy == 'cukup',
                selectedBg: const Color(0xFFE8F8F2),
                selectedBorder: const Color(0xFFB5EAD7),
                selectedDot: const Color(0xFF1D6B4F),
                selectedFg: const Color(0xFF1D6B4F),
                onTap: () => setState(() => _selectedEnergy = 'cukup'),
              ),
              // 3. Energi Penuh (Sesuai Gambar 2: Aksen Kuning Keemasan)
              _energyPill(
                label: 'Energi Penuh',
                isSelected: _selectedEnergy == 'penuh',
                selectedBg: const Color(0xFFFDF4DC),
                selectedBorder: const Color(0xFFE5C678),
                selectedDot: const Color(0xFF78350F),
                selectedFg: const Color(0xFF78350F),
                onTap: () => setState(() => _selectedEnergy = 'penuh'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Aksi: Batal & Simpan Catatan
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D3958),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Catatan',
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
    ),
  );
  }

  Widget _levelExplanationCard({
    required double width,
    required String level,
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF4F9) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D3958) : const Color(0xFFE8ECEF),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  level,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFF1D3958) : const Color(0xFF4A4E69),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF1D3958) : const Color(0xFF2C3E55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 9.8,
                color: Color(0xFF6B7280),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyPill({
    required String label,
    required bool isSelected,
    required Color selectedBg,
    required Color selectedBorder,
    required Color selectedDot,
    required Color selectedFg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBorder : const Color(0xFFE5E1E3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selectedDot,
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
                color: isSelected ? selectedFg : const Color(0xFF43474D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
