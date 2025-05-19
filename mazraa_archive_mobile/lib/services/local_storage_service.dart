import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/models/document.dart';
import '../core/models/storage_location.dart';
import '../core/models/user.dart';
import '../features/barcode/domain/models/generated_barcode.dart';

class LocalStorageService {
  static Database? _database;
  static const String _dbName = 'mazraa_archive.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Documents table
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY,
        document_type TEXT NOT NULL,
        barcode TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        storage_location TEXT,
        file_path TEXT,
        file_type TEXT,
        file_size INTEGER,
        archived INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        created_by_id INTEGER,
        updated_by_id INTEGER,
        sync_status TEXT NOT NULL
      )
    ''');

    // Storage locations table
    await db.execute('''
      CREATE TABLE storage_locations (
        id INTEGER PRIMARY KEY,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        shelf TEXT,
        row TEXT,
        box TEXT,
        capacity INTEGER NOT NULL,
        used_space INTEGER NOT NULL,
        active INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        created_by_id INTEGER,
        updated_by_id INTEGER,
        sync_status TEXT NOT NULL
      )
    ''');

    // Sync logs table
    await db.execute('''
      CREATE TABLE sync_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        device_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL
      )
    ''');

    // Generated barcodes table
    await db.execute('''
      CREATE TABLE generated_barcodes (
        barcode TEXT PRIMARY KEY,
        document_type TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        is_used INTEGER NOT NULL,
        document_id TEXT,
        storage_location TEXT,
        sync_status TEXT NOT NULL
      )
    ''');
  }

  // Document operations
  Future<void> saveDocument(Document document, {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.insert(
      'documents',
      {
        ...document.toJson(),
        'sync_status': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Document>> getDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents');
    return List.generate(maps.length, (i) => Document.fromJson(maps[i]));
  }

  Future<Document?> getDocumentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Document.fromJson(maps.first);
  }

  Future<void> deleteDocument(int id) async {
    final db = await database;
    await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Storage location operations
  Future<void> saveStorageLocation(StorageLocation location, {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.insert(
      'storage_locations',
      {
        ...location.toJson(),
        'sync_status': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StorageLocation>> getStorageLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('storage_locations');
    return List.generate(maps.length, (i) => StorageLocation.fromJson(maps[i]));
  }

  Future<StorageLocation?> getStorageLocationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'storage_locations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return StorageLocation.fromJson(maps.first);
  }

  Future<void> deleteStorageLocation(int id) async {
    final db = await database;
    await db.delete(
      'storage_locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sync operations
  Future<void> addSyncLog(String entityType, int entityId, String action, Map<String, dynamic> data, String deviceId) async {
    final db = await database;
    await db.insert(
      'sync_logs',
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'data': data.toString(),
        'device_id': deviceId,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs(String deviceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_logs',
      where: 'device_id = ? AND synced = ?',
      whereArgs: [deviceId, 0],
    );
    return maps;
  }

  Future<void> markSyncLogAsSynced(int syncLogId) async {
    final db = await database;
    await db.update(
      'sync_logs',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [syncLogId],
    );
  }

  // Generated barcode operations
  Future<void> saveGeneratedBarcode(GeneratedBarcode barcode, {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.insert(
      'generated_barcodes',
      {
        'barcode': barcode.barcode,
        'document_type': barcode.documentType,
        'generated_at': barcode.generatedAt.toIso8601String(),
        'is_used': barcode.isUsed ? 1 : 0,
        'document_id': barcode.documentId,
        'storage_location': barcode.storageLocation,
        'sync_status': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GeneratedBarcode>> getGeneratedBarcodes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'generated_barcodes',
      orderBy: 'generated_at DESC',
    );
    return List.generate(maps.length, (i) {
      final map = maps[i];
      return GeneratedBarcode(
        barcode: map['barcode'],
        documentType: map['document_type'],
        generatedAt: DateTime.parse(map['generated_at']),
        isUsed: map['is_used'] == 1,
        documentId: map['document_id'],
        storageLocation: map['storage_location'],
      );
    });
  }

  Future<GeneratedBarcode?> getGeneratedBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'generated_barcodes',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isEmpty) return null;
    final map = maps.first;
    return GeneratedBarcode(
      barcode: map['barcode'],
      documentType: map['document_type'],
      generatedAt: DateTime.parse(map['generated_at']),
      isUsed: map['is_used'] == 1,
      documentId: map['document_id'],
      storageLocation: map['storage_location'],
    );
  }

  Future<void> updateGeneratedBarcode(GeneratedBarcode barcode) async {
    final db = await database;
    await db.update(
      'generated_barcodes',
      {
        'document_type': barcode.documentType,
        'generated_at': barcode.generatedAt.toIso8601String(),
        'is_used': barcode.isUsed ? 1 : 0,
        'document_id': barcode.documentId,
        'storage_location': barcode.storageLocation,
      },
      where: 'barcode = ?',
      whereArgs: [barcode.barcode],
    );
  }

  Future<void> deleteGeneratedBarcode(String barcode) async {
    final db = await database;
    await db.delete(
      'generated_barcodes',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
  }

  Future<Document?> getDocumentByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isEmpty) return null;
    return Document.fromJson(maps.first);
  }
} 