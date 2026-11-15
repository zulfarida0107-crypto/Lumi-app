import 'package:flutter/material.dart';
import 'setting.dart';

/// ============================================================================
/// KOMPONEN HEADER RESMI LUMI
/// ============================================================================
/// 1. Sisi Kiri: Foto resmi `assets/public/lumi_app_icon.jpg` rata kiri tanpa background putih
/// 2. Sisi Kanan: Hanya tombol Pengaturan (Settings)
class LumiHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsTap;

  const LumiHeader({super.key, this.onSettingsTap});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF8FA),
        border: Border(
          bottom: BorderSide(color: Color(0x1F73777E), width: 0.8),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sisi Kiri: Foto ikon + Nama Aplikasi "Lumi" & Tagline
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/public/lumi_app_icon.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.spa_rounded,
                        color: Color(0xFF355070),
                        size: 28,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Lumi',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D3958),
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ruang Teduh & Jejak Harian',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Sisi Kanan: Hanya pengaturan saja
            InkWell(
              onTap:
                  onSettingsTap ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingScreen()),
                    );
                  },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: Color(0xFF595D78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
