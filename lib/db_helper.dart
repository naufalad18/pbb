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
    final path = join(await getDatabasesPath(), 'blangkis_store_v4.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Tabel Produk
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            deskripsi TEXT,
            harga INTEGER,
            gambar TEXT
          )
        ''');

        // 2. Tabel Transaksi
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT,
            total_belanja INTEGER,
            ongkir INTEGER,
            grand_total INTEGER,
            kurir TEXT
          )
        ''');

        // 3. Tabel User
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            role TEXT
          )
        ''');

        // Data Awal (Seeding)
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

        await db.insert('users',
            {'username': 'admin', 'password': 'admin', 'role': 'admin'});
        await db.insert(
            'users', {'username': 'user', 'password': 'user', 'role': 'user'});
      },
    );
  }

  // --- METHODS PRODUK (CRUD) ---
  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // --- METHODS TRANSAKSI & LAPORAN ---
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('transactions', row);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('transactions', orderBy: "id DESC");
  }

  // --- METHODS USER (LOGIN & KELOLA KONSUMEN) ---
  Future<Map<String, dynamic>?> checkLogin(String user, String pass) async {
    final db = await database;
    final res = await db.query('users',
        where: 'username = ? AND password = ?', whereArgs: [user, pass]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // Ambil semua user yang role-nya 'user' (Konsumen)
  Future<List<Map<String, dynamic>>> getConsumers() async {
    final db = await database;
    return await db.query('users', where: 'role = ?', whereArgs: ['user']);
  }
}
