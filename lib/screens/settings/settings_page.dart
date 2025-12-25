import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/routes/routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;

  Future<void> _reauthenticateAndPerform(
      String title, Future<void> Function(String password) action) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد كلمة المرور لـ $title'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('يرجى إدخال كلمة المرور الحالية للمتابعة'),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context); // Close dialog
                try {
                  // Re-authenticate
                  User? user = _auth.currentUser;
                  if (user != null && user.email != null) {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: passwordController.text.trim(),
                    );
                    await user.reauthenticateWithCredential(credential);
                    // Perform action
                    await action(passwordController.text.trim());
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('كلمة المرور غير صحيحة أو حدث خطأ: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeEmail(String password) async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير البريد الإلكتروني'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'البريد الإلكتروني الجديد'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty || !v.contains('@') ? 'غير صحيح' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                try {
                  await _auth.currentUser!.verifyBeforeUpdateEmail(emailController.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال رابط تأكيد للبريد الجديد. يرجى التحقق منه.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل التغيير: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String oldPassword) async {
    final passController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passController,
            decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
            obscureText: true,
            validator: (v) => v!.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                try {
                  await _auth.currentUser!.updatePassword(passController.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل التغيير: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user?.email ?? 'المستخدم'),
            subtitle: const Text('البريد الإلكتروني المسجل'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('تغيير البريد الإلكتروني'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _reauthenticateAndPerform('تغيير الإيميل', _changeEmail),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('تغيير كلمة المرور'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _reauthenticateAndPerform('تغيير الباسورد', _changePassword),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}