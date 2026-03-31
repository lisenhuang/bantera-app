import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bantera',
      theme: BanteraTheme.lightTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}
