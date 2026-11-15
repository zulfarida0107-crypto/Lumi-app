import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'lumi_auth_screens.dart';

/// ============================================================================
/// LAYAR PEMBUKAAN APLIKASI (ANIMATED SPLASH SCREEN) — LUMI
/// ============================================================================
/// Menampilkan animasi maskot Lumi yang dibangun secara interaktif sesuai
/// ikon resmi (Beruang Krem + Tunas Daun Mint di atas latar Navy #2E4765):
/// 1. Kotak ikon Navy muncul dengan efek elastis (scale & glow).
/// 2. Wajah beruang Lumi muncul lembut, berkedip ramah, dan pipi merona.
/// 3. Tunas daun mint di atas kepala tumbuh dan bergoyang perlahan.
/// 4. Teks "Lumi — Ruang Teduh & Jejak Harian" muncul secara bertahap,
///    kemudian berpindah otomatis ke halaman Login dengan transisi halus.
class LumiSplashScreen extends StatefulWidget {
  const LumiSplashScreen({super.key});

  @override
  State<LumiSplashScreen> createState() => _LumiSplashScreenState();
}

class _LumiSplashScreenState extends State<LumiSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _blinkCtrl;

  late final Animation<double> _cardScale;
  late final Animation<double> _bearPop;
  late final Animation<double> _sproutGrow;
  late final Animation<double> _cheeksGlow;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  Timer? _blinkTimer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Controller utama urutan munculnya elemen (2400 ms)
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Controller mengambang & goyangan tunas daun berkelanjutan
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Controller kedipan mata beruang Lumi
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    // 1. Skala kartu ikon Navy (0.0 -> 0.45)
    _cardScale = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    // 2. Munculnya kepala & telinga beruang (0.15 -> 0.60)
    _bearPop = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutBack),
    );

    // 3. Tumbuhnya tunas daun mint di atas kepala (0.40 -> 0.82)
    _sproutGrow = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.40, 0.82, curve: Curves.elasticOut),
    );

    // 4. Rona pipi pink & senyuman hangat (0.45 -> 0.85)
    _cheeksGlow = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    // 5. Teks judul & subjudul di bawah ikon (0.55 -> 1.0)
    _textFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _mainCtrl.forward();

    // Kedipan mata lucu di tengah animasi pembukaan
    _blinkTimer = Timer(const Duration(milliseconds: 1450), () {
      if (!mounted) return;
      _blinkCtrl.forward().then((_) {
        if (mounted) _blinkCtrl.reverse();
      });
    });

    // Navigasi otomatis ke LumiLoginScreen setelah animasi selesai
    _navTimer = Timer(const Duration(milliseconds: 3400), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: const LumiLoginScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _navTimer?.cancel();
    _mainCtrl.dispose();
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FA),
      body: GestureDetector(
        onTap: _goToLogin,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft Ambient Background Blobs
            Positioned(
              top: -70,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9E1).withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE0FF).withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Konten Utama Splash Screen
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Ikon Maskot Beruang & Tunas Daun dengan Animasi Bertahap
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _mainCtrl,
                        _floatCtrl,
                        _blinkCtrl,
                      ]),
                      builder: (context, _) {
                        final floatOffset =
                            math.sin(_floatCtrl.value * math.pi) * 6.0;
                        final leafSway =
                            math.sin(_floatCtrl.value * math.pi * 2) * 0.08;

                        return Transform.translate(
                          offset: Offset(0, -floatOffset),
                          child: Transform.scale(
                            scale: _cardScale.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Lingkaran pendaran cahaya hangat di belakang ikon
                                Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFA8E6CF)
                                            .withValues(alpha: 0.28 * _sproutGrow.value.clamp(0.0, 1.0)),
                                        const Color(0xFFFFD9E1)
                                            .withValues(alpha: 0.22 * _cheeksGlow.value.clamp(0.0, 1.0)),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),

                                // Bingkai Ikon Rounded Square (#2E4765 sesuai gambar ikon)
                                Container(
                                  width: 176,
                                  height: 176,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E4765),
                                    borderRadius: BorderRadius.circular(42),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1D3958)
                                            .withValues(alpha: 0.22),
                                        blurRadius: 28,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(42),
                                    child: CustomPaint(
                                      size: const Size(176, 176),
                                      painter: _LumiMascotSplashPainter(
                                        bearPop: _bearPop.value.clamp(0.0, 1.15),
                                        sproutGrow:
                                            _sproutGrow.value.clamp(0.0, 1.2),
                                        cheeksGlow:
                                            _cheeksGlow.value.clamp(0.0, 1.0),
                                        blinkValue:
                                            _blinkCtrl.value.clamp(0.0, 1.0),
                                        leafSwayAngle: leafSway,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // 2. Teks Judul & Subjudul Lumi
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Lumi',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF1D3958),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ruang Teduh & Jejak Harian',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Color(0xFF595D78),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Indikator Loading Lembut
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFEEB8C6)
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF355070),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Menyiapkan ruang teduhmu...',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF355070),
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

/// CustomPainter yang menggambar ulang secara presisi ikon beruang Lumi + tunas daun
/// sehingga setiap bagiannya (telinga, wajah krem, mata berkedip, pipi merona, dan tunas daun)
/// dapat beranimasi secara halus saat aplikasi dibuka.
class _LumiMascotSplashPainter extends CustomPainter {
  final double bearPop;
  final double sproutGrow;
  final double cheeksGlow;
  final double blinkValue;
  final double leafSwayAngle;

  _LumiMascotSplashPainter({
    required this.bearPop,
    required this.sproutGrow,
    required this.cheeksGlow,
    required this.blinkValue,
    required this.leafSwayAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    // -------------------------------------------------------------------------
    // 1. TUNAS DAUN MINT DI ATAS KEPALA (Tumbuh & Bergoyang Lembut)
    // -------------------------------------------------------------------------
    if (sproutGrow > 0.01) {
      canvas.save();
      final stemBaseX = cx;
      final stemBaseY = cy - 44 * bearPop;
      canvas.translate(stemBaseX, stemBaseY);
      canvas.rotate(leafSwayAngle);
      canvas.scale(sproutGrow, sproutGrow);

      // Batang tunas
      final stemPaint = Paint()
        ..color = const Color(0xFF88D4AB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round;

      final stemPath = Path()
        ..moveTo(0, 6)
        ..quadraticBezierTo(-1, -10, 0, -22);
      canvas.drawPath(stemPath, stemPaint);

      // Daun Kiri
      canvas.save();
      canvas.translate(-2, -18);
      canvas.rotate(-0.55);
      final leafPaint = Paint()
        ..color = const Color(0xFFA8E6CF)
        ..style = PaintingStyle.fill;
      final leafPathLeft = Path()
        ..moveTo(0, 0)
        ..cubicTo(-18, -6, -24, -26, -4, -32)
        ..cubicTo(10, -26, 8, -8, 0, 0)
        ..close();
      canvas.drawPath(leafPathLeft, leafPaint);

      // Tulang daun kiri
      final veinPaint = Paint()
        ..color = const Color(0xFF7BC69D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-1, -3), const Offset(-4, -22), veinPaint);
      canvas.restore();

      // Daun Kanan
      canvas.save();
      canvas.translate(2, -18);
      canvas.rotate(0.55);
      final leafPathRight = Path()
        ..moveTo(0, 0)
        ..cubicTo(18, -6, 24, -26, 4, -32)
        ..cubicTo(-10, -26, -8, -8, 0, 0)
        ..close();
      canvas.drawPath(leafPathRight, leafPaint);
      canvas.drawLine(const Offset(1, -3), const Offset(4, -22), veinPaint);
      canvas.restore();

      canvas.restore();
    }

    // -------------------------------------------------------------------------
    // 2. KEPALA & TELINGA BERUANG KREM LUMI
    // -------------------------------------------------------------------------
    if (bearPop > 0.01) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(bearPop, bearPop);

      final furOuterPaint = Paint()
        ..color = const Color(0xFFF9EFE4)
        ..style = PaintingStyle.fill;
      final earInnerPaint = Paint()
        ..color = const Color(0xFFE3D0C1)
        ..style = PaintingStyle.fill;

      // Telinga Kiri & Kanan
      const earOffsetX = 42.0;
      const earOffsetY = -36.0;
      canvas.drawCircle(
        const Offset(-earOffsetX, earOffsetY),
        19,
        furOuterPaint,
      );
      canvas.drawCircle(
        const Offset(-earOffsetX, earOffsetY),
        10.5,
        earInnerPaint,
      );

      canvas.drawCircle(
        const Offset(earOffsetX, earOffsetY),
        19,
        furOuterPaint,
      );
      canvas.drawCircle(
        const Offset(earOffsetX, earOffsetY),
        10.5,
        earInnerPaint,
      );

      // Kepala Beruang (Bentuk pipi chubby lembut seperti di ikon)
      final headRect = Rect.fromCenter(
        center: const Offset(0, 2),
        width: 112,
        height: 96,
      );
      final headRRect = RRect.fromRectAndCorners(
        headRect,
        topLeft: const Radius.circular(52),
        topRight: const Radius.circular(52),
        bottomLeft: const Radius.circular(46),
        bottomRight: const Radius.circular(46),
      );

      // Bayangan lembut di bagian bawah dagu beruang
      final shadowPaint = Paint()
        ..color = const Color(0xFFEBD9C8)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(headRRect.shift(const Offset(0, 2.5)), shadowPaint);
      canvas.drawRRect(headRRect, furOuterPaint);

      // -----------------------------------------------------------------------
      // 3. RONA PIPI PINK LEMBUT
      // -----------------------------------------------------------------------
      if (cheeksGlow > 0.01) {
        final cheekPaint = Paint()
          ..color =
              const Color(0xFFF6B4C2).withValues(alpha: 0.88 * cheeksGlow)
          ..style = PaintingStyle.fill;

        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(-33, 14),
            width: 22,
            height: 14,
          ),
          cheekPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(33, 14),
            width: 22,
            height: 14,
          ),
          cheekPaint,
        );
      }

      // -----------------------------------------------------------------------
      // 4. MATA BERKEDIP & KILAU MATA
      // -----------------------------------------------------------------------
      final eyePaint = Paint()
        ..color = const Color(0xFF33221A)
        ..style = PaintingStyle.fill;
      final eyeHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final eyeHeight = 14.0 * (1.0 - 0.85 * blinkValue);
      for (final eyeX in [-21.0, 21.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(eyeX, 0),
            width: 14.0,
            height: eyeHeight.clamp(2.0, 14.0),
          ),
          eyePaint,
        );
        if (blinkValue < 0.4) {
          canvas.drawCircle(
            Offset(eyeX - 2.5, -2.5),
            2.4,
            eyeHighlightPaint,
          );
        }
      }

      // -----------------------------------------------------------------------
      // 5. HIDUNG COKELAT PASTEL & SENYUMAN HANGAT
      // -----------------------------------------------------------------------
      final nosePaint = Paint()
        ..color = const Color(0xFF8C736C)
        ..style = PaintingStyle.fill;

      final noseRect = Rect.fromCenter(
        center: const Offset(0, 6),
        width: 10,
        height: 6.5,
      );
      canvas.drawOval(noseRect, nosePaint);

      // Mulut tersenyum
      final smilePaint = Paint()
        ..color = const Color(0xFF8C736C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;

      final smilePath = Path()
        ..moveTo(-10, 14)
        ..quadraticBezierTo(0, 21, 10, 14);
      canvas.drawPath(smilePath, smilePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LumiMascotSplashPainter oldDelegate) {
    return oldDelegate.bearPop != bearPop ||
        oldDelegate.sproutGrow != sproutGrow ||
        oldDelegate.cheeksGlow != cheeksGlow ||
        oldDelegate.blinkValue != blinkValue ||
        oldDelegate.leafSwayAngle != leafSwayAngle;
  }
}
