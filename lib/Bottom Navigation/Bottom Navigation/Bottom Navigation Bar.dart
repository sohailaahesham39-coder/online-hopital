import 'package:flutter/material.dart';


import '../../services.dart';
import '../booking/Bookings Screen.dart';
import '../Payment/Payment Screen.dart';
import '../profile/Profile Screen.dart';
import '../Chat/chat screen.dart';


class MainBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _MainBottomNavigationBarState createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // In MainBottomNavigationBar class, correct the indices:
          Flexible(child: _buildNavItem(0, 'Services', Icons.medical_services_outlined, Icons.medical_services)),
          Flexible(child: _buildNavItem(1, 'Bookings', Icons.calendar_today_outlined, Icons.calendar_today)),
          Flexible(child: _buildNavItem(2, 'Payments', Icons.payment_outlined, Icons.payment)),
          Flexible(child: _buildNavItem(3, 'Chat', Icons.chat_bubble_outline, Icons.chat_bubble)), // Changed from 4 to 3
          Flexible(child: _buildNavItem(4, 'Profile', Icons.person_outline, Icons.person)), // Changed from 5 to 4
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData inactiveIcon, IconData activeIcon) {
    final isSelected = widget.currentIndex == index;

    return InkWell(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0x101976D2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isSelected ? Color(0x201976D2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? Color(0xFF1976D2) : Color(0xFFB0BEC5),
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFF1976D2) : Color(0xFFB0BEC5),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MainScreen extends StatefulWidget {
  final String userName; // Optional if you want to pass the userName

  const MainScreen({Key? key, this.userName = ''}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ServicesScreen(userName: ''), // Replace '' with actual userName if needed
    BookingsScreen(),
    PaymentScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

