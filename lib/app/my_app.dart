// lib/app/my_app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/auth_gate.dart';
import 'config/themes/app_theme.dart';
import 'providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'For You Daily',
      themeMode: themeProvider.themeMode, // <-- Dùng themeMode từ provider
      theme: AppTheme.lightTheme,         // <-- Theme sáng
      darkTheme: AppTheme.darkTheme,      // <-- Theme tối
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}