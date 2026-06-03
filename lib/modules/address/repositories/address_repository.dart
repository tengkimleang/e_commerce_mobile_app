import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/delivery_address.dart';

abstract class IAddressRepository {
  Future<List<DeliveryAddress>> getAll();
  Future<void> insert(DeliveryAddress address);
  Future<void> update(DeliveryAddress address);
  Future<void> delete(String id);
  Future<void> setDefault(String id);
}

class AddressRepository implements IAddressRepository {
  static const _dbName = 'chipmong_retail.db';
  static const _dbVersion = 1;
  static const _table = 'addresses';

  Database? _db;

  Future<Database> _openDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, _dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name_address TEXT NOT NULL,
            address TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            label INTEGER NOT NULL DEFAULT 3,
            is_default INTEGER NOT NULL DEFAULT 0,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  @override
  Future<List<DeliveryAddress>> getAll() async {
    final db = await _openDb();
    final rows = await db.query(_table, orderBy: 'is_default DESC, rowid ASC');
    return rows.map(DeliveryAddress.fromMap).toList();
  }

  @override
  Future<void> insert(DeliveryAddress address) async {
    final db = await _openDb();
    await db.transaction((txn) async {
      if (address.isDefault) {
        await txn.update(_table, {'is_default': 0});
      }
      await txn.insert(
        _table,
        address.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  @override
  Future<void> update(DeliveryAddress address) async {
    final db = await _openDb();
    await db.transaction((txn) async {
      if (address.isDefault) {
        await txn.update(_table, {'is_default': 0});
      }
      await txn.update(
        _table,
        address.toMap(),
        where: 'id = ?',
        whereArgs: [address.id],
      );
    });
  }

  @override
  Future<void> delete(String id) async {
    final db = await _openDb();
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setDefault(String id) async {
    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.update(_table, {'is_default': 0});
      await txn.update(
        _table,
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
