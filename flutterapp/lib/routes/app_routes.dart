import 'package:flutter/material.dart';
import 'package:flutterapp/screens/home_screen.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/screens/views/admin/AdminDashboard.dart';
import 'package:flutterapp/screens/views/admin/users/user_list_page.dart';
import 'package:flutterapp/screens/views/admin/widgets/admin_layout.dart';
import 'package:flutterapp/screens/views/formateur/formateur__layout.dart';
import 'package:flutterapp/screens/views/profile_view.dart';


class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String userList = '/user-list';
  static const String adminDashboard = '/admin-dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
    home: (context) =>  LoginPage(),
      adminDashboard: (context) => AdminLayout(page: AdminDashboardScreen()), // Admin Dashboard dans AdminLayout
      userList: (context) => AdminLayout(page: UserListPage()), // Page de la liste des utilisateurs
       login: (context) => LoginPage(),
      // Ajoutez d'autres pages ici si nécessaire// '/deconnexion': (context) => LogoutPage(), // Page de déconnexion ou logique
    };
  }
}
