import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibraryMate',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF0A7A8A),
        scaffoldBackgroundColor: const Color(0xFFF5F7F9),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Pages for the navigation bar
  // Hna 7to les pages dyalkom !!!!
  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('My Books Page (By Zaayd)')),
    const Center(child: Text('Profile Page (To be created)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0A7A8A),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('2', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              child: const Icon(Icons.menu_book_outlined),
            ),
            activeIcon: Badge(
              label: const Text('2', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              child: const Icon(Icons.menu_book),
            ),
            label: 'My Books',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}