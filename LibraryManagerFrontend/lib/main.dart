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
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index == 0) {
      _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (_selectedIndex == 0) {
          final canPop = await _homeNavigatorKey.currentState?.maybePop() ?? false;
          if (canPop) return;
        }
        
        // If we can't pop internally, we could allow the app to exit or minimize.
        // For simplicity in this context, we just don't handle the 'exit' here 
        // which might require setting canPop: true under certain conditions.
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            Navigator(
              key: _homeNavigatorKey,
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => const HomePage(),
                );
              },
            ),
            const Center(child: Text('My Books Page (By Zaayd)')),
            const Center(child: Text('Profile Page (To be created)')),
          ],
        ),
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
    ));
  }
}