import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutterapp/FirebaseOptions.dart';
import 'package:flutterapp/routes/app_routes.dart';

void main() async {
  // setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help-E',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.getRoutes(),
    );
  }
}
