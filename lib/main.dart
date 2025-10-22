import 'package:flutter/material.dart';
import 'package:posyandu_app/presentation/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PosyanduApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0098F8)),
      ),
      home: SplashScreen(),
    );
  }
}
