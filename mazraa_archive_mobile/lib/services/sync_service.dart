import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'api_service.dart';
import 'local_storage_service.dart';
import '../core/models/document.dart';
import '../core/models/storage_location.dart';

class SyncService {
  final ApiService _apiService;
  final LocalStorageService _localStorage;
  final DeviceInfoPlugin _deviceInfo;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._apiService, this._localStorage)
      : _deviceInfo = DeviceInfoPlugin() {
    _initSync();
  }

  Future<void> _initSync() async {
    // Check connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncData();
      }
    });

    // Start periodic sync
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      syncData();
    });
  }

  Future<String> getDeviceId() async {
    final androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.id;
  }

  Future<void> syncData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final deviceId = await getDeviceId();
      final pendingSyncs = await _localStorage.getPendingSyncs(deviceId);

      if (pendingSyncs.isEmpty) {
        _isSyncing = false;
        return;
      }

      // Group syncs by entity type
      final documentSyncs = pendingSyncs.where((sync) => sync['entity_type'] == 'document');
      final locationSyncs = pendingSyncs.where((sync) => sync['entity_type'] == 'storage_location');

      // Sync documents
      for (final sync in documentSyncs) {
        try {
          final document = Document.fromJson(sync['data']);
          switch (sync['action']) {
            case 'create':
              await _apiService.createDocument(document);
              break;
            case 'update':
              await _apiService.updateDocument(document.id!, document);
              break;
            case 'delete':
              await _apiService.deleteDocument(document.id!);
              break;
          }
          await _localStorage.markSyncLogAsSynced(sync['id']);
        } catch (e) {
          // Handle sync errors
          print('Error syncing document: $e');
        }
      }

      // Sync storage locations
      for (final sync in locationSyncs) {
        try {
          final location = StorageLocation.fromJson(sync['data']);
          switch (sync['action']) {
            case 'create':
              await _apiService.createStorageLocation(location);
              break;
            case 'update':
              await _apiService.updateStorageLocation(location.id!, location);
              break;
            case 'delete':
              await _apiService.deleteStorageLocation(location.id!);
              break;
          }
          await _localStorage.markSyncLogAsSynced(sync['id']);
        } catch (e) {
          // Handle sync errors
          print('Error syncing storage location: $e');
        }
      }

      // Get latest data from server
      final documents = await _apiService.getDocuments();
      final locations = await _apiService.getStorageLocations();

      // Update local storage
      for (final document in documents) {
        await _localStorage.saveDocument(document);
      }
      for (final location in locations) {
        await _localStorage.saveStorageLocation(location);
      }
    } catch (e) {
      // Handle general sync errors
      print('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    _syncTimer?.cancel();
  }
} 