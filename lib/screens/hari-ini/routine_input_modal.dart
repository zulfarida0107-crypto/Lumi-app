import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/lumi_provider.dart';

/// ============================================================================
/// POPUP / BOTTOM SHEET: INPUT MAKAN & OBAT (Pagi, Siang, Malam)
/// ============================================================================
/// Mengganti status menjadi opsi Pagi, Siang, Malam.
/// Bila dipilih dan disimpan, otomatis terupdate pada tampilan Hari Ini.
void showRoutineInputModal(BuildContext context, {required RoutineType type, RoutineItem? initialItem}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => RoutineInputModalSheet(type: type, initialItem: initialItem),
  );
}

class RoutineInputModalSheet extends StatefulWidget {
  final RoutineType type;
  final RoutineItem? initialItem;

  const RoutineInputModalSheet({
    super.key,
    required this.type,
    this.initialItem,
  });

  @override
  State<RoutineInputModalSheet> createState() => _RoutineInputModalSheetState();
}

class _RoutineInputModalSheetState extends State<RoutineInputModalSheet> {
  late bool _pagi;
  late bool _siang;
  late bool _malam;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<LumiProvider>();
    final items = widget.type == RoutineType.obat
        ? provider.currentJejak.medications
        : provider.currentJejak.meals;

    _pagi = items.any((m) => m.id.contains('pagi') && m.isCompleted);
    _siang = items.any((m) => m.id.contains('siang') && m.isCompleted);
    _malam = items.any((m) => m.id.contains('malam') && m.isCompleted);

    // Jika dibuka dari item spesifik yang belum diceklis, aktifkan item tersebut
    if (widget.initialItem != null) {
      if (widget.initialItem!.id.contains('pagi')) _pagi = true;
      if (widget.initialItem!.id.contains('siang')) _siang = true;
      if (widget.initialItem!.id.contains('malam')) _malam = true;
    }

    // Ambil catatan yang ada
    final existingNote = widget.initialItem?.note.isNotEmpty == true
        ? widget.initialItem!.note
        : items.firstWhere((m) => m.note.isNotEmpty, orElse: () => const RoutineItem(id: '', title: '', type: RoutineType.makan)).note;

    _noteController = TextEditingController(text: existingNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final provider = context.read<LumiProvider>();
    provider.saveRoutinesForType(
      type: widget.type,
      pagi: _pagi,
      siang: _siang,
      malam: _malam,
      note: _noteController.text.trim(),
    );

    Navigator.of(context).pop();

    final title = widget.type == RoutineType.obat ? 'Obat' : 'Makan';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Jadwal $title hari ini berhasil diperbarui.'),
        backgroundColor: const Color(0xFF355070),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMakan = widget.type == RoutineType.makan;
    final title = isMakan ? 'Makan' : 'Obat';
    final themeColor = isMakan ? const Color(0xFFFFC0CB) : const Color(0xFFB5EAD7);
    final iconColor = isMakan ? const Color(0xFF512D38) : const Color(0xFF1D3958);
    final icon = isMakan ? Icons.restaurant_rounded : Icons.medication_rounded;

    return Container(
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

          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3958),
                      ),
                    ),
                    Text(
                      isMakan
                          ? 'Pilih jadwal makan hari ini (Pagi, Siang, Malam)'
                          : 'Pilih jadwal konsumsi obat (Pagi, Siang, Malam)',
                      style: const TextStyle(
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
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pilihan Status: Pagi, Siang, Malam
          const Text(
            'Status Waktu',
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
              // 1. Pagi
              Expanded(
                child: _waktuPill(
                  label: 'Pagi',
                  icon: Icons.wb_sunny_outlined,
                  isSelected: _pagi,
                  activeBg: isMakan ? const Color(0xFFFFF0F3) : const Color(0xFFE8F8F2),
                  activeBorder: isMakan ? const Color(0xFFFFC0CB) : const Color(0xFFB5EAD7),
                  activeFg: isMakan ? const Color(0xFF512D38) : const Color(0xFF1D6B4F),
                  onTap: () => setState(() => _pagi = !_pagi),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Siang
              Expanded(
                child: _waktuPill(
                  label: 'Siang',
                  icon: Icons.light_mode_outlined,
                  isSelected: _siang,
                  activeBg: isMakan ? const Color(0xFFFFF0F3) : const Color(0xFFE8F8F2),
                  activeBorder: isMakan ? const Color(0xFFFFC0CB) : const Color(0xFFB5EAD7),
                  activeFg: isMakan ? const Color(0xFF512D38) : const Color(0xFF1D6B4F),
                  onTap: () => setState(() => _siang = !_siang),
                ),
              ),
              const SizedBox(width: 8),

              // 3. Malam
              Expanded(
                child: _waktuPill(
                  label: 'Malam',
                  icon: Icons.nightlight_round,
                  isSelected: _malam,
                  activeBg: isMakan ? const Color(0xFFFFF0F3) : const Color(0xFFE8F8F2),
                  activeBorder: isMakan ? const Color(0xFFFFC0CB) : const Color(0xFFB5EAD7),
                  activeFg: isMakan ? const Color(0xFF512D38) : const Color(0xFF1D6B4F),
                  onTap: () => setState(() => _malam = !_malam),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Input Keterangan / Menu / Dosis
          Text(
            isMakan ? 'Menu Makanan (Opsional)' : 'Dosis / Catatan Obat (Opsional)',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF595D78),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: isMakan
                  ? 'Misal: Roti gandum, sup hangat, air putih'
                  : 'Misal: Sertraline 50mg, Vitamin D sesudah makan',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF73777E)),
              filled: true,
              fillColor: const Color(0xFFFCF8FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.35)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.35)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF355070), width: 1.5),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF1D3958),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Aksi
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
    );
  }

  Widget _waktuPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeBg,
    required Color activeBorder,
    required Color activeFg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : const Color(0xFFFCF8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeBorder : const Color(0xFFC3C6CE).withValues(alpha: 0.35),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBorder.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeFg : const Color(0xFF73777E),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle_rounded, size: 13, color: activeFg),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeFg : const Color(0xFF595D78),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
