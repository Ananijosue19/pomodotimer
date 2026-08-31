import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomotime/presentation/screens/splash_screen.dart';
import 'core/providers/timer_provider.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/services/ambiance_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AmbianceService()),
        ChangeNotifierProxyProvider2<TaskProvider, UserProvider, TimerProvider>(
          create: (_) => TimerProvider(),
          update: (_, tasks, user, timer) {
            timer!.updateDependencies(tasks, user);
            return timer;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minuteur Pomodoro',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: "Poppins"),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
