import 'package:flutter/material.dart';
import 'package:sky_luxury/nav_bar/chat/conversation_screen.dart';
import 'package:sky_luxury/nav_bar/home_screen.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({Key? key}) : super(key: key);

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          children: [
            currentIndex == 0 ? HomeScreen() : ConversationScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (int index) => setState(() => currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home_filled),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home'),
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.message_sharp),
                  icon: Icon(Icons.message_outlined),
                  label: 'Message')
            ]));
  }
}
