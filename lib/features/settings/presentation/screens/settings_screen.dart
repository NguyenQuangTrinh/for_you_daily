// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/providers/theme_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/data/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isReminderOn = false;
  final NotificationService _notificationService = NotificationService();

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
      return 'Hệ thống';
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Chọn chế độ hiển thị'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
              child: const Text('Sáng'),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
              child: const Text('Tối'),
            ),
            SimpleDialogOption(
              onPressed: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
              child: const Text('Hệ thống'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _isReminderOn = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('waterReminder', value);

    if (value) {
      // Nếu bật, lên lịch thông báo
      _notificationService.scheduleDailyWaterReminders();
    } else {
      // Nếu tắt, hủy tất cả thông báo
      _notificationService.cancelAllNotifications();
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          const _SettingsSectionTitle('NHẮC NHỞ'),
          _SettingsListItem(
            icon: Icons.notifications_none_outlined,
            title: 'Nhắc nhở uống nước',
            subtitle: 'Bật để nhận thông báo hàng ngày',
            trailing: Switch(
              value: _isReminderOn,
              onChanged: _toggleReminder, // Gọi hàm mới
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64, right: 16, bottom: 16),
            child: Text(
              'Bật "Nhắc nhở uống nước" để thêm hoặc quản lý giờ nhắc.',
              style: TextStyle(
                color: _isReminderOn ? Colors.grey.shade500 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          _SettingsListItem(
            icon: Icons.water_drop_outlined,
            title: 'Mục tiêu uống nước',
            subtitle: '2000 ml / ngày',
            onTap: () {},
          ),
          const _SettingsSectionTitle('CHU KỲ'),
          _SettingsListItem(
            icon: Icons.tune_outlined,
            title: 'Điều chỉnh tham số tính toán',
            subtitle: 'Pha hoàng thể: 14 ngày',
            onTap: () {},
          ),
          const _SettingsSectionTitle('GIAO DIỆN'),
          _SettingsListItem(
            icon: Icons.settings_outlined,
            title: 'Chế độ hiển thị',
            subtitle: _getThemeModeText(themeProvider.themeMode),
            onTap: () => _showThemeDialog(context),
          ),
          const _SettingsSectionTitle('DỮ LIỆU'),
          const _SettingsSectionTitle('TÀI KHOẢN'),
          _SettingsListItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            subtitle: 'Bạn sẽ được đưa về màn hình đăng nhập',
            onTap: () async {
              final navigator = Navigator.of(context);
              // Lấy AuthService ra
              final authService = AuthService();

              // Đóng tất cả các màn hình cho đến màn hình gốc
              navigator.popUntil((route) => route.isFirst);

              // Sau đó mới thực hiện đăng xuất
              await authService.signOut();
            },
            // Tùy chỉnh để không có mũi tên
            trailing: const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}

// Widget con cho tiêu đề của mỗi section
class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0, right: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Widget con cho mỗi mục cài đặt trong danh sách
class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}