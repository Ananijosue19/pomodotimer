import 'package:flutter/material.dart';
import 'package:pomotime/presentation/screens/home.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: "Poppins"),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
