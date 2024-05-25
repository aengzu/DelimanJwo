import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sogra_front/view/ar_view/ar_screen.dart';
import 'package:sogra_front/view/my_bread_screen/mybread_screen.dart';

import 'map_view/map_screen.dart';


class MainScreens extends StatefulWidget {
  const MainScreens({super.key});

  @override
  State<MainScreens> createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:IndexedStack(
          index: _selectedIndex,
          children: [
            ArScreen(),
            MapScreen(),
            MybreadScreen(),
          ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFACD74),
        unselectedItemColor: Color(0xFF999999),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: '탐색 모드',
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: '빵 지도',
            icon: Icon(Icons.map),
          ),
          BottomNavigationBarItem(
            label: '나의 빵',
            icon: Icon(Icons.people),
          ),
        ],
      ),
    );
  }

}
