import 'package:flutter/material.dart';
import 'db_helper.dart'; // Import Database Helper
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const Color kremColor = Color(0xFFFDF5E6);
  static const Color coklatTuaColor = Color(0xFF5D4037);
  static const Color coklatMudaColor = Color(0xFF8D6E63);

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // 1. Validasi Input Kosong
    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    // 2. Validasi Password Sama
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan Konfirmasi tidak sama!')),
      );
      return;
    }

    // 3. Proses Simpan ke Database
    try {
      final db = DbHelper();

      // Masukkan ke tabel 'users'
      // Secara default, yang daftar lewat sini role-nya adalah 'user' (konsumen)
      await db.database.then((database) async {
        await database.insert('users', {
          'username': username,
          'password': password,
          'role': 'user', // Otomatis jadi User Biasa
        });
      });

      if (!mounted) return;

      // 4. Sukses & Arahkan ke Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Error biasanya kalau username sudah ada (karena kita set UNIQUE di database)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username sudah digunakan, pilih yang lain!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kremColor,
      appBar: AppBar(
        title: const Text("Registrasi Akun"),
        backgroundColor: coklatTuaColor,
        foregroundColor: kremColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add, size: 80, color: coklatTuaColor),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username Baru',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.person, color: coklatTuaColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.lock, color: coklatTuaColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Ulangi Password',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.lock_reset, color: coklatTuaColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: coklatTuaColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('DAFTAR SEKARANG',
                  style: TextStyle(color: kremColor, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
