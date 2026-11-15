import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/lumi_theme.dart';
import 'providers/lumi_provider.dart';
import 'screens/auth/lumi_auth_screens.dart';
import 'screens/auth/lumi_splash_screen.dart';
import 'screens/layout/main_layout.dart';
import 'screens/layout/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LumiApp());
}

/// ============================================================================
/// LUMI APP: RUANG TEDUH & JEJAK HARIAN
/// ============================================================================
class LumiApp extends StatelessWidget {
  const LumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LumiProvider()..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Lumi — Ruang Teduh & Jejak Harian',
        debugShowCheckedModeBanner: false,
        theme: LumiTheme.lightTheme,
        home: const LumiSplashScreen(),
        routes: {
          '/splash': (context) => const LumiSplashScreen(),
          '/login': (context) => const LumiLoginScreen(),
          '/welcome': (context) => const LumiWelcomeScreen(),
          '/register': (context) => const LumiRegisterScreen(),
          '/biometric': (context) => const LumiBiometricScreen(),
          '/pin': (context) => const LumiPinScreen(),
          '/home': (context) => const MainLayoutScreen(),
          '/settings': (context) => const SettingScreen(),
        },
      ),
    );
  }
}
