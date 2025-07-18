import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const Navbar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  Widget _buildIcon(String imagePath, int index) {
    bool isActive = currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? const Color.fromRGBO(134, 182, 246, 0.8) : Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        imagePath,
        color: isActive ? Colors.white : Colors.grey,
        width: 36,
        height: 36,
      ),
    );
  }

  Widget _buildIconWidget(IconData iconData, int index) {
    bool isActive = currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? const Color.fromRGBO(134, 182, 246, 0.8) : Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        iconData,
        color: isActive ? Colors.white : Colors.grey,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues( 
              alpha: 0.5,
            ),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/monitoring.png', 0),
              label: 'Monitoring',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/helmetIcon.png', 1),
              label: 'Mandor',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/manajemen_proyek.png', 2), // Folder icon di tengah
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/riwayat.png', 3),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWidget(Icons.person, 4), // Icon profile menggunakan Icons.person
              label: 'Profile',
            ),
          ],
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 30,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }
}