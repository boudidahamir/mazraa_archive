import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/models/document.dart';
import '../core/models/document_type.dart';
import '../core/models/storage_location.dart';
import '../core/models/user.dart';
import '../features/barcode/domain/models/generated_barcode.dart';

class LocalStorageService {
  static Database? _database;
  static const String _dbName = 'mazraa_archive.db';
  static const int _dbVersion = 3;

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
      onUpgrade: _upgradeDatabase,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Rename old table to temp
      await db.execute(
          'ALTER TABLE storage_locations RENAME TO temp_storage_locations');

      // Recreate storage_locations with new column names (camelCase)
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
        usedSpace INTEGER NOT NULL,
        active INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        createdById INTEGER,
        updatedById INTEGER,
        sync_status TEXT NOT NULL
      )
    ''');

      // Copy data from old table
      await db.execute('''
      INSERT INTO storage_locations (
        id, code, name, description, shelf, row, box,
        capacity, usedSpace, active, createdAt, updatedAt,
        createdById, updatedById, sync_status
      )
      SELECT
        id, code, name, description, shelf, row, box,
        capacity, used_space, active, created_at, updated_at,
        created_by_id, updated_by_id, sync_status
      FROM temp_storage_locations
    ''');

      // Remove temp table
      await db.execute('DROP TABLE temp_storage_locations');

      // Ensure document_types and users exist (in case this upgrade path skipped onCreate)
      await db.execute('''
      CREATE TABLE IF NOT EXISTS document_types (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        created_by_id INTEGER,
        updated_by_id INTEGER
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        fullName TEXT NOT NULL,
        role TEXT NOT NULL,
        enabled INTEGER NOT NULL,
        deviceId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        createdById INTEGER,
        updatedById INTEGER,
        isActive INTEGER,
        roles TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS current_user (
        id INTEGER PRIMARY KEY,
        user_id INTEGER
      )
    ''');
    }
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
  usedSpace INTEGER NOT NULL,
  active INTEGER NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  createdById INTEGER,
  updatedById INTEGER,
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

    await db.execute('''
  CREATE TABLE document_types (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    created_by_id INTEGER,
    updated_by_id INTEGER
  )
''');

    await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    fullName TEXT NOT NULL,
    role TEXT NOT NULL,
    enabled INTEGER NOT NULL,
    deviceId TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    createdById INTEGER,
    updatedById INTEGER,
    isActive INTEGER,
    roles TEXT
  )
''');
  }

  // Document operations
  Future<void> saveDocument(Document document,
      {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.insert(
      'documents',
      document.toSqliteMap(syncStatus: syncStatus),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );


  }

  Future<List<Document>> getDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents');
    return List.generate(maps.length, (i) => Document.fromSqlite(maps[i]));
  }

  Future<Document?> getDocumentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Document.fromSqlite(maps.first);
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
  Future<void> saveStorageLocation(StorageLocation location,
      {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.insert(
      'storage_locations',
      location.toSqliteMap(syncStatus: syncStatus),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );


  }

  Future<List<StorageLocation>> getStorageLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('storage_locations');
    return List.generate(maps.length, (i) => StorageLocation.fromSqlite(maps[i]));
  }

  Future<StorageLocation?> getStorageLocationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'storage_locations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return StorageLocation.fromSqlite(maps.first);
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
  Future<void> addSyncLog(String entityType, int entityId, String action,
      Map<String, dynamic> data, String deviceId) async {
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

  Future<void> saveGeneratedBarcode(GeneratedBarcode barcode,
      {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.insert(
      'generated_barcodes',
      {
        'barcode': barcode.barcode,
        'document_type': barcode.documentType,
        'generated_at': barcode.generatedAt.toIso8601String(),
        'is_used': barcode.isUsed ? 1 : 0,
        'document_id': barcode.documentId?.toString(),
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

  Future<void> updateGeneratedBarcode(GeneratedBarcode barcode,
      {String syncStatus = 'synced'}) async {
    final db = await database;
    await db.update(
      'generated_barcodes',
      {
        'document_type': barcode.documentType,
        'generated_at': barcode.generatedAt.toIso8601String(),
        'is_used': barcode.isUsed ? 1 : 0,
        'document_id': barcode.documentId?.toString(),
        'storage_location': barcode.storageLocation,
        'sync_status': syncStatus,
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

  Future<List<DocumentType>> getDocumentTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('document_types');
    return List.generate(maps.length, (i) => DocumentType.fromSqlite(maps[i]));
  }

  Future<void> saveDocumentType(DocumentType type) async {
    final db = await database;
    Future<void> saveDocumentType(DocumentType type) async {
      final db = await database;
      await db.insert(
        'document_types',
        {
          'id': type.id,
          'name': type.name,
          'code': type.code,
          'description': type.description,
          'created_at': type.createdAt.toIso8601String(),
          'updated_at': type.updatedAt.toIso8601String(),
          'created_by_id': type.createdById,
          'updated_by_id': type.updatedById,
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // <-- add this line
      );
    }


  }

  Future<List<Document>> getDocumentsByType(String documentType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'document_type = ?',
      whereArgs: [documentType],
    );
    return List.generate(maps.length, (i) => Document.fromSqlite(maps[i]));
  }

  // Save or update a user
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'fullName': user.fullName,
        'role': user.role.name.toUpperCase(),
        'enabled': user.enabled ? 1 : 0,
        'deviceId': user.deviceId,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt?.toIso8601String(),
        'createdById': user.createdById,
        'updatedById': user.updatedById,
        'isActive': user.isActive == null ? null : (user.isActive! ? 1 : 0),
        'roles': user.roles,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Get all users
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

// Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

// Delete user by ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Save currently logged-in user
  Future<void> saveCurrentUserId(int userId) async {
    final db = await database;
    await db.execute(
        'CREATE TABLE IF NOT EXISTS current_user (id INTEGER PRIMARY KEY, user_id INTEGER)');
    await db.delete('current_user');
    await db.insert('current_user', {'id': 1, 'user_id': userId});
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    final result = await db.query('current_user');
    if (result.isEmpty) return null;
    return getUserById(result.first['user_id'] as int);
  }

  
}
