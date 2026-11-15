import 'package:flutter/material.dart';
import '../../core/theme/lumi_theme.dart';
import '../layout/main_layout.dart';

/// ============================================================================
/// LAYAR PENDAFTARAN (REGISTRATION SCREEN)
/// ============================================================================
class RegistrasiScreen extends StatelessWidget {
  const RegistrasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final pinController = TextEditingController();

    return Scaffold(
      backgroundColor: LumiColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mulai Langkah Pertama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang di Lumi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tempat aman untuk mencatat jejak harian tanpa penghakiman. Cukup nama panggilan dan PIN privasi.',
                style: TextStyle(fontSize: 12, color: LumiColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Panggilanmu',
                  hintText: 'Misal: Budi / Kawan Lumi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Buat 4 Digit PIN Privasi',
                  hintText: '****',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
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
                  child: const Text('Buat Ruang Teduh Saya', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
