import 'package:flutter/material.dart';

import 'database/db_helper.dart';

import 'ui/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashPage(),
    );
  }
}
