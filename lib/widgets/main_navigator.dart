import 'package:flutter/material.dart';
import 'package:physio_clinic_appointment/screens/dashboard_screen.dart';
import 'package:physio_clinic_appointment/screens/patients_screen.dart';
import 'package:physio_clinic_appointment/screens/post_screen.dart';
import 'package:physio_clinic_appointment/screens/profile_screen.dart';
import 'package:physio_clinic_appointment/screens/setting_screen.dart';




class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0; // Tracks the current tab index

  final List<Widget> _screens = [
    const DashboardScreen(), // Index 0: Home/Dashboard
    const SettingsScreen(),  // Index 1: Settings
    const PatientsScreen(),  // Index 2: Patients
    const PostsScreen(),     // Index 3: Posts
    const ProfileScreen(),   // Index 4: Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // The currently selected screen is displayed here
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      
        // ⬇️ The Bottom Navigation Bar ⬇️
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Posts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0FAF7C), // Your primary color
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed, // Use fixed type for 5 items
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}