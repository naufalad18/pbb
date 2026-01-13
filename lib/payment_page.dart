import 'dart:io'; // 1. Import untuk File gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 2. Import untuk ambil foto
import 'db_helper.dart'; // 3. Import agar bisa simpan ke database

class PaymentPage extends StatefulWidget {
  final int totalAmount;
  const PaymentPage({Key? key, required this.totalAmount}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _bayarController = TextEditingController();

  // Data Ongkir Sederhana
  final Map<String, int> _ongkirList = {
    'Ambil Sendiri (Rp 0)': 0,
    'Semarang (Rp 10.000)': 10000,
    'Luar Semarang (Rp 25.000)': 25000,
    'Luar Jawa (Rp 50.000)': 50000,
  };

  String? _selectedKurir;
  int _biayaOngkir = 0;
  int _jumlahBayar = 0;
  int _kembalian = 0;

  // Variabel untuk Bukti Pembayaran
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  static const Color kremColor = Color(0xFFFDF5E6);
  static const Color coklatTuaColor = Color(0xFF5D4037);
  static const Color coklatMudaColor = Color(0xFF8D6E63);

  @override
  void initState() {
    super.initState();
    _selectedKurir = _ongkirList.keys.first; // Default pilihan pertama
  }

  // Menghitung Total Akhir (Harga Produk + Ongkir)
  int get _totalBayarAkhir => widget.totalAmount + _biayaOngkir;

  void _calculateChange(String value) {
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    _jumlahBayar = int.tryParse(cleanValue) ?? 0;

    setState(() {
      _kembalian = _jumlahBayar - _totalBayarAkhir;
    });
  }

  void _updateOngkir(String? value) {
    setState(() {
      _selectedKurir = value;
      _biayaOngkir = _ongkirList[value] ?? 0;
      // Recalculate kembalian saat ongkir berubah
      _calculateChange(_bayarController.text);
    });
  }

  // Fungsi Baru: Ambil Foto dari Galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi Update: Simpan ke DB & Tampilkan Nota
  Future<void> _processPayment() async {
    // 1. Validasi Uang
    if (_jumlahBayar < _totalBayarAkhir) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang pembayaran kurang!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Validasi Bukti Foto (Sesuai Soal: Ada upload bukti)
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload bukti pembayaran!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. SIMPAN KE DATABASE (Agar muncul di History)
    await DbHelper().insertTransaction({
      'tanggal': DateTime.now().toString(),
      'total_belanja': widget.totalAmount,
      'ongkir': _biayaOngkir,
      'grand_total': _totalBayarAkhir,
      'kurir': _selectedKurir,
      // Jika ingin simpan path gambar juga, pastikan tabel DB support kolom ini
      // 'bukti_path': _imageFile!.path,
    });

    if (!mounted) return;

    // 4. TAMPILKAN NOTA
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik tombol tutup
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("NOTA PEMBAYARAN")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Transaksi Berhasil Disimpan!",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
              const Divider(),
              _buildNotaRow("Harga Produk", widget.totalAmount),
              _buildNotaRow("Ongkos Kirim", _biayaOngkir),
              const Divider(thickness: 2),
              _buildNotaRow("TOTAL", _totalBayarAkhir, isBold: true),
              const SizedBox(height: 10),
              _buildNotaRow("Bayar", _jumlahBayar),
              _buildNotaRow("Kembali", _kembalian),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Terima Kasih!",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog Nota
                Navigator.pop(context, true); // Kembali ke Dashboard & Reset
              },
              child: const Text("TUTUP & SELESAI"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotaRow(String label, int value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rp. $value",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir & Pengiriman'),
        backgroundColor: coklatTuaColor,
        foregroundColor: kremColor,
      ),
      backgroundColor: kremColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rincian Biaya
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Total Belanja',
                      style: TextStyle(color: coklatMudaColor),
                    ),
                    Text(
                      'Rp. ${widget.totalAmount}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: coklatTuaColor,
                      ),
                    ),
                    const Divider(),
                    // Dropdown Ongkir
                    DropdownButtonFormField<String>(
                      value: _selectedKurir,
                      decoration: const InputDecoration(
                        labelText: "Pilih Pengiriman / Lokasi",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      items: _ongkirList.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(
                            key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: _updateOngkir,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Biaya Ongkir:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Rp. $_biayaOngkir",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    const Text(
                      "TOTAL YANG HARUS DIBAYAR",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    Text(
                      'Rp. $_totalBayarAkhir',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- INPUT BUKTI PEMBAYARAN (BARU) ---
            const Text(
              "Bukti Pembayaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: coklatTuaColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          Text(
                            "Ketuk untuk upload foto",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // -------------------------------------

            // Input Pembayaran
            TextField(
              controller: _bayarController,
              keyboardType: TextInputType.number,
              onChanged: _calculateChange,
              decoration: const InputDecoration(
                labelText: "Masukkan Jumlah Uang",
                prefixText: 'Rp. ',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: coklatTuaColor, width: 2.0),
                ),
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: coklatTuaColor,
              ),
            ),

            const SizedBox(height: 20),

            // Info Kembalian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kembalian >= 0 ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kembalian:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp. $_kembalian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _kembalian >= 0
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Bayar
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: coklatTuaColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CETAK NOTA & SELESAI',
                style: TextStyle(
                  fontSize: 18,
                  color: kremColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
