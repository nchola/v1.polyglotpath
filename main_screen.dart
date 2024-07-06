// main_screen.dart

import 'package:flutter/material.dart';
import 'package:polyglotpath/home_screen.dart';
import 'package:polyglotpath/screens/profile/profile_screen.dart';
import 'package:polyglotpath/screens/favorite/favorites_screen.dart';
import 'package:polyglotpath/screens/forum/community_forum_screen.dart';
import 'package:polyglotpath/widgets/global_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  MainScreen({this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    HomeScreen(),
    FavoritesScreen(),
    CommunityForumScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: GlobalBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
