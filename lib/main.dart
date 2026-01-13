import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // [WAJIB]
import 'firebase_options.dart'; // [WAJIB] File hasil configure tadi
import 'login_page.dart'; // Halaman login yang baru kita edit

void main() async {
  // 1. Pastikan binding aktif
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Nyalakan Firebase (Wajib ada agar tidak error)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Blingkis',
      theme: ThemeData(
        // Sesuaikan warna tema Mas Naufal
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      // Langsung panggil halaman Login
      home: const LoginPage(),
    );
  }
}
