import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ui/update_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF102B46),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF49D5BC),
          brightness: Brightness.dark),
      ),
      debugShowCheckedModeBanner: false,
      home: UpdateGate(),
    );
  }
}
