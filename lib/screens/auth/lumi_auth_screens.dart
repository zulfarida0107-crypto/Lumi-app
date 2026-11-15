import 'dart:async';
import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

/// ============================================================================
/// RANGKAIAN LAYAR AUTENTIKASI & KEAMANAN RUANG TEDUH LUMI
/// ============================================================================
/// Mencakup 5 layar sesuai desain HTML:
/// 1. [LumiLoginScreen]     — Halaman Masuk Utama (Biometrik, PIN, Email & Sandi)
/// 2. [LumiWelcomeScreen]   — Sambutan Hangat (muncul dari tombol "Masuk ke Lumi")
/// 3. [LumiRegisterScreen]  — Daftar Akun Baru + Janji Privasi Lumi Modal
/// 4. [LumiBiometricScreen] — Verifikasi Sidik Jari Interaktif
/// 5. [LumiPinScreen]       — Kunci PIN Privasi 4-Digit (Dialpad 3x4)

// =============================================================================
// PENYIMPANAN STATUS AKUN TERDAFTAR (WAJIB DAFTAR AKUN DULU SEBELUM MASUK)
// =============================================================================
class LumiAuthStore {
  static String? registeredNickname;
  static String? registeredEmail;
  static String? registeredPassword;
  static String? registeredPin;
  static bool biometricEnabled = false;

  static bool get hasAccount =>
      registeredEmail != null &&
      registeredEmail!.isNotEmpty &&
      registeredPassword != null &&
      registeredPassword!.isNotEmpty;

  static void registerAccount({
    required String nickname,
    required String email,
    required String password,
    required bool enableBiometric,
    String pin = '1234',
  }) {
    registeredNickname = nickname.trim().isNotEmpty
        ? nickname.trim()
        : 'Kawan Tenang';
    registeredEmail = email.trim().toLowerCase();
    registeredPassword = password;
    biometricEnabled = enableBiometric;
    if (registeredPin == null || registeredPin!.isEmpty) {
      registeredPin = pin;
    }
  }
}

// =============================================================================
// 1. LAYAR MASUK UTAMA (LOGIN SCREEN)
// =============================================================================
class LumiLoginScreen extends StatefulWidget {
  const LumiLoginScreen({super.key});

  @override
  State<LumiLoginScreen> createState() => _LumiLoginScreenState();
}

class _LumiLoginScreenState extends State<LumiLoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _promptMustRegisterFirst() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9E1).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 19,
                  color: Color(0xFF30111B),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Belum Ada Akun Terdaftar',
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
          content: const Text(
            'Kamu harus memiliki akun terlebih dahulu sebelum dapat mengakses Ruang Teduh Lumi. Yuk, daftar akun barumu sekarang.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF595D78),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Nanti',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF595D78),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LumiRegisterScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF355070),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleEmailLogin() {
    if (!LumiAuthStore.hasAccount) {
      _promptMustRegisterFirst();
      return;
    }

    final inputUser = _emailCtrl.text.trim().toLowerCase();
    final inputPwd = _passwordCtrl.text;

    if (inputUser.isEmpty || inputPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan email/nama panggilan dan kata sandimu terlebih dahulu.'),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      return;
    }

    final validEmail = LumiAuthStore.registeredEmail?.toLowerCase() ?? '';
    final validAlias = LumiAuthStore.registeredNickname?.toLowerCase() ?? '';

    if ((inputUser != validEmail && inputUser != validAlias) ||
        inputPwd != LumiAuthStore.registeredPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email/nama pengguna atau kata sandi tidak sesuai dengan akun terdaftar.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LumiWelcomeScreen(
          initialNickname: LumiAuthStore.registeredNickname ?? 'Kawan Tenang',
        ),
      ),
    );
  }

  void _handleGoogleLogin() {
    if (!LumiAuthStore.hasAccount) {
      _promptMustRegisterFirst();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LumiWelcomeScreen(
          initialNickname: LumiAuthStore.registeredNickname ?? 'Kawan Tenang',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: Stack(
        children: [
          // Ambient Glow Blobs
          Positioned(
            top: -64,
            right: -64,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD9E1).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFDEE0FF).withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header: Brand Identifier & Tactile Emblem
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF355070)
                                      .withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/public/lumi_app_icon.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFFFD9E1),
                                child: const Icon(
                                  Icons.spa_rounded,
                                  size: 40,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Lumi',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ruang Teduh & Jejak Harian',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                              color: Color(0xFF595D78),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // 2. Warm & Compassionate Sanctuary Greeting
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF355070)
                                  .withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Selamat datang kembali di ruang teduhmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Quick & Frictionless Biometric / PIN Sign-in Card
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Masuk Cepat & Aman',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAuthCard(
                              icon: Icons.fingerprint_rounded,
                              iconBg: const Color(0xFFF1EDEF),
                              iconColor: const Color(0xFF355070),
                              title: 'Sidik Jari',
                              subtitle: 'atau Face ID',
                              onTap: () {
                                if (!LumiAuthStore.hasAccount) {
                                  _promptMustRegisterFirst();
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LumiBiometricScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickAuthCard(
                              icon: Icons.pin_outlined,
                              iconBg: const Color(0xFFFFD9E1)
                                  .withValues(alpha: 0.65),
                              iconColor: const Color(0xFF30111B),
                              title: 'Kunci PIN',
                              subtitle: 'Privasi Akun',
                              onTap: () {
                                if (!LumiAuthStore.hasAccount) {
                                  _promptMustRegisterFirst();
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LumiPinScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 4. Soft Subtle Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'atau masuk dengan email',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 5. Credentials Form
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Email / Nama Pengguna',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14.5,
                          color: Color(0xFF1D3958),
                        ),
                        decoration: InputDecoration(
                          hintText: 'teman@teduh.id',
                          hintStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color:
                                const Color(0xFF595D78).withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            size: 20,
                            color: Color(0xFF595D78),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFF355070),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kata Sandi',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595D78),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tautan pemulihan kata sandi dikirim ke email terdaftar.',
                                    ),
                                    backgroundColor: Color(0xFF1D3958),
                                  ),
                                );
                              },
                              child: const Text(
                                'Lupa kata sandi?',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF355070),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14.5,
                          color: Color(0xFF1D3958),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ketik kata sandi rahasia',
                          hintStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color:
                                const Color(0xFF595D78).withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: Color(0xFF595D78),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: const Color(0xFF595D78),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFF355070),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 6. Primary Action: Masuk ke Lumi -> Membuka Sambutan Hangat
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF355070),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0xFF355070)
                                .withValues(alpha: 0.28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Masuk ke Lumi',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 7. Alternative Social Login: Google
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.45),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGoogleBadge(),
                              const SizedBox(width: 10),
                              const Text(
                                'Lanjutkan dengan Akun Google',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 8. Footer: Registration Anchor
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Belum memiliki ruang pribadi di Lumi? ',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                color: Color(0xFF595D78),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LumiRegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Daftar Akun Baru',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D3958),
                                  decoration: TextDecoration.underline,
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAuthCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFC3C6CE).withValues(alpha: 0.35),
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 25, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3958),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
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
    );
  }
}

Widget _buildGoogleBadge() {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFE5E1E3)),
      color: Colors.white,
    ),
    alignment: Alignment.center,
    child: const Text(
      'G',
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4285F4),
      ),
    ),
  );
}

// =============================================================================
// 2. LAYAR SAMBUTAN HANGAT (WELCOME SCREEN — DARI TOMBOL "MASUK KE LUMI")
// =============================================================================
class LumiWelcomeScreen extends StatefulWidget {
  final String initialNickname;

  const LumiWelcomeScreen({
    super.key,
    this.initialNickname = 'Kawan Tenang',
  });

  @override
  State<LumiWelcomeScreen> createState() => _LumiWelcomeScreenState();
}

class _LumiWelcomeScreenState extends State<LumiWelcomeScreen> {
  late String _nickname = widget.initialNickname;

  void _editNicknameDialog() {
    final ctrl = TextEditingController(text: _nickname);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Ubah Nama Panggilan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3958),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bagaimana Lumi boleh menyapamu dengan tenang?',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  color: Color(0xFF595D78),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Kawan Tenang',
                  filled: true,
                  fillColor: const Color(0xFFFCF8FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: const Color(0xFFC3C6CE).withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
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
                final val = ctrl.text.trim();
                if (val.isNotEmpty) {
                  setState(() {
                    _nickname = val;
                  });
                  LumiAuthStore.registeredNickname = val;
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D3958),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _enterMainApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: Stack(
        children: [
          // Atmospheric Ambient Glow Blobs
          Positioned(
            top: -64,
            left: -64,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD9E1).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFDEE0FF).withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 8),

                      // Main Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              // Hero Mascot Area with Soft Glowing Aura
                              Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 144,
                                    height: 144,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD9E1)
                                          .withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 112,
                                    height: 112,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: const Color(0xFFEEB8C6)
                                            .withValues(alpha: 0.5),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF355070)
                                              .withValues(alpha: 0.1),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Image.asset(
                                        'assets/public/lumi_app_icon.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.spa_rounded,
                                          size: 48,
                                          color: Color(0xFF1D3958),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    top: -8,
                                    right: -6,
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 22,
                                      color: Color(0xFFEEB8C6),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Welcome Headlines & Empathetic Narrative
                              const Text(
                                'Selamat Datang di Ruang Teduhmu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D3958),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Akun dan ruang amanmu telah siap. Mulai hari ini, setiap perasaan, lelah, dan detak harimu memiliki tempat bersandar yang tenang, tanpa tuntutan, dan terjaga kerahasiaannya.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14.5,
                                    height: 1.5,
                                    color: Color(0xFF595D78),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Personalization Card: Nama Panggilan Nyaman
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFFFD9E1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF355070)
                                          .withValues(alpha: 0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFD9E1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.face_rounded,
                                            size: 22,
                                            color: Color(0xFF30111B),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Mulai dengan Nama Panggilan',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF595D78),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  _nickname,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1D3958),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFEEB8C6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: _editNicknameDialog,
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF6F2F4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: Color(0xFF1D3958),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Actions Container
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _enterMainApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D3958),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(0xFF1D3958)
                                    .withValues(alpha: 0.25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text(
                                'Masuk ke Ruang Hari Ini',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LumiPinScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                size: 18,
                                color: Color(0xFF1D3958),
                              ),
                              label: const Text(
                                'Atur Kunci Biometrik / PIN Sekarang',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D3958),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFFEBE7E9),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. LAYAR DAFTAR AKUN BARU (REGISTER SCREEN)
// =============================================================================
class LumiRegisterScreen extends StatefulWidget {
  const LumiRegisterScreen({super.key});

  @override
  State<LumiRegisterScreen> createState() => _LumiRegisterScreenState();
}

class _LumiRegisterScreenState extends State<LumiRegisterScreen> {
  final TextEditingController _aliasCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _biometricEnabled = true;
  bool _agreedToPrivacy = true;

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showPrivacyPledgeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 640),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
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
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE7E9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.lock_person_outlined,
                        size: 24,
                        color: Color(0xFF1D3958),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Janji Privasi Lumi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3958),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF595D78),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '1. Enkripsi Sisi Klien: Catatan perasaan, jadwal obat, dan riwayat tidurmu dienkripsi sebelum disimpan.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF595D78),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. Bebas Jual-Beli Data: Kami tidak pernah menjual atau membagikan catatan kesehatan mental ke pihak ketiga atau platform iklan mana pun.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF595D78),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. Hak Penghapusan Mutlak: Kamu dapat menghapus akun dan semua rekam jejak harianmu kapan saja dengan satu kali klik tanpa syarat.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF595D78),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBE7E9),
                    foregroundColor: const Color(0xFF1D3958),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Saya Mengerti',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitRegister() {
    final alias = _aliasCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (alias.isEmpty || email.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi nama panggilan, alamat email, dan kata sandi terlebih dahulu.',
          ),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      return;
    }

    if (pwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi minimal 6 karakter agar akunmu tetap aman.'),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      return;
    }

    if (pwd != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi belum cocok.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    if (!_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan setujui Komitmen Privasi & Ruang Aman Lumi terlebih dahulu.',
          ),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      return;
    }

    LumiAuthStore.registerAccount(
      nickname: alias,
      email: email,
      password: pwd,
      enableBiometric: _biometricEnabled,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LumiWelcomeScreen(initialNickname: alias),
      ),
    );
  }

  void _quickGoogleRegister() {
    if (!_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan setujui Komitmen Privasi & Ruang Aman Lumi terlebih dahulu.',
          ),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      return;
    }
    final nickname = _aliasCtrl.text.trim().isNotEmpty
        ? _aliasCtrl.text.trim()
        : 'Kawan Tenang';
    final email = _emailCtrl.text.trim().isNotEmpty
        ? _emailCtrl.text.trim()
        : 'teman@teduh.id';
    final pwd = _passwordCtrl.text.isNotEmpty
        ? _passwordCtrl.text
        : 'lumi1234';

    LumiAuthStore.registerAccount(
      nickname: nickname,
      email: email,
      password: pwd,
      enableBiometric: _biometricEnabled,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LumiWelcomeScreen(initialNickname: nickname),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdLen = _passwordCtrl.text.length;
    String strengthText = 'Cukup aman & mudah kamu ingat';
    int activeBars = 2;
    Color barColor = const Color(0xFF355070);

    if (pwdLen > 0 && pwdLen < 6) {
      strengthText = 'Beri sedikit karakter lagi agar lebih kokoh';
      activeBars = 1;
      barColor = const Color(0xFFFFD9E1);
    } else if (pwdLen >= 6 && pwdLen < 10) {
      strengthText = 'Bagus! Mudah diingat dan cukup tenang';
      activeBars = 2;
      barColor = const Color(0xFF355070);
    } else if (pwdLen >= 10) {
      strengthText = 'Sempurna & sangat terlindungi ✨';
      activeBars = 3;
      barColor = const Color(0xFF355070);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar Back Button
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC3C6CE)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Color(0xFF595D78),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Warm Greeting & Reassurance Hero
                  const Text(
                    'Mulai Ruang Teduh Pribadimu',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3958),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tempat aman untuk mencatat ritme tidur dan perasaanmu tanpa penghakiman.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14.5,
                      color: Color(0xFF595D78),
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Registration Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color:
                            const Color(0xFFC3C6CE).withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF355070).withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input 1: Nama Panggilan / Alias
                        const Text(
                          'Nama Panggilan / Alias',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRoundedField(
                          controller: _aliasCtrl,
                          hintText: 'Contoh: Kawan Tenang',
                          prefixIcon: Icons.sentiment_satisfied_outlined,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: const [
                            Icon(
                              Icons.visibility_off_outlined,
                              size: 14,
                              color: Color(0xFF1D3958),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Nama bebas demi kenyamanan privasimu.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11.5,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Input 2: Alamat Email Aktif
                        const Text(
                          'Alamat Email Aktif',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRoundedField(
                          controller: _emailCtrl,
                          hintText: 'alamatmu@domain.com',
                          prefixIcon: Icons.mail_outline_rounded,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: const [
                            Icon(
                              Icons.lock_clock_outlined,
                              size: 14,
                              color: Color(0xFF1D3958),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Untuk cadangan & pemulihan data terenkripsi.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11.5,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Input 3: Kata Sandi Baru + Strength Indicator
                        const Text(
                          'Kata Sandi Baru',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRoundedField(
                          controller: _passwordCtrl,
                          hintText: 'Minimal 6 karakter yang nyaman',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: const Color(0xFF595D78),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Gentle Password Strength Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDEF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFD9E1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        strengthText,
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
                              ),
                              Row(
                                children: List.generate(3, (i) {
                                  final isFilled = i < activeBars;
                                  return Container(
                                    width: 22,
                                    height: 6,
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: isFilled
                                          ? barColor
                                          : const Color(0xFFEBE7E9),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Input 4: Konfirmasi Kata Sandi
                        const Text(
                          'Konfirmasi Kata Sandi',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3958),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRoundedField(
                          controller: _confirmCtrl,
                          hintText: 'Ketik ulang kata sandi',
                          prefixIcon: Icons.password_rounded,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: const Color(0xFF595D78),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFEBE7E9)),
                        const SizedBox(height: 10),

                        // Biometric / 4-Digit Quick PIN Toggle
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCF8FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC3C6CE)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Switch(
                                value: _biometricEnabled,
                                activeThumbColor: const Color(0xFF355070),
                                onChanged: (val) {
                                  setState(() {
                                    _biometricEnabled = val;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aktifkan Kunci Biometrik / PIN 4-digit',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1D3958),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Langsung aktif saat membuka aplikasi agar catatan hatimu tetap terlindungi.',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11.5,
                                        color: Color(0xFF595D78),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Privacy Pledge Agreement Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToPrivacy,
                              activeColor: const Color(0xFF355070),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _agreedToPrivacy = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text(
                                    'Saya setuju dengan ',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: Color(0xFF595D78),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _showPrivacyPledgeModal,
                                    child: const Text(
                                      'Komitmen Privasi & Ruang Aman Lumi',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1D3958),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Primary Button: Buat Ruang Teduh
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _submitRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF355070),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF355070)
                                  .withValues(alpha: 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Buat Ruang Teduh',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fast Alternative Option
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color:
                              const Color(0xFFC3C6CE).withValues(alpha: 0.4),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau mulai lebih tenang',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF595D78),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color:
                              const Color(0xFFC3C6CE).withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _quickGoogleRegister,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color:
                              const Color(0xFFC3C6CE).withValues(alpha: 0.45),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleBadge(),
                          const SizedBox(width: 10),
                          const Text(
                            'Daftar Cepat dengan Akun Google',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          'Sudah memiliki akun Lumi? ',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: Color(0xFF595D78),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Masuk di sini',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                              decoration: TextDecoration.underline,
                            ),
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
      ),
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        color: Color(0xFF1C1B1D),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13.5,
          color: const Color(0xFF595D78).withValues(alpha: 0.55),
        ),
        prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF595D78)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF6F2F4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: const Color(0xFFC3C6CE).withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: const Color(0xFFC3C6CE).withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(
            color: Color(0xFF355070),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. LAYAR VERIFIKASI SIDIK JARI (BIOMETRIC SCREEN)
// =============================================================================
class LumiBiometricScreen extends StatefulWidget {
  const LumiBiometricScreen({super.key});

  @override
  State<LumiBiometricScreen> createState() => _LumiBiometricScreenState();
}

class _LumiBiometricScreenState extends State<LumiBiometricScreen> {
  String _statusText = 'Sensor Siap Dipindai';
  bool _isScanning = false;
  bool _isVerified = false;

  void _simulateScan() {
    if (!LumiAuthStore.hasAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harus memiliki akun terdaftar terlebih dahulu sebelum menggunakan Sidik Jari.'),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LumiRegisterScreen()),
      );
      return;
    }
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _statusText = 'Memeriksa Sidik Jari...';
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isVerified = true;
        _statusText = 'Terverifikasi! Membuka Jurnal...';
      });
    });

    Future.delayed(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Navigation Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Color(0xFF595D78),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Batal',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Content: Biometric Prompt Section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Tactile Sensory Biometric Center Stage
                          GestureDetector(
                            onTap: _simulateScan,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD9E1)
                                        .withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 168,
                                  height: 168,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFEEB8C6)
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    color: _isVerified
                                        ? const Color(0xFFB5EAD7)
                                            .withValues(alpha: 0.45)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isScanning
                                          ? const Color(0xFF84A98C)
                                          : const Color(0xFFEEB8C6),
                                      width: _isScanning ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF355070)
                                            .withValues(alpha: 0.08),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.fingerprint_rounded,
                                    size: 56,
                                    color: _isVerified
                                        ? const Color(0xFF1D3958)
                                        : const Color(0xFF355070),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Live Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFEBE7E9),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isVerified
                                        ? const Color(0xFF84A98C)
                                        : const Color(0xFF355070),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _statusText,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D3958),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Pindai Sidik Jari Anda',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Sentuh sensor sidik jari di atas untuk membuka lembar jurnal pribadimu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Security & Privacy Reassurance Island
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFC3C6CE)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD2E4FF)
                                        .withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_outlined,
                                    size: 18,
                                    color: Color(0xFF1D3958),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Privasi Terjamin',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1D3958),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Sidik jari diproses secara lokal oleh sistem keamanan perangkatmu dan tidak pernah dikirim ke internet.',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12,
                                          height: 1.4,
                                          color: Color(0xFF595D78),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Alternative Unlock Actions
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LumiPinScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.dialpad_rounded,
                                size: 19,
                                color: Color(0xFF355070),
                              ),
                              label: const Text(
                                'Gunakan Kunci PIN 4-Digit',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF355070),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFFEEB8C6),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.password_rounded,
                              size: 16,
                              color: Color(0xFF595D78),
                            ),
                            label: const Text(
                              'Masuk dengan Kata Sandi Akun',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595D78),
                              ),
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
    );
  }
}

// =============================================================================
// 5. LAYAR KUNCI PIN PRIVASI 4-DIGIT (PIN SCREEN)
// =============================================================================
class LumiPinScreen extends StatefulWidget {
  const LumiPinScreen({super.key});

  @override
  State<LumiPinScreen> createState() => _LumiPinScreenState();
}

class _LumiPinScreenState extends State<LumiPinScreen> {
  String _enteredPin = '';

  void _onDigitTap(String digit) {
    if (!LumiAuthStore.hasAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harus memiliki akun terdaftar terlebih dahulu sebelum membuka Kunci PIN.'),
          backgroundColor: Color(0xFF1D3958),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LumiRegisterScreen()),
      );
      return;
    }
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
    });
    if (_enteredPin.length == 4) {
      LumiAuthStore.registeredPin = _enteredPin;
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
          (route) => false,
        );
      });
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      ('1', ''),
      ('2', 'ABC'),
      ('3', 'DEF'),
      ('4', 'GHI'),
      ('5', 'JKL'),
      ('6', 'MNO'),
      ('7', 'PQRS'),
      ('8', 'TUV'),
      ('9', 'WXYZ'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header Navigation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: Color(0xFF595D78),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Kembali',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main PIN Canvas
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          // Safe Sanctuary Badge Icon
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD9E1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD8A4B1)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 30,
                                  color: Color(0xFF355070),
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFEEB8C6),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    size: 13,
                                    color: Color(0xFF355070),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Masukkan PIN Ruang Teduh',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3958),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Masukkan kode rahasiamu',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: Color(0xFF595D78),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // PIN Dots Display (4 Dots)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFEBE7E9),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(4, (i) {
                                final isFilled = i < _enteredPin.length;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isFilled
                                        ? const Color(0xFF355070)
                                        : const Color(0xFFF6F2F4),
                                    shape: BoxShape.circle,
                                    border: isFilled
                                        ? null
                                        : Border.all(
                                            color: const Color(0xFFC3C6CE),
                                            width: 1.8,
                                          ),
                                    boxShadow: isFilled
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF355070)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: isFilled
                                      ? Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Keypad (3x4 Tactile Dialpad Grid)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: keys.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemBuilder: (ctx, i) {
                                    final digit = keys[i].$1;
                                    final sub = keys[i].$2;
                                    return _buildDialKey(
                                      digit: digit,
                                      sub: sub,
                                      onTap: () => _onDigitTap(digit),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Bottom Row: Sidik Jari | 0 | Hapus
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 64,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LumiBiometricScreen(),
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD9E1)
                                                  .withValues(alpha: 0.45),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.fingerprint_rounded,
                                                  size: 24,
                                                  color: Color(0xFF355070),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Sidik Jari',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF595D78),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: SizedBox(
                                        height: 64,
                                        child: _buildDialKey(
                                          digit: '0',
                                          sub: '+',
                                          onTap: () => _onDigitTap('0'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: SizedBox(
                                        height: 64,
                                        child: InkWell(
                                          onTap: _onBackspace,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.backspace_outlined,
                                                size: 22,
                                                color: Color(0xFF595D78),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
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
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Gunakan Sidik Jari atau masuk melalui email untuk mengatur ulang PIN.',
                                  ),
                                  backgroundColor: Color(0xFF1D3958),
                                ),
                              );
                            },
                            child: const Text(
                              'Lupa PIN?',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595D78),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Security Metadata Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F2F4),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFEBE7E9),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Color(0xFF1D3958),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'AES-256 Enkripsi Perangkat • Dilindungi Sistem Keamanan Lokal',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF595D78),
                            ),
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
      ),
    );
  }

  Widget _buildDialKey({
    required String digit,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFEBE7E9),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF355070).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3958),
                height: 1.0,
              ),
            ),
            if (sub.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: Color(0xFF595D78),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
