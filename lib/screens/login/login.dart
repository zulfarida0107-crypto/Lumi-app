import 'package:flutter/material.dart';
import '../../core/theme/lumi_theme.dart';
import '../layout/main_layout.dart';
import '../registrasi/registrasi.dart';

/// ============================================================================
/// LAYAR MASUK (LOGIN SCREEN)
/// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumiColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Maskot Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: LumiColors.mutedNavy,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lumi',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ruang Teduh & Jejak Harian',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Form Input
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email atau Nama Panggilan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'PIN atau Kata Sandi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Masuk
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LumiColors.mutedNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Masuk ke Ruang Teduh', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 16),

                // Link Daftar
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistrasiScreen()),
                    );
                  },
                  child: const Text(
                    'Belum punya akun? Mulai langkah pertamamu di sini.',
                    style: TextStyle(fontSize: 12, color: LumiColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
