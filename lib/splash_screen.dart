import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Tambahkan 'SingleTickerProviderStateMixin'
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Variabel untuk mengontrol visibilitas teks
  double _opacitySelamat = 0.0;
  double _opacityDatang = 0.0;
  double _opacityDiBlangkis = 0.0;

  // Timer untuk navigasi dan animasi
  Timer? _navigationTimer;
  Timer? _textAnimationTimer1;
  Timer? _textAnimationTimer2;

  @override
  void initState() {
    super.initState();
    _startAnimationsAndNavigation();
  }

  void _startAnimationsAndNavigation() {
    // Timer 1: Munculkan "Selamat"
    _textAnimationTimer1 = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _opacitySelamat = 1.0);
    });

    // Timer 2: Munculkan sisa teks
    _textAnimationTimer2 = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _opacityDatang = 1.0;
          _opacityDiBlangkis = 1.0;
        });
      }
    });

    // Timer Navigasi
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      // Durasi total splash screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Batalkan semua timer
    _navigationTimer?.cancel();
    _textAnimationTimer1?.cancel();
    _textAnimationTimer2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFDF5E6); // Warna Krem
    const Color textColor = Color(0xFF5D4037); // Warna Coklat Tua

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Blangkis
            Image.asset(
              'assets/images/logo.png',
              height: 150,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.storefront, size: 100, color: textColor),
            ),
            const SizedBox(height: 30),

            // Animasi Teks dalam Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _opacitySelamat,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "Selamat ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _opacityDatang,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "Datang ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _opacityDiBlangkis,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "di Blangkis",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30), 
            const CircularProgressIndicator(
              color: textColor, 
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
