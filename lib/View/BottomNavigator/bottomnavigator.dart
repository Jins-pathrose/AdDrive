import 'dart:ui';

import 'package:addrive/View/Screens/campaigns.dart';
import 'package:addrive/View/Screens/homepage.dart';
import 'package:addrive/View/Screens/myride.dart';
import 'package:addrive/View/Screens/notifications.dart';
import 'package:addrive/View/Screens/profile.dart';
import 'package:flutter/material.dart';

class BottomNavigator extends StatefulWidget {
  final int initialIndex;
  
  const BottomNavigator({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // List of pages for each bottom navigation item
  final List<Widget> _pages = [
    HomePage(),
    MyRidePage(),
    CampaignsPage(),
    Notifications(),
    ProfilePage(),
  ];

  // List of icons for bottom navigation
  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.campaign_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  // List of labels for bottom navigation
  final List<String> _labels = [
    'Home',
    'My Ride',
    'Campaigns',
    'Alerts',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body will change based on selected index
      body: _pages[_selectedIndex],
      extendBody: true,

      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _icons.length,
                (index) => Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _selectedIndex == index
                                  ? Color(0xFF6C3FE4).withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _icons[index],
                              color: _selectedIndex == index
                                  ? Color(0xFF6C3FE4)
                                  : Color(0xFF6B7280),
                              size: 26,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _labels[index],
                            style: TextStyle(
                              color: _selectedIndex == index
                                  ? Color(0xFF6C3FE4)
                                  : Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: _selectedIndex == index
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}