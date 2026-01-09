import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final int totalAmount; 
  const PaymentPage({Key? key, required this.totalAmount}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _bayarController = TextEditingController();
  int _jumlahBayar = 0;
  int _kembalian = 0;
  static const Color kremColor = Color(0xFFFDF5E6);
  static const Color coklatTuaColor = Color(0xFF5D4037);
  static const Color coklatMudaColor = Color(0xFF8D6E63);

  @override
  void initState() {
    super.initState();
    _bayarController.text = '0';
    _calculateChange(); 
  }

  void _calculateChange() {
    int total = widget.totalAmount;
    _jumlahBayar = int.tryParse(_bayarController.text) ?? 0;
    setState(() {
      _kembalian = _jumlahBayar - total;
    });
  }

  void _processPayment() {
    if (_kembalian < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah pembayaran kurang!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaksi Berhasil! Kembalian: Rp. $_kembalian')),
    );

    int count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pembayaran'),
        backgroundColor: coklatTuaColor,
        foregroundColor: kremColor,
      ),
      backgroundColor: kremColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Transaksi:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: coklatTuaColor,
              ),
            ),
            Text(
              'Rp. ${widget.totalAmount}', 
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: coklatMudaColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Jumlah Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: coklatTuaColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bayarController,
              keyboardType: TextInputType.number, 
              onChanged: (value) =>
                  _calculateChange(), 
              decoration: InputDecoration(
                labelText: "Masukkan Jumlah Uang",
                prefixText: 'Rp. ',
                prefixStyle: TextStyle(color: coklatTuaColor, fontSize: 18),
                fillColor: Colors.white,
                filled: true,
                border: const OutlineInputBorder(),
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
            const SizedBox(height: 40),

            Text(
              'Kembali',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: coklatTuaColor,
              ),
            ),
            Text(
              'Rp. ${_kembalian < 0 ? 0 : _kembalian}', 
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _kembalian >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 50),

            ElevatedButton(
              onPressed:
                  _calculateChange, 
              onLongPress: _processPayment, 
              style: ElevatedButton.styleFrom(
                backgroundColor: _kembalian >= 0
                    ? coklatTuaColor
                    : coklatMudaColor, 
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _kembalian < 0 ? 'Kurang Rp. ${-_kembalian}' : 'Bayar Sekarang',
                style: const TextStyle(fontSize: 18, color: kremColor),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Tekan agak lama untuk memproses pembayaran',
                  style: TextStyle(color: coklatMudaColor, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
