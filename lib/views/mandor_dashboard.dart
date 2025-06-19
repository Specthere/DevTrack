import 'package:devtrack/views/laporan_page.dart';
import 'package:flutter/material.dart';
import 'package:devtrack/views/profile_page.dart';
import 'project_list_page.dart';
import 'riwayat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MandorDashboard extends StatefulWidget {
  const MandorDashboard({super.key});
  
  @override
  State<MandorDashboard> createState() => _MandorDashboardState();
}

class _MandorDashboardState extends State<MandorDashboard> {
  int _currentIndex = 0;
  int _previousIndex = 0; // Untuk menyimpan index sebelumnya
  
  // Tetapkan dengan widget placeholder agar tidak null
  List<Widget> _pages = const [
    Scaffold(body: Center(child: Text('Memuat...'))),
    Scaffold(body: Center(child: Text('Memuat...'))),
    Scaffold(body: Center(child: Text('Memuat...'))),
    Scaffold(body: Center(child: Text('Memuat...'))),
  ];
  
  int? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getInt('user_id');
        _userName = prefs.getString('user_name') ?? 'User';
        _userEmail = prefs.getString('user_email') ?? 'user@example.com';
        _isLoading = false;
      });
      
      if (_userId != null) {
        _buildPages(); // Panggil method terpisah untuk build pages
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error jika diperlukan
      debugPrint('Error loading user data: $e');
    }
  }

  // Method terpisah untuk build pages agar bisa dipanggil ulang jika diperlukan
  void _buildPages() {
    if (_userId != null) {
      setState(() {
        _pages = [
          ProjectListPage(userId: _userId!),
          LaporanPage(),
          RiwayatPage(userId: _userId!,), // Uncomment jika ada halaman riwayat
    
          // Wrap ProfileMandorPage dengan callback untuk back navigation
          _buildProfilePage(),
        ];
      });
    }
  }

  // Method untuk membangun halaman profile dengan callback
  Widget _buildProfilePage() {
    return ProfileMandorPage(
      userId: _userId!,
      userName: _userName!,
      userEmail: _userEmail!,
      onBackPressed: () {
        // Kembali ke tab sebelumnya atau ke tab pertama jika sebelumnya juga profile
        setState(() {
          // Jika sebelumnya juga di profile (index 3), kembali ke tab pertama
          if (_previousIndex == 3) {
            _currentIndex = 0; // Kembali ke tab Proyek
          } else {
            _currentIndex = _previousIndex;
          }
        });
      },
    );
  }

  // Method untuk handle tab navigation
  void _onTabTapped(int index) {
    setState(() {
      _previousIndex = _currentIndex; // Simpan index sebelumnya
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1CA5B8)),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat dashboard...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Kalau user ID belum didapat dan sudah bukan loading, arahkan ke login
    if (_userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Data pengguna tidak ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CA5B8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan dashboard normal dengan IndexedStack
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1CA5B8),
          unselectedItemColor: const Color(0xFFB0BEC5),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.edit_document, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.edit_document, size: 26),
              ),
              label: 'Proyek',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.analytics_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.analytics, size: 26),
              ),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.lock_clock, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.lock_clock, size: 26),
              ),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person, size: 26),
              ),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}