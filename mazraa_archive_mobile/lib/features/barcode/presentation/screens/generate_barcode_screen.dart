import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../../../core/models/document_type.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/models/storage_location.dart';
import '../../../../core/models/document.dart';
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


  List<StorageLocation> _locations = [];
  List<Document> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadDocumentTypes();
  }

  Future<void> _loadDocumentTypes() async {
    setState(() => _isLoadingDocumentTypes = true);
    try {
      final apiService = context.read<ApiService>();
      final types = await apiService.getDocumentTypes();
      setState(() => _documentTypes = types);
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
      final apiService = context.read<ApiService>();
      final locations = await apiService.getAvailableLocations();
      if (!mounted) return;
      setState(() => _locations = locations);
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
      final apiService = context.read<ApiService>();
      final docs = await apiService.getDocumentsByType(documentType);
      if (!mounted) return;
      setState(() => _documents = docs);
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
      final apiService = context.read<ApiService>();
      final barcode = await apiService.generateBarcode(
        _selectedDocumentType!.code,
        _selectedDocument!.id,
      );
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
      final localStorage = context.read<LocalStorageService>();
      final barcode = GeneratedBarcode(
        barcode: _generatedBarcode!,
        documentType: _selectedDocumentType!,
        generatedAt: DateTime.now(),
        storageLocation: _selectedLocation!.code,
      );
      await localStorage.saveGeneratedBarcode(barcode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode saved successfully'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('Generate Barcode')),
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
                    const Text('Document Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          _loadDocuments(value.code); // use the .code to fetch related documents
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
                    const Text('Storage Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            : const Text('Generate Barcode'),
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
                      const Text('Generated Barcode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            label: const Text('Save'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement share
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
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
