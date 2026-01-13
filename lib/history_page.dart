import 'package:flutter/material.dart';
import 'db_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final data = await DbHelper().getHistory();
    setState(() {
      _historyData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Belanja'),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: const Color(0xFFFDF5E6),
      ),
      backgroundColor: const Color(0xFFFDF5E6),
      body: _historyData.isEmpty
          ? const Center(child: Text("Belum ada transaksi"))
          : ListView.builder(
              itemCount: _historyData.length,
              itemBuilder: (context, index) {
                final item = _historyData[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF5D4037),
                    ),
                    title: Text("Total: Rp. ${item['grand_total']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tgl: ${item['tanggal'].toString().substring(0, 16)}",
                        ),
                        Text("Kurir: ${item['kurir']}"),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
