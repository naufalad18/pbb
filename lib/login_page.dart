import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart'; // Import halaman admin
import 'register_page.dart';
import 'db_helper.dart'; // Import database helper

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color kremColor = Color(0xFFFDF5E6);
  static const Color coklatTuaColor = Color(0xFF5D4037);
  static const Color coklatMudaColor = Color(0xFF8D6E63);

  Future<void> _login() async {
    final inputUsername = _usernameController.text.trim();
    final inputPassword = _passwordController.text.trim();

    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi')),
      );
      return;
    }

    // CEK LOGIN KE DATABASE
    final user = await DbHelper().checkLogin(inputUsername, inputPassword);

    if (user != null) {
      // Login Berhasil
      final role = user['role'];

      // Simpan sesi login (Opsional, agar tidak login ulang terus)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user['username']);
      await prefs.setString('role', role);

      if (!mounted) return;

      if (role == 'admin') {
        // Masuk Halaman Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
        );
      } else {
        // Masuk Halaman Customer (Produk)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const DashboardProductsPage()),
        );
      }
    } else {
      // Login Gagal
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password salah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kremColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.store,
                        size: 80, color: coklatTuaColor),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText:
                      'Coba: admin atau user', // Hint untuk memudahkan test
                  labelStyle: const TextStyle(color: coklatMudaColor),
                  prefixIcon:
                      const Icon(Icons.person_outline, color: coklatTuaColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Coba: admin atau user',
                  labelStyle: const TextStyle(color: coklatMudaColor),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: coklatTuaColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: coklatTuaColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: kremColor, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Belum punya akun? Registrasi!',
                    style: TextStyle(
                      color: coklatTuaColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Opsi Login Sosmed (Dummy)
              const SizedBox(height: 20),
              const Text("Atau masuk dengan:", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text("Google"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.facebook),
                    label: const Text("Facebook"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
