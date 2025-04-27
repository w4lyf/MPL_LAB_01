import 'package:flutter/material.dart';
import 'package:railway_app/HomePage.dart';
import 'package:railway_app/settings.dart';

class NavigationContainer extends StatefulWidget {
  final int initialIndex;
  const NavigationContainer({super.key, this.initialIndex = 0});
  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  late int _selectedIndex;                                                                // Tracks which page/tab is currently active
  @override
  void initState() {                                                                      // Sets default tab when page loads
    super.initState();
    _selectedIndex = widget.initialIndex;
  }
  final List<Widget> _pages = const [                                                     // Stores list of screens
    HomePage(),
    SettingsPage(),
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
      bottomNavigationBar: Container(                                                     //  creates a nav bar - container + row
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,                             // Share space equally
            children: [
              _buildNavItem(Icons.home, 'Home', 0),                                     // Set icons for both nav items and call fn
              _buildNavItem(Icons.settings, 'Settings', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.deepPurple : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.deepPurple : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}