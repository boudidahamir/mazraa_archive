import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/models/document.dart';
import '../core/models/storage_location.dart';
import '../core/models/user.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _baseUrl = 'http://localhost:8080/api';

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        )),
        _storage = const FlutterSecureStorage() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiration
          _storage.delete(key: 'auth_token');
          // TODO: Navigate to login screen
        }
        return handler.next(e);
      },
    ));
  }

  // Authentication
  Future<String> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final token = response.data['token'];
    await _storage.write(key: 'auth_token', value: token);
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Documents
  Future<List<Document>> getDocuments() async {
    final response = await _dio.get('/documents');
    return (response.data as List)
        .map((json) => Document.fromJson(json))
        .toList();
  }

  Future<Document> createDocument(Document document) async {
    final response = await _dio.post('/documents', data: document.toJson());
    return Document.fromJson(response.data);
  }

  Future<Document> updateDocument(int id, Document document) async {
    final response = await _dio.put('/documents/$id', data: document.toJson());
    return Document.fromJson(response.data);
  }

  Future<void> deleteDocument(int id) async {
    await _dio.delete('/documents/$id');
  }

  // Storage Locations
  Future<List<StorageLocation>> getStorageLocations() async {
    final response = await _dio.get('/storage-locations');
    return (response.data as List)
        .map((json) => StorageLocation.fromJson(json))
        .toList();
  }

  Future<StorageLocation> createStorageLocation(StorageLocation location) async {
    final response = await _dio.post('/storage-locations', data: location.toJson());
    return StorageLocation.fromJson(response.data);
  }

  Future<StorageLocation> updateStorageLocation(int id, StorageLocation location) async {
    final response = await _dio.put('/storage-locations/$id', data: location.toJson());
    return StorageLocation.fromJson(response.data);
  }

  Future<void> deleteStorageLocation(int id) async {
    await _dio.delete('/storage-locations/$id');
  }

  // Barcode
  Future<String> generateBarcode(String documentType) async {
    final response = await _dio.post('/barcodes/generate', data: {
      'documentType': documentType,
    });
    return response.data['barcode'];
  }

  Future<bool> validateBarcode(String barcode) async {
    final response = await _dio.post('/barcodes/validate', data: {
      'barcode': barcode,
    });
    return response.data['valid'];
  }

  // Sync
  Future<Map<String, dynamic>> syncChanges(Map<String, dynamic> changes) async {
    final response = await _dio.post('/sync', data: changes);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs(String deviceId) async {
    final response = await _dio.get('/sync/pending/$deviceId');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> markAsSynced(int syncLogId) async {
    await _dio.post('/sync/$syncLogId/mark-synced');
  }

  Future<void> resolveConflict(int syncLogId, String resolution) async {
    await _dio.post('/sync/$syncLogId/resolve-conflict', data: {
      'resolution': resolution,
    });
  }
} 