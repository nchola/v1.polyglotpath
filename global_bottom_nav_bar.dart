// global_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const GlobalBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Color.fromARGB(255, 30, 162, 153),
          unselectedItemColor: Color.fromARGB(255, 158, 158, 158),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: onItemTapped,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color.fromARGB(255, 30, 162, 153),
          ),
          unselectedLabelStyle: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color.fromARGB(255, 158, 158, 158),
          ),
          iconSize: 28,
          elevation: 10,
        ),
      ),
    );
  }
}
