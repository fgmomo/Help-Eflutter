import 'package:flutter/material.dart';
import 'package:flutterapp/screens/views/formateur/chat_formateur.dart';
import 'package:flutterapp/screens/views/formateur/home_formateur.dart';
import 'package:flutterapp/screens/views/formateur/profil_formateur.dart';
import 'package:flutterapp/screens/views/formateur/ticket_formateur.dart';
import 'package:google_fonts/google_fonts.dart';  
import 'package:flutterapp/config/config.dart';


class FormateurHomeScreen extends StatefulWidget {
  const FormateurHomeScreen({super.key});

  @override
  State<FormateurHomeScreen> createState() => _FormateurHomeScreenState();
}

class _FormateurHomeScreenState extends State<FormateurHomeScreen> {
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
      body: PageView(
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        controller: _pageController,
        children: const <Widget>[
          HomeFormateurView(),
          TicketFormateurView(),
          ChatFormateurView(),
          ProfileFormateurView(),
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
