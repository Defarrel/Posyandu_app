import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'presentation/auth/login_screen.dart';
=======
import 'package:posyandu_app/presentation/home/home_root.dart';
>>>>>>> 524c3a52ff6372901ea53b1f98968b6984643fe1

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PosyanduApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeRoot(),
    );
  }
}
