import 'package:flutter/material.dart';
import '../../core/theme/lumi_theme.dart';
import '../auth/lumi_auth_screens.dart';

/// ============================================================================
/// LAYAR PENGATURAN (SETTINGS SCREEN) - LUMI RUANG TEDUH
/// ============================================================================
/// 1. Profil Kawan Tenang & Maskot Lumi
/// 2. Privasi & Keamanan (Biometrik, Bersihkan Cache)
/// 3. Ritme Notifikasi Lembut
/// 4. Sinkronisasi Lembar Jejak & Data (Popup Input Link & Nama File Spreadsheet)
/// 5. Kunci Ruang Teduh Sementara & Kata Penyemangat
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _biometricEnabled = true;
  bool _gentleReminderEnabled = true;

  // State link dan nama berkas spreadsheet (bisa diatur langsung lewat popup tanpa backend)
  String _spreadsheetFileName = 'Lumi_Jejak_2026';
  String _spreadsheetUrl = 'https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit';

  void _showSpreadsheetLinkDialog() {
    final nameController = TextEditingController(text: _spreadsheetFileName);
    final urlController = TextEditingController(text: _spreadsheetUrl);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.table_chart_rounded, color: Color(0xFF188038), size: 22),
            SizedBox(width: 8),
            Text(
              'Tautan Spreadsheet',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3958),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Berkas Spreadsheet:',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3958),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Contoh: Lumi_Jejak_Harian',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF73777E)),
                  filled: true,
                  fillColor: const Color(0xFFFCF8FA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF355070)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Link / URL Google Spreadsheet:',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3958),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: urlController,
                maxLines: 2,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'https://docs.google.com/spreadsheets/d/...',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF73777E)),
                  filled: true,
                  fillColor: const Color(0xFFFCF8FA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: const Color(0xFFC3C6CE).withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF355070)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Link tersimpan langsung di aplikasi tanpa perlu konfigurasi backend.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: Color(0xFF73777E),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF595D78),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (nameController.text.trim().isNotEmpty) {
                  _spreadsheetFileName = nameController.text.trim();
                }
                _spreadsheetUrl = urlController.text.trim();
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tautan spreadsheet "$_spreadsheetFileName" berhasil disimpan.'),
                  backgroundColor: const Color(0xFF355070),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF355070),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Simpan Tautan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1D3958)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Intro Header
              const Text(
                'Kelola kenyamanan, keamanan & privasi ruang teduhmu dengan perlahan tanpa terburu-buru.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Color(0xFF595D78),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Profile & Mascot Hero Card
              _buildProfileCard(),
              const SizedBox(height: 20),

              // 3. SECTION 1: Privasi & Keamanan Tingkat Tinggi
              _buildSectionHeader(
                icon: Icons.security_rounded,
                title: 'Privasi & Keamanan Tingkat Tinggi',
              ),
              const SizedBox(height: 8),
              _buildPrivacySection(),
              const SizedBox(height: 20),

              // 4. SECTION 2: Ritme Notifikasi
              _buildSectionHeader(
                icon: Icons.notifications_none_rounded,
                title: 'Ritme Notifikasi',
              ),
              const SizedBox(height: 8),
              _buildNotificationSection(),
              const SizedBox(height: 20),

              // 5. SECTION 3: Sinkronisasi Jejak & Data
              _buildSectionHeader(
                icon: Icons.sync_rounded,
                title: 'Sinkronisasi Jejak & Data',
              ),
              const SizedBox(height: 8),
              _buildSyncSection(),
              const SizedBox(height: 24),

              // 6. SECTION 4: Footer, Kunci Sementara
              _buildFooterSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET HELPERS
  // ===========================================================================

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1D3958)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3958),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.35)),
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
          // Maskot Lentera Lumi
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 54,
              height: 54,
              color: const Color(0xFF355070).withValues(alpha: 0.08),
              child: Image.asset(
                'assets/public/lumi_app_icon.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.spa_rounded, color: Color(0xFF355070), size: 26),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Detail Kawan Tenang
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LumiAuthStore.registeredNickname ?? 'Kawan Tenang',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 13, color: Color(0xFF1D3958)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        LumiAuthStore.registeredEmail != null
                            ? '${LumiAuthStore.registeredEmail} • Terenkripsi'
                            : 'Data Tersimpan Lokal & Terenkripsi',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LumiLoginScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD9E1).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD8A4B1).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.login_rounded,
                          size: 14,
                          color: Color(0xFF30111B),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Masuk Akun Lumi',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF30111B),
                          ),
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

  Widget _buildPrivacySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Item 1: Kunci Biometrik & PIN
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _iconBox(Icons.fingerprint_rounded, const Color(0xFF1D3958)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Kunci Biometrik & PIN',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Buka dengan Face ID, sidik jari, atau 4-digit PIN tanpa jeda.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.5,
                          color: Color(0xFF595D78),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _biometricEnabled,
                  activeThumbColor: const Color(0xFF355070),
                  onChanged: (val) {
                    setState(() => _biometricEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val ? 'Kunci biometrik diaktifkan.' : 'Kunci biometrik dinonaktifkan.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1EDEF)),

          // Item 2: Bersihkan Cache & Kunci Cepat
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache sementara dibersihkan. Ruang teduhmu kembali hening.'),
                  backgroundColor: LumiColors.mutedNavy,
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _iconBox(Icons.auto_delete_outlined, const Color(0xFF595D78)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bersihkan Cache & Kunci Cepat',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hapus riwayat pengetikan sementara dan langsung amankan layar.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.5,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF595D78), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pengingat Lembut
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(Icons.notifications_paused_outlined, const Color(0xFF512D38)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pengingat Lembut & Nada Sopan',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        Switch(
                          value: _gentleReminderEnabled,
                          activeThumbColor: const Color(0xFF355070),
                          onChanged: (val) => setState(() => _gentleReminderEnabled = val),
                        ),
                      ],
                    ),
                    const Text(
                      'Hanya kata-kata penuh empati tanpa kata mendesak, tanpa getar mendadak, menjaga ketenangan detak jantung.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        color: Color(0xFF595D78),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action link: Uji notifikasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingin melihat contoh sapaan Lumi?',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  color: Color(0xFF595D78),
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('"Hai Kawan Tenang, tarik nafas sejenak yuk. Kamu sudah bertahan hebat hari ini."'),
                      backgroundColor: LumiColors.mutedNavy,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Uji Notifikasi Sekarang',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3958),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8A4B1).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355070).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Google Sheets Pribadi + Popup Masukkan Link
          InkWell(
            onTap: _showSpreadsheetLinkDialog,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E1E3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF188038).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_chart_rounded, size: 22, color: Color(0xFF188038)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _spreadsheetFileName,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D3958),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F8F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Tersambung',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D6B4F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _spreadsheetUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC3C6CE).withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1D3958)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dual Bento Buttons: Ekspor CSV & Ringkasan (PDF)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menyiapkan berkas CSV untuk olah data mandiri...')),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F2F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E1E3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.download_rounded, size: 16, color: Color(0xFF1D3958)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ekspor CSV',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const Text(
                          'Untuk olah data mandiri',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menyiapkan Ringkasan PDF format ramah konsultasi...')),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F2F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E1E3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.medical_information_outlined, size: 16, color: Color(0xFF1D3958)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ringkasan (PDF)',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const Text(
                          'Format ramah konsultasi',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enkripsi Footer
          Row(
            children: const [
              Icon(Icons.shield_rounded, size: 14, color: Color(0xFF1D3958)),
              SizedBox(width: 6),
              Text(
                'Standar Enkripsi AES-256',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: Color(0xFF595D78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        // Lock App Button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LumiPinScreen(),
              ),
            );
          },
          icon: const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF1D3958)),
          label: const Text(
            'Kunci Ruang Teduh Sementara',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3958),
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD8A4B1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Reassurance Quote
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Setiap perasaanmu berharga dan valid. Beristirahatlah kapan pun tubuhmu meminta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.5,
              color: Color(0xFF73777E),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
