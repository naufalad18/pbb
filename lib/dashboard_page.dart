import 'dart:io'; // Tambahkan import ini
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import 'product.dart';
import 'payment_page.dart';
import 'update_profile_page.dart';
import 'db_helper.dart';
import 'history_page.dart';

class DashboardProductsPage extends StatefulWidget {
  const DashboardProductsPage({super.key});

  @override
  State<DashboardProductsPage> createState() => _DashboardProductsPageState();
}

class _DashboardProductsPageState extends State<DashboardProductsPage> {
  final DbHelper _dbHelper = DbHelper();

  List<Product> products = [];
  String? _namaLengkap;
  int _totalJual = 0;
  int _lastAddedPrice = 0;

  static const Color kremColor = Color(0xFFFDF5E6);
  static const Color coklatTuaColor = Color(0xFF5D4037);
  static const Color coklatMudaColor = Color(0xFF8D6E63);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProductsFromDb();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaLengkap = prefs.getString('nama_lengkap') ?? 'Pelanggan';
    });
  }

  Future<void> _loadProductsFromDb() async {
    final data = await _dbHelper.getProducts();
    setState(() {
      products = data;
    });
  }

  // --- FUNGSI BARU UNTUK HANDLE GAMBAR ---
  Widget _buildProductImage(String gambar) {
    if (gambar.contains('/') && File(gambar).existsSync()) {
      return Image.file(
        File(gambar),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    return Image.asset(
      'assets/images/$gambar',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
    );
  }
  // ----------------------------------------

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _addToTotal(int price) {
    setState(() {
      _totalJual += price;
      _lastAddedPrice = price;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Rp. $price ditambahkan')));
  }

  void _undoLastAdd() {
    if (_lastAddedPrice > 0) {
      setState(() {
        _totalJual -= _lastAddedPrice;
        _lastAddedPrice = 0;
      });
    }
  }

  void _showDescription(String title, String description) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) async {
    Uri? uri;
    switch (value) {
      case 'call':
        uri = Uri.parse('tel:+6281234567890');
        break;
      case 'sms':
        uri = Uri.parse('sms:+6281234567890');
        break;
      case 'maps':
        uri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=Desa+Pakis+Beringin+Semarang');
        break;
      case 'history':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryPage()),
        );
        return;
      case 'update':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpdateProfilePage()),
        );
        return;
    }

    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _goToPayment() async {
    if (_totalJual == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total penjualan masih nol')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentPage(totalAmount: _totalJual)),
    );

    if (result == true) {
      setState(() {
        _totalJual = 0;
        _lastAddedPrice = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kremColor,
      appBar: AppBar(
        backgroundColor: coklatTuaColor,
        foregroundColor: kremColor,
        title: const Text('Produk Blangkis'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'call', child: Text('Call Center')),
              PopupMenuItem(value: 'sms', child: Text('SMS Center')),
              PopupMenuItem(value: 'maps', child: Text('Lokasi / Maps')),
              PopupMenuItem(value: 'history', child: Text('Riwayat Belanja')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'update', child: Text('Update User')),
            ],
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final p = products[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => _addToTotal(p.harga),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: _buildProductImage(
                                  p.gambar), // GUNAKAN FUNGSI BARU
                            ),
                          ),
                          title: InkWell(
                            onTap: () => _showDescription(p.nama, p.deskripsi),
                            child: Text(
                              p.nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: Text('Rp. ${p.harga}'),
                        ),
                      );
                    },
                  ),
          ),
          InkWell(
            onTap: _goToPayment,
            child: Container(
              color: coklatMudaColor.withOpacity(0.15),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        onPressed: _undoLastAdd,
                      ),
                      Text(_namaLengkap ?? 'Pelanggan'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Penjualan'),
                      Text(
                        'Rp. $_totalJual',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
