import 'package:flutter/material.dart';
import '../../core/config/routes/routes.dart';
import '../../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ApiService _apiService = ApiService();
  String _userEmail = 'تحميل...';
  String _userName = 'تحميل...';
  String _userRole = 'تحميل...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _apiService.getMe();
      setState(() {
        _userEmail = data['email'] ?? '';
        _userName = data['name'] ?? '';
        final role = data['role'] ?? 'patient';
        _userRole = role == 'admin'
            ? 'مسؤول النظام'
            : role == 'doctor'
                ? 'طبيب'
                : 'مريض';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userEmail = 'غير مسجل';
        _userName = 'مستخدم عشوائي';
        _userRole = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  accountName: Text(
                    _userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  accountEmail: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userEmail),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _userRole,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('عن التطبيق'),
                  subtitle: const Text('DocLine - سيستم حجز العيادات الذكي'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _apiService.logout();
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                  },
                ),
              ],
            ),
    );
  }
}