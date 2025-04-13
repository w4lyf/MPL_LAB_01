// navigation_container.dart
import 'package:flutter/material.dart';
import 'package:railway_app/booking.dart';
import 'package:railway_app/settings.dart';
// import 'settings_page.dart';

class NavigationContainer extends StatefulWidget {
  final int initialIndex;
  const NavigationContainer({super.key, this.initialIndex = 0});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    BookingPage(username: "AbhinavS"),
    //MapPage(onStationSelected: "CSTM", isSelectingFromStation: isSelectingFromStation),
    SettingsPage(),  //You'll need to create this
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.train, 'Train', 0),
              _buildNavItem(Icons.public, 'Map', 1),
              _buildNavItem(Icons.settings, 'Settings', 2),
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