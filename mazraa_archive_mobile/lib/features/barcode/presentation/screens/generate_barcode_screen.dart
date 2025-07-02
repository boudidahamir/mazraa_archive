import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../../../core/models/document_type.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/models/storage_location.dart';
import '../../../../core/models/document.dart';
import '../../../../services/sync_service.dart';
import '../../domain/models/generated_barcode.dart';

class GenerateBarcodeScreen extends StatefulWidget {
  const GenerateBarcodeScreen({super.key});

  @override
  State<GenerateBarcodeScreen> createState() => _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState extends State<GenerateBarcodeScreen> {
  Document? _selectedDocument;
  StorageLocation? _selectedLocation;
  String? _generatedBarcode;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoadingLocations = false;
  bool _isLoadingDocuments = false;
  String? _errorMessage;
  List<DocumentType> _documentTypes = [];
  DocumentType? _selectedDocumentType;
  bool _isLoadingDocumentTypes = false;
  bool _isOnline = true;

  List<StorageLocation> _locations = [];
  List<Document> _documents = [];

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
  }

  Future<void> _checkConnectivityAndLoad() async {
    final result = await Connectivity().checkConnectivity();
    setState(() => _isOnline = result != ConnectivityResult.none);

    await _loadDocumentTypes();
    await _loadLocations();
  }

  Future<void> _loadDocumentTypes() async {
    setState(() => _isLoadingDocumentTypes = true);
    try {
      if (_isOnline) {
        final apiService = context.read<ApiService>();
        final types = await apiService.getDocumentTypes();

        final localStorage = context.read<LocalStorageService>();
        for (final type in types) {
          await localStorage.saveDocumentType(type); // Assuming you added this method
        }

        setState(() => _documentTypes = types);
      } else {
        final localStorage = context.read<LocalStorageService>();
        final types = await localStorage.getDocumentTypes(); // Add this method
        setState(() => _documentTypes = types);
      }
      setState(() => _generatedBarcode = null);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load document types: $e');
    } finally {
      setState(() => _isLoadingDocumentTypes = false);
    }
  }


  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);
    try {
      if (_isOnline) {
        final apiService = context.read<ApiService>();
        final locations = await apiService.getAvailableLocations();

        final localStorage = context.read<LocalStorageService>();
        for (final loc in locations) {
          await localStorage.saveStorageLocation(loc);
        }

        setState(() => _locations = locations);
      } else {
        final localStorage = context.read<LocalStorageService>();
        final locations = await localStorage.getStorageLocations();
        setState(() => _locations = locations);
      }

      setState(() => _generatedBarcode = null);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load storage locations: $e');
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }


  Future<void> _loadDocuments(String documentType) async {
    setState(() => _isLoadingDocuments = true);
    try {
      if (_isOnline) {
        final apiService = context.read<ApiService>();
        final docs = await apiService.getDocumentsByType(documentType);

        final localStorage = context.read<LocalStorageService>();
        for (final doc in docs) {
          await localStorage.saveDocument(doc);
        }

        setState(() => _documents = docs);
      } else {
        final localStorage = context.read<LocalStorageService>();
        final docs = await localStorage.getDocumentsByType(documentType); // You need this
        setState(() => _documents = docs);
      }

      setState(() => _generatedBarcode = null);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load documents: $e');
    } finally {
      setState(() => _isLoadingDocuments = false);
    }
  }


  Future<void> _generateBarcode() async {
    if (_selectedDocumentType == null || _selectedDocument == null || _selectedLocation == null) {
      setState(() {
        _errorMessage = 'Please select document type, document, and storage location';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String barcode;

      if (_isOnline) {
        final apiService = context.read<ApiService>();
        barcode = await apiService.generateBarcode(
          _selectedDocumentType!.code,
          _selectedDocument!.id,
        );
      } else {
        // Local barcode generation fallback: PREFIX-00001234
        final prefix = _selectedDocumentType!.code;
        final id = _selectedDocument!.id;
        barcode = '$prefix-${id.toString().padLeft(8, '0')}';
      }


      if (!mounted) return;
      setState(() => _generatedBarcode = barcode);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to generate barcode: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBarcode() async {
    if (_generatedBarcode == null) return;

    setState(() => _isSaving = true);

    try {
      final apiService = context.read<ApiService>();
      final localStorage = context.read<LocalStorageService>();
      final syncService = context.read<SyncService>();

      final isOnline = await Connectivity().checkConnectivity() != ConnectivityResult.none;
      final isNewLocation = _selectedDocument!.storageLocationId != _selectedLocation!.id;

      // 1. Prepare updated document
      final updatedDocument = _selectedDocument!.copyWith(
        barcode: _generatedBarcode!,
        storageLocationId: _selectedLocation!.id,
        storageLocationCode: _selectedLocation!.code,
        documentTypeId: _selectedDocumentType!.id,
        documentTypeName: _selectedDocumentType!.code
      );

      // 2. Save document (online or queue)
      if (isOnline) {
        await apiService.updateDocument(_selectedDocument!.id!, updatedDocument);
      } else {
        await localStorage.saveDocument(updatedDocument, syncStatus: 'pending');
        await localStorage.addSyncLog(
          'document',
          updatedDocument.id!,
          'update',
          updatedDocument.toJson(),
          await syncService.getDeviceId(),
        );
      }

      // 3. Update location if needed
      if (isNewLocation) {
        final updatedLocation = _selectedLocation!.copyWith(
          usedSpace: _selectedLocation!.usedSpace + 1,
        );

        if (isOnline) {
          await apiService.updateStorageLocation(updatedLocation.id!, updatedLocation);
        } else {
          await localStorage.saveStorageLocation(updatedLocation, syncStatus: 'pending');
          await localStorage.addSyncLog(
            'storage_location',
            updatedLocation.id!,
            'update',
            updatedLocation.toJson(),
            await syncService.getDeviceId(),
          );
        }
      }

      // 4. Save barcode locally (generated_barcodes table)
      final barcode = GeneratedBarcode(
        barcode: _generatedBarcode!,
        documentType: _selectedDocumentType!.code,
        generatedAt: DateTime.now(),
        documentId: _selectedDocument!.id,
        storageLocation: _selectedLocation!.code,
      );
      await localStorage.saveGeneratedBarcode(barcode);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOnline
                ? 'Barcode saved successfully'
                : 'Saved locally – will sync when back online',
          ),
          backgroundColor: isOnline ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save barcode: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Générer un code-barres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type de document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DocumentType>(
                      value: _selectedDocumentType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: _documentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDocumentType = value;
                          _selectedDocument = null;
                          _documents = [];
                        });
                        if (value != null) {
                          if(_isOnline){_loadDocuments(value.code);}
                          else{_loadDocuments(value.name);}
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_isLoadingDocuments)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<Document>(
                        value: _selectedDocument,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: _documents.map((doc) {
                          return DropdownMenuItem(
                            value: doc,
                            child: Text(doc.title), // Adjust to match your Document model
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDocument = value);
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text('Emplacement de stockage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_isLoadingLocations)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<StorageLocation>(
                        value: _selectedLocation,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text('${location.name} (${location.code})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedLocation = value);
                        },
                      ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _selectedDocumentType == null || _selectedDocument == null || _selectedLocation == null)
                            ? null
                            : _generateBarcode,

                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                            : const Text('Générer le code-barres'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_generatedBarcode != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Code-barres généré', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Center(
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: _generatedBarcode!,
                          width: 200,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(_generatedBarcode!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      if (_selectedLocation != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Location: ${_selectedLocation!.name} (${_selectedLocation!.code})',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveBarcode,
                            icon: _isSaving
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                                : const Icon(Icons.save),
                            label: const Text('Enregistrer'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement share
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Partager'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
