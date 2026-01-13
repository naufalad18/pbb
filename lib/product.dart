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

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      harga: map['harga'],
      gambar: map['gambar'],
    );
  }
}
