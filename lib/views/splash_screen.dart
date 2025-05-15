import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSplash = true;
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Mulai animasi fade-in logo
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });

    // Setelah delay, tampilkan halaman welcome
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSplash ? _buildSplashView() : _buildWelcomeView(),
      ),
    );
  }

  Widget _buildSplashView() {
    return Container(
      key: const ValueKey(1),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB3DFFF), Color(0xFF008CFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: AnimatedOpacity(
          opacity: _logoOpacity,
          duration: const Duration(seconds: 1),
          child: Image.asset('assets/logo.png', width: 150, height: 150),
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Container(
      key: const ValueKey(2),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 220, // total tinggi area atas
            child: Stack(
              children: [
                // Kotak biru pendek
                Container(
                  height: 150, // tinggi kotak birunya kamu bisa ubah sesukamu
                  width: double.infinity,
                  color: const Color(0xFF1DA1B2),
                ),

                // Wave di bawah tetap di posisi bawah
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipPath(
                    clipper: BottomWaveClipper(),
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      color: const Color(0xFF1DA1B2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Selamat datang di DevTrack, kelola dan pantau progres proyek dengan mudah, transparan, dan efisien.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Selanjutnya", style: TextStyle(color: Colors.black54)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

        ],
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Mulai dari kiri atas
    path.lineTo(0, size.height * 0.90);

    // Gelombang pertama
    path.quadraticBezierTo(
      size.width * 0.20, size.height * 0.70,
      size.width * 0.5, size.height * 0.90,
    );

    // Gelombang kedua
    path.quadraticBezierTo(
      size.width * 0.80, size.height,
      size.width, size.height * 0.70,
    );

    // Tutup path ke kanan atas
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
