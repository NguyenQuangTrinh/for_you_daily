// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app/my_app.dart';
import 'app/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'features/cycle/presentation/providers/cycle_provider.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp();
  await NotificationService().init();
  await initializeDateFormatting('vi_VN', '');

  runApp(
    MultiProvider( // Dùng MultiProvider để quản lý nhiều provider
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CycleProvider()), // <-- THÊM MỚI
        ChangeNotifierProvider(create: (context) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

