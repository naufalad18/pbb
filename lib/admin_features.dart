import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'db_helper.dart';
import 'product.dart';

// ================== 1. HALAMAN KELOLA PRODUK (DENGAN UPLOAD GAMBAR) ==================
class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List<Product> _products = [];
  final DbHelper _dbHelper = DbHelper();
  final ImagePicker _picker = ImagePicker(); // Inisialisasi Picker

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() async {
    final data = await _dbHelper.getProducts();
    setState(() {
      _products = data;
    });
  }

  // Fungsi Helper: Menampilkan Gambar (Aset vs File)
  Widget _buildProductImage(String gambar) {
    // Jika path berisi tanda '/', asumsikan itu File dari Galeri
    if (gambar.contains('/') && File(gambar).existsSync()) {
      return Image.file(
        File(gambar),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    // Jika tidak, asumsikan itu Aset Bawaan
    return Image.asset(
      'assets/images/$gambar',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image),
    );
  }

  void _showForm(Product? product) {
    final nameController = TextEditingController(text: product?.nama ?? '');
    final descController =
        TextEditingController(text: product?.deskripsi ?? '');
    final priceController =
        TextEditingController(text: product?.harga.toString() ?? '');

    // Variabel sementara untuk gambar yang dipilih
    String currentImage = product?.gambar ?? 'lipat.png'; // Default aset
    File? pickedImageFile;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          // StatefulBuilder agar dialog bisa update tampilan saat pilih foto
          builder: (context, setStateDialog) {
            Future<void> pickImage() async {
              final XFile? picked =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                setStateDialog(() {
                  pickedImageFile = File(picked.path);
                  currentImage = picked.path; // Update path gambar
                });
              }
            }

            return AlertDialog(
              title: Text(product == null ? "Tambah Produk" : "Edit Produk"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Nama Produk')),
                    TextField(
                        controller: descController,
                        decoration:
                            const InputDecoration(labelText: 'Deskripsi')),
                    TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Harga'),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 15),

                    // --- BAGIAN PILIH GAMBAR ---
                    const Text("Gambar Produk:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: pickedImageFile != null
                            ? Image.file(pickedImageFile!,
                                fit: BoxFit.cover) // Tampilkan yg baru dipilih
                            : _buildProductImage(
                                currentImage), // Tampilkan yg lama
                      ),
                    ),
                    TextButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Ubah / Pilih Foto"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () async {
                    final newProduct = Product(
                      id: product?.id,
                      nama: nameController.text,
                      deskripsi: descController.text,
                      harga: int.tryParse(priceController.text) ?? 0,
                      gambar:
                          currentImage, // Simpan path gambar (aset atau file)
                    );

                    if (product == null) {
                      await _dbHelper.insertProduct(newProduct);
                    } else {
                      await _dbHelper.updateProduct(newProduct);
                    }
                    _refreshProducts();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Kelola Produk"),
          backgroundColor: Colors.redAccent),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: _buildProductImage(p.gambar), // Gunakan helper
              ),
              title: Text(p.nama),
              subtitle: Text("Rp ${p.harga}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(p)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(p.id!)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================== 2. HALAMAN KELOLA KONSUMEN (TETAP) ==================
class ManageConsumersPage extends StatefulWidget {
  const ManageConsumersPage({super.key});

  @override
  State<ManageConsumersPage> createState() => _ManageConsumersPageState();
}

class _ManageConsumersPageState extends State<ManageConsumersPage> {
  List<Map<String, dynamic>> _consumers = [];

  @override
  void initState() {
    super.initState();
    _loadConsumers();
  }

  void _loadConsumers() async {
    final data = await DbHelper().getConsumers();
    setState(() {
      _consumers = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Daftar Konsumen"),
          backgroundColor: Colors.redAccent),
      body: _consumers.isEmpty
          ? const Center(child: Text("Belum ada konsumen terdaftar"))
          : ListView.builder(
              itemCount: _consumers.length,
              itemBuilder: (context, index) {
                final user = _consumers[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['username']),
                    subtitle: const Text("Role: User/Konsumen"),
                  ),
                );
              },
            ),
    );
  }
}

// ================== 3. HALAMAN LAPORAN PENJUALAN (TETAP) ==================
class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  int _totalRevenue = 0;
  DateTimeRange? _selectedDateRange;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() async {
    final data = await DbHelper().getHistory();
    setState(() {
      _transactions = data;
      _filteredTransactions = data;
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    int total = 0;
    for (var item in _filteredTransactions) {
      total += (item['grand_total'] as int);
    }
    setState(() {
      _totalRevenue = total;
    });
  }

  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filteredTransactions = _transactions.where((t) {
          DateTime tDate = DateTime.parse(t['tanggal']);
          return tDate
                  .isAfter(picked.start.subtract(const Duration(days: 1))) &&
              tDate.isBefore(picked.end.add(const Duration(days: 1)));
        }).toList();
        _calculateTotal();
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedDateRange = null;
      _filteredTransactions = _transactions;
      _calculateTotal();
    });
  }

  Future<void> _exportPdf() async {
    final doc = pw.Document();

    String judul = "Laporan Penjualan Global";
    String periode = "Semua Waktu";

    if (_selectedDateRange != null) {
      judul = "Laporan Penjualan Periodik";
      periode =
          "${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}";
    }

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0,
                  child: pw.Text(judul,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.Text("Periode: $periode"),
              pw.Text(
                  "Tanggal Cetak: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}"),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                headers: <String>['No', 'Tanggal', 'Tujuan', 'Kurir', 'Total'],
                data: _filteredTransactions.map((item) {
                  return [
                    item['id'].toString(),
                    item['tanggal'].toString().substring(0, 10),
                    item['tujuan'] ?? '-',
                    item['kurir'] ?? '-',
                    currencyFormatter.format(item['grand_total']),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text("TOTAL PENDAPATAN:  ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(currencyFormatter.format(_totalRevenue),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ])
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export PDF",
            onPressed: _exportPdf,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Filter Periode:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    if (_selectedDateRange != null)
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _resetFilter)
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(_selectedDateRange == null
                      ? "Pilih Rentang Tanggal"
                      : "${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text("Total Pendapatan", style: TextStyle(fontSize: 14)),
                Text(
                  currencyFormatter.format(_totalRevenue),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent),
                ),
              ],
            ),
          ),
          const Divider(thickness: 5),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text("Tidak ada data pada periode ini."))
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = _filteredTransactions[index];
                      return ListTile(
                        leading: const Icon(Icons.receipt, color: Colors.green),
                        title: Text(
                            "Order #${t['id']} - ${currencyFormatter.format(t['grand_total'])}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Tgl: ${t['tanggal'].toString().substring(0, 16)}"),
                            if (t['tujuan'] != null) Text("Ke: ${t['tujuan']}"),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
