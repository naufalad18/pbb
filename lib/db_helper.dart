import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'blangkis.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            deskripsi TEXT,
            harga INTEGER,
            gambar TEXT
          )
        ''');

        // 🔥 DATA AWAL (INI YANG DOSEN MAU)
        await db.insert('products', {
          'nama': 'Blankon Lipat Motif Klasik',
          'deskripsi': 'Blankon khas Pakis dari kain batik tulis.',
          'harga': 75000,
          'gambar': 'lipat.png',
        });

        await db.insert('products', {
          'nama': 'Blankon Halus Prodo',
          'deskripsi': 'Blankon premium dengan hiasan emas.',
          'harga': 150000,
          'gambar': 'prodo.png',
        });

        await db.insert('products', {
          'nama': 'Blankon Anak Motif Ceria',
          'deskripsi': 'Blankon anak dengan motif cerah.',
          'harga': 50000,
          'gambar': 'anak.png',
        });
      },
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }
}
