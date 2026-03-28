import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rick_and_morty/util/constants.dart';
import 'package:rick_and_morty/features/favorite/view/favorite_screen.dart';
import 'package:rick_and_morty/features/home/view/home_screen.dart';
import 'package:rick_and_morty/features/menu/view/menu_screen.dart';

class MainBottomNavigation extends StatefulWidget {
  const MainBottomNavigation({super.key});
  @override
  State<MainBottomNavigation> createState() {
    return _MainBottomNavigation();
  }
}

class _MainBottomNavigation extends State<MainBottomNavigation> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    FavoriteScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // ensures status bar dark mode
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: color2,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: color6,
          unselectedItemColor: color3,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined),
              activeIcon: Icon(Icons.favorite),
              label: "Favorite",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              activeIcon: Icon(Icons.menu_open),
              label: "Menu",
            ),
          ],
        ),
      ),
    );
  }
}
