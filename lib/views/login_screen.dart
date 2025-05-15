import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
              height: size.height * 0.45,
              color: const Color(0xFF1CA5B8), // warna biru tua
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.35),
                  const Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: "kelompok3pbm@gmai.com",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Masukkan kata sandi anda",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (_) {}),
                          const Text("Ingatkan Saya", style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Lupa Password ?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1CA5B8),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1CA5B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
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
    path.lineTo(0, size.height * 0.85);

    // Gelombang 1
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.70,
      size.width * 0.5, size.height * 0.85,
    );

    // Gelombang 2
    path.quadraticBezierTo(
      size.width * 0.75, size.height,
      size.width, size.height * 0.85,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
