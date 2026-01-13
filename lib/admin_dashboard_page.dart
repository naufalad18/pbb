import 'package:flutter/material.dart';
import 'login_page.dart';
import 'admin_features.dart'; // Import fitur admin yang baru dibuat

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Card(
            color: Colors.redAccent,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Selamat Datang, Admin!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Menu 1: Kelola Produk
          _buildAdminMenu(
            context,
            icon: Icons.inventory,
            title: "Kelola Produk",
            subtitle: "Tambah, Edit, & Hapus Data Produk",
            destination: const ManageProductsPage(),
          ),

          // Menu 2: Kelola Konsumen
          _buildAdminMenu(
            context,
            icon: Icons.people,
            title: "Kelola Konsumen",
            subtitle: "Lihat Daftar User Terdaftar",
            destination: const ManageConsumersPage(),
          ),

          // Menu 3: Laporan Penjualan
          _buildAdminMenu(
            context,
            icon: Icons.analytics,
            title: "Laporan Penjualan",
            subtitle: "Lihat Rekap Pendapatan & Transaksi",
            destination: const SalesReportPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[50],
          child: Icon(icon, color: Colors.redAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}
