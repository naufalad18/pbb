import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';
import 'register_page.dart';
import 'db_helper.dart';
import 'auth_service.dart';

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

  // Variabel Loading
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false; // [BARU] Loading untuk Facebook

  // --- LOGIKA LOGIN DATABASE LOKAL (TETAP) ---
  Future<void> _login() async {
    final inputUsername = _usernameController.text.trim();
    final inputPassword = _passwordController.text.trim();

    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi')),
      );
      return;
    }

    // CEK LOGIN KE DATABASE LOKAL
    final user = await DbHelper().checkLogin(inputUsername, inputPassword);

    if (user != null) {
      final role = user['role'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user['username']);
      await prefs.setString('role', role);

      if (!mounted) return;
      _navigateBasedOnRole(role);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password salah!')),
      );
    }
  }

  // --- LOGIKA LOGIN GOOGLE (TETAP) ---
  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final User? user = await AuthService().signInWithGoogle();
      if (user != null) {
        await _processSocialLoginSuccess(user, "Google");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Google dibatalkan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Login Google: $e")),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // --- [BARU] LOGIKA LOGIN FACEBOOK ---
  Future<void> _handleFacebookLogin() async {
    setState(() => _isFacebookLoading = true); // Mulai loading FB
    try {
      // 1. Panggil AuthService Facebook
      final User? user = await AuthService().signInWithFacebook();

      if (user != null) {
        // 2. Jika sukses, proses data user
        await _processSocialLoginSuccess(user, "Facebook");
      } else {
        // Jika batal/gagal tanpa error catch
        // (Pesan error spesifik biasanya sudah di-print di AuthService)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login Facebook tidak berhasil / dibatalkan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Login Facebook: $e")),
      );
    } finally {
      if (mounted) setState(() => _isFacebookLoading = false); // Stop loading
    }
  }

  // --- [HELPER] PROSES SETELAH LOGIN SOSMED SUKSES ---
  Future<void> _processSocialLoginSuccess(User user, String provider) async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan nama user atau default jika null
    await prefs.setString('username', user.displayName ?? "$provider User");
    await prefs.setString('role', 'user'); // Default role User

    if (!mounted) return;
    _navigateBasedOnRole('user');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selamat Datang, ${user.displayName}!")),
    );
  }

  // Helper Navigasi
  void _navigateBasedOnRole(String role) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardProductsPage()),
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
              // --- BAGIAN LOGO ---
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

              // --- FORM USERNAME ---
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Coba: admin atau user',
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

              // --- FORM PASSWORD ---
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

              // --- TOMBOL LOGIN BIASA ---
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

              // --- LOGIN SOSMED ---
              const SizedBox(height: 20),
              const Text("Atau masuk dengan:", textAlign: TextAlign.center),
              const SizedBox(height: 10),

              // Tampilkan Loading jika Google ATAU Facebook sedang proses
              if (_isGoogleLoading || _isFacebookLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- TOMBOL GOOGLE ---
                    ElevatedButton.icon(
                      onPressed: _handleGoogleLogin,
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text("Google"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                    ),

                    const SizedBox(width: 10),

                    // --- TOMBOL FACEBOOK (SUDAH AKTIF) ---
                    ElevatedButton.icon(
                      onPressed:
                          _handleFacebookLogin, // <--- Panggil fungsi ini
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
