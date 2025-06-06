import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart'; // 👈 Import the dashboard page
import 'home_page.dart';

void main() {
  runApp(TrackerApp());
}

class TrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRACKER',
      theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Sans'),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => HomePage(), // 👈 Register dashboard route
      },
    );
  }
}
