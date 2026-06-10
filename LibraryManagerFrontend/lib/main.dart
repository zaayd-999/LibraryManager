import 'dart:ui';
import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/my_books/my_books_page.dart';
import 'services/borrow_api.dart';

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
  int _borrowedCount = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MyBooksPage(),
    const Center(child: Text('Profile Page (To be created)')),
  ];

  @override
  void initState() {
    super.initState();
    _loadBorrowedCount();
  }

  Future<void> _loadBorrowedCount() async {
    try {
      final books = await BorrowApi.getBorrows();

      setState(() {
        _borrowedCount = books.length;
      });
    } catch (e) {
      print(e);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      _loadBorrowedCount();
    }
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
              label: Text(
                '$_borrowedCount',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              child: const Icon(Icons.menu_book_outlined),
            ),
            activeIcon: Badge(
              label: Text(
                '$_borrowedCount',
                style: const TextStyle(color: Colors.white),
              ),
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