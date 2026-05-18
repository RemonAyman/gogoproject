import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/config/routes/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء إدخال البريد الإلكتروني أولاً')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين كلمة المرور'),
        content: const Text(
            'تم إرسال طلب إعادة تعيين كلمة المرور إلى بريدك الإلكتروني بنجاح (وضع ديمو).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً')),
        ],
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        final role = data['user']['role'];
        if (role == 'patient') {
          Navigator.pushReplacementNamed(context, AppRoutes.patientHome);
        } else if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, AppRoutes.doctorHome);
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.role);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
              obscureText: _isObscure,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('دخول'),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.signup);
              },
              child: const Text('ليس لديك حساب؟ سجل الآن'),
            ),
          ],
        ),
      ),
    );
  }
}