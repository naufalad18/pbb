class Product {
  final int? id;
  final String nama;
  final String deskripsi;
  final int harga;
  final String gambar;

  Product({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.gambar,
  });

  // Mengubah data dari Map (Database) ke Object Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      harga: map['harga'],
      gambar: map['gambar'],
    );
  }

  // --- BAGIAN INI YANG TADI HILANG ---
  // Mengubah Object Product ke Map (untuk disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
    };
  }
}
