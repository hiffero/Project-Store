import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(const FeroWayApp());
}

class FeroWayApp extends StatelessWidget {
  const FeroWayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeroWay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[600],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue[600]!,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}