// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../../app/config/constants/app_colors.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Text(
              'For You Daily',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Màn hình chính'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer trước khi chuyển màn hình
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // Thêm các tính năng khác ở đây sau
        ],
      ),
    );
  }
}

// Thêm đoạn import này vào đầu file để sử dụng AppColors
