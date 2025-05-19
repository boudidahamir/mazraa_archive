import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/models/document.dart';
import '../core/models/document_type.dart';
import '../core/models/storage_location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://fallback:8080/api';

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
  Future<String> generateBarcode(String documentType, int documentId) async {
    final response = await _dio.post('/barcodes/generate', queryParameters: {
      'documentType': documentType,
      'id': documentId,
    });

    return response.data;
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

  // Fetch a document by barcode
  Future<Document?> getDocumentByBarcode(String barcode) async {
    final response = await _dio.get('/documents/barcode/$barcode');
    if (response.data == null) return null;
    return Document.fromJson(response.data);
  }

  // Alias for getStorageLocations
  Future<List<StorageLocation>> getAvailableLocations() async {
    return getStorageLocations();
  }

  Future<List<Document>> getDocumentsByType(String documentTypeCode) async {
    final response = await _dio.get('/documents/by-type-code/$documentTypeCode');
    if (response.statusCode == 200) {
      return (response.data as List).map((json) => Document.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  Future<List<DocumentType>> getDocumentTypes() async {
    final response = await _dio.get('/document-types');

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => DocumentType.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load document types');
    }
  }

  getStorageLocationById(int i) {

  }

} 