// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutterapp/screens/views/profile_view.dart';
import 'package:google_fonts/google_fonts.dart';  
import 'package:flutterapp/config/config.dart';
import 'package:flutterapp/screens/views/home_view.dart';
import 'package:flutterapp/screens/views/ticket_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Text(
      //   //   'Help-E',
      //   //   style: GoogleFonts.poppins(
      //   //     textStyle: const TextStyle(
      //   //       fontWeight: FontWeight.bold,
      //   //     ),
      //   //   ),
      //   // ),
      //   backgroundColor: primColor,
      //   actions: [
      //     Container(
      //       padding: const EdgeInsets.all(6.0),
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         color: Colors.white,
      //         border: Border.all(color: Colors.black, width: 2.0),
      //       ),
      //       child: IconButton(
      //         icon: const Icon(
      //           Icons.notifications_none,
      //           color: Colors.black,
      //           size: 30,
      //         ),
      //         onPressed: () {
      //           // Action pour la notification
      //         },
      //         iconSize: 10,
      //         tooltip: 'Notifications',
      //       ),
      //     ),
      //   ],
      // ),
      
      body: PageView(
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        controller: _pageController,
        children: <Widget>[
          HomeView(),
          TicketsPage(),
          ProfilePage(),
        ],
        
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(_currentIndex);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: primColor,
        unselectedItemColor: secondColor,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
    );
  }
}
