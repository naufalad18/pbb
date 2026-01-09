import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import 'product.dart';
import 'payment_page.dart';
import 'update_profile_page.dart';

class DashboardProductsPage extends StatefulWidget {
  const DashboardProductsPage({super.key});

  @override
  DashboardProductsPageState createState() => DashboardProductsPageState();
}

class DashboardProductsPageState extends State<DashboardProductsPage> {
  String? _namaLengkap;
  int _totalJual = 0;
  int _lastAddedPrice = 0;
  static const Color kremColor = Color(0xFFFDF5E6);
  static const Color coklatTuaColor = Color(0xFF5D4037);
  static const Color coklatMudaColor = Color(0xFF8D6E63);
  final List<Product> products = [
    Product(
      nama: "Blankon Lipat Motif Klasik",
      deskripsi:
          "Blankon khas Pakis dari kain batik tulis, bisa dilipat praktis.",
      harga: 75000,
      gambar: "lipat.png",
    ),
    Product(
      nama: "Blankon Halus Prodo",
      deskripsi: "Blankon kualitas premium dengan hiasan prodo emas.",
      harga: 150000,
      gambar: "prodo.png",
    ),
    Product(
      nama: "Blankon Anak Motif Ceria",
      deskripsi: "Ukuran pas untuk anak-anak dengan motif cerah.",
      harga: 50000,
      gambar: "anak.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _namaLengkap = prefs.getString('nama_lengkap') ?? 'Pelanggan';
      });
    }
  }

  void _logout() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _addToTotal(int price) {
    setState(() {
      _totalJual += price;
      _lastAddedPrice = price;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rp. $price ditambahkan. Total: Rp. $_totalJual'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _undoLastAdd() {
    if (_lastAddedPrice > 0) {
      setState(() {
        _totalJual -= _lastAddedPrice;
        _lastAddedPrice = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penambahan terakhir dibatalkan.'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada penambahan untuk dibatalkan.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showDescription(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kremColor,
        title: Text(title, style: const TextStyle(color: coklatTuaColor)),
        content: Text(
          description,
          style: const TextStyle(color: coklatMudaColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: coklatTuaColor)),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) async {
    String? url;
    switch (value) {
      case 'call':
        url = 'tel:+6281234567890';
        break;
      case 'sms':
        url = 'sms:+6281234567890';
        break;
      case 'maps':
        url =
            'https://www.google.com/maps/search/?api=1&query=Desa+Pakis+Beringin+Semarang';
        break;
      case 'update':
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
        );
        return;
    }
    if (url != null) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tidak dapat membuka $value')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kremColor,
      appBar: AppBar(
        backgroundColor: coklatTuaColor,
        foregroundColor: kremColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.storefront),
            ),
            const SizedBox(width: 10),
            const Text('Produk Blangkis'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'call',
                child: ListTile(
                  leading: Icon(Icons.call),
                  title: Text('Call Center'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sms',
                child: ListTile(
                  leading: Icon(Icons.sms),
                  title: Text('SMS Center'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'maps',
                child: ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Lokasi/Maps'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'update',
                child: ListTile(
                  leading: Icon(Icons.manage_accounts),
                  title: Text('Update User'),
                ),
              ),
            ],
            icon: const Icon(Icons.menu),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    leading: GestureDetector(
                      onTap: () => _addToTotal(product.harga),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/${product.gambar}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    title: InkWell(
                      onTap: () =>
                          _showDescription(product.nama, product.deskripsi),
                      child: Text(
                        product.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: coklatTuaColor,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      "Rp. ${product.harga}",
                      style: const TextStyle(
                        color: coklatMudaColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          InkWell(
            onTap: () async {
              // <--- Pastikan ada 'async' di sini
              if (_totalJual > 0) {
                // 1. Kita tunggu (await) sampai PaymentPage selesai & tutup
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(totalAmount: _totalJual),
                  ),
                );

                // 2. Cek apakah PaymentPage mengirim sinyal 'true' (artinya sukses bayar)
                if (result == true) {
                  setState(() {
                    _totalJual = 0; // Reset total
                    _lastAddedPrice = 0; // Reset history undo
                  });

                  // Opsional: Pesan kecil bahwa keranjang sudah kosong
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pembayaran selesai, keranjang dikosongkan.',
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Total penjualan masih nol!')),
                );
              }
            },
            child: Container(
              color: coklatMudaColor.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.undo,
                          color: coklatTuaColor,
                          size: 20,
                        ),
                        onPressed: _undoLastAdd,
                        tooltip: 'Batalkan Penambahan Terakhir',
                        padding: const EdgeInsets.only(right: 8),
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        _namaLengkap ?? 'Pelanggan',
                        style: const TextStyle(
                          fontSize: 14,
                          color: coklatMudaColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Penjualan:',
                        style: TextStyle(fontSize: 14, color: coklatMudaColor),
                      ),
                      Text(
                        'Rp. $_totalJual',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: coklatTuaColor,
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
