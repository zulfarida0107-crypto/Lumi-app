import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import '../../providers/lumi_provider.dart';
import '../hari-ini/hari_ini.dart';
import '../catatan/catatan.dart';
import '../matriks/matriks_bulanan.dart';
import '../sheets/sheets.dart';
import 'lumi_header.dart';
import 'lumi_navigator.dart';

/// ============================================================================
/// LAYAR UTAMA (MAIN LAYOUT)
/// ============================================================================
/// Mengintegrasikan komponen modular:
/// 1. Top Bar: [LumiHeader] (Memuat Maskot Resmi, Tombol Darurat & Settings)
/// 2. Body: [IndexedStack] (4 Tab: Hari Ini, Catatan, Matriks, Sheet)
/// 3. Bottom Bar: [LumiNavigator] (Navigasi 4 Tab + Tombol (+) Melayang)
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0; // Default Tab: 0 (Hari Ini)

  final List<Widget> _screens = const [
    HariIniScreen(),
    CatatanScreen(),
    MatriksScreen(),
    SheetsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FA),
      // 1. Header Resmi Terpisah (Ikon Maskot, Tombol Darurat, Settings)
      appBar: const LumiHeader(),
      // 2. Konten Layar Aktif
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // 3. Navigator Bawah Terpisah
      bottomNavigationBar: LumiNavigator(
        currentIndex: _currentIndex,
        onTabSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
      ),
    );
  }
}

@Preview(name: 'Lumi Modular Layout')
Widget previewMainLayout() {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => LumiProvider())],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainLayoutScreen(),
    ),
  );
}
