import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  Future<void> handleLogin() async {
    setState(() => loading = true);

    final res = await AuthService.login(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (res['token'] != null) {
      final user = res['user'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome ${user['name']}")),
      );

      // Delay kecil biar SnackBar tidak flicker
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Login failed')),
      );
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleLogin,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'),
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }
}
