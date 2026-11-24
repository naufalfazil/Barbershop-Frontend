import 'package:flutter/material.dart';
import 'package:frontend_asas/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CukurIn",
      home: Scaffold(
        body: LoginPage(),
      ),
    );
  }
}