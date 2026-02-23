// lib/core/widgets/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_or_register_screen.dart';
import 'main_navigation_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Nếu người dùng đã đăng nhập (và không ẩn danh) -> Vào màn hình chính
          if (snapshot.hasData && !snapshot.data!.isAnonymous) {
            return const MainNavigationShell();
          }
          // Nếu chưa đăng nhập -> Vào màn hình đăng nhập/đăng ký
          else {
            return const LoginOrRegisterScreen();
          }
        },
      ),
    );
  }
}