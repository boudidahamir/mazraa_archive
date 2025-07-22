import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../services/sync_service.dart';
import '../../../../core/models/document.dart';
import '../../../../core/models/document_type.dart';
import '../../../../core/models/storage_location.dart';
import '../../../barcode/domain/models/generated_barcode.dart';

class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({super.key});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DocumentType? _selectedDocumentType;
  StorageLocation? _selectedLocation;
  final Map<String, String> _statusMap = {
    'Actif': 'ACTIVE',
    'Archivé': 'ARCHIVED',
    'Détruit': 'DESTROYED',
    'Retiré': 'RETRIEVED',
  };
  String _selectedStatus = 'Actif';
  
  List<DocumentType> _documentTypes = [];
  List<StorageLocation> _locations = [];
  
  bool _isLoading = false;
  bool _isLoadingTypes = false;
  bool _isLoadingLocations = false;
  bool _isGeneratingBarcode = false;
  bool _isSavingBarcode = false;
  bool _isOnline = true;
  String? _errorMessage;
  String? _generatedBarcode;
  Document? _createdDocument;

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivityAndLoad() async {
    final result = await Connectivity().checkConnectivity();
    setState(() => _isOnline = result != ConnectivityResult.none);

    await _loadDocumentTypes();
    await _loadLocations();
  }

  Future<void> _loadDocumentTypes() async {
    setState(() => _isLoadingTypes = true);
    try {
      if (_isOnline) {
        final apiService = context.read<ApiService>();
        final types = await apiService.getDocumentTypes();

        final localStorage = context.read<LocalStorageService>();
        for (final type in types) {
          await localStorage.saveDocumentType(type);
        }

        setState(() => _documentTypes = types);
      } else {
        final localStorage = context.read<LocalStorageService>();
        final types = await localStorage.getDocumentTypes();
        setState(() => _documentTypes = types);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Échec de la chargement des types de document : $e');
    } finally {
      setState(() => _isLoadingTypes = false);
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
    } catch (e) {
      setState(() => _errorMessage = 'Échec de la chargement des emplacements de stockage : $e');
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _createDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDocumentType == null || _selectedLocation == null) {
      setState(() => _errorMessage = 'Veuillez sélectionner le type de document et l\'emplacement de stockage');
      return;
    }

    // Validate that the selected location has a valid ID
    if (_selectedLocation!.id == null) {
      setState(() => _errorMessage = 'L\'emplacement de stockage sélectionné est invalide. Veuillez en choisir un autre.');
      setState(() => _errorMessage = 'Selected storage location is invalid. Please select a different location.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final localStorage = context.read<LocalStorageService>();
      final syncService = context.read<SyncService>();

      // Create new document
      final newDocument = Document(
        id: 0, // Will be assigned by server
        title: _titleController.text.trim(),
        barcode: null, // Always send null for new document creation
        description: _descriptionController.text.trim(),
        status: _statusMap[_selectedStatus]!,
        documentTypeId: _selectedDocumentType!.id,
        documentTypeName: _selectedDocumentType!.code,
        storageLocationId: _selectedLocation!.id!,
        storageLocationCode: _selectedLocation!.code,
        archived: _selectedStatus == 'Archived',
        archivedAt: _selectedStatus == 'Archived' ? DateTime.now() : null,
        archivedById: null,
        archivedByName: '',
        createdAt: DateTime.now(),
        updatedAt: null,
        createdById: 1, // TODO: Get actual user ID
        createdByName: 'User', // TODO: Get actual user name
        updatedById: null,
        updatedByName: '',
      );

      Document createdDocument;
      if (_isOnline) {
        // Create document on server
        createdDocument = await apiService.createDocument(newDocument);
        await localStorage.saveDocument(createdDocument);

        // Update location used space
        final updatedLocation = _selectedLocation!.copyWith(
          usedSpace: _selectedLocation!.usedSpace + 1,
        );
        await apiService.updateStorageLocation(_selectedLocation!.id!, updatedLocation);
        await localStorage.saveStorageLocation(updatedLocation);
      } else {
        // Save locally and queue for sync
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final localDocument = newDocument.copyWith(id: tempId);
        
        await localStorage.saveDocument(localDocument, syncStatus: 'pending');
        await localStorage.addSyncLog(
          'document',
          tempId,
          'create',
          localDocument.toJson(),
          await syncService.getDeviceId(),
        );
        
        createdDocument = localDocument;
      }

      setState(() {
        _createdDocument = createdDocument;
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isOnline
                      ? 'Document created successfully'
                      : 'Document created locally (will sync when online)',
                ),
              ),
            ],
          ),
          backgroundColor: _isOnline ? Colors.green : Colors.orange,
        ),
      );

      // Automatically generate barcode after document creation
      await _generateBarcode();
      
    } catch (e) {
      setState(() => _errorMessage = 'Échec de la création du document : $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateBarcode() async {
    if (_createdDocument == null || _selectedDocumentType == null) {
      setState(() => _errorMessage = 'Veuillez d\'abord créer un document');
      return;
    }

    setState(() {
      _isGeneratingBarcode = true;
      _errorMessage = null;
    });

    try {
      String barcode;

      if (_isOnline) {
        final apiService = context.read<ApiService>();
        barcode = await apiService.generateBarcode(
          _selectedDocumentType!.code,
          _createdDocument!.id,
        );
      } else {
        // Local barcode generation fallback: PREFIX-00001234
        final prefix = _selectedDocumentType!.code;
        final id = _createdDocument!.id;
        barcode = '$prefix-${id.toString().padLeft(8, '0')}';
      }

      if (!mounted) return;
      setState(() => _generatedBarcode = barcode);
    } catch (e) {
      setState(() => _errorMessage = 'Échec de la génération du code-barres : $e');
    } finally {
      setState(() => _isGeneratingBarcode = false);
    }
  }

  Future<void> _saveBarcode() async {
    if (_generatedBarcode == null || _createdDocument == null) return;

    setState(() => _isSavingBarcode = true);

    try {
      final apiService = context.read<ApiService>();
      final localStorage = context.read<LocalStorageService>();
      final syncService = context.read<SyncService>();

      final isOnline = await Connectivity().checkConnectivity() != ConnectivityResult.none;

      // 1. Prepare updated document with barcode
      final updatedDocument = _createdDocument!.copyWith(
        barcode: _generatedBarcode!,
        documentTypeId: _selectedDocumentType!.id,
        documentTypeName: _selectedDocumentType!.code,
      );

      // 2. Save document (online or queue)
      if (isOnline) {
        await apiService.updateDocument(_createdDocument!.id!, updatedDocument);
        await localStorage.saveDocument(updatedDocument);
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

      // 3. Save barcode locally (generated_barcodes table)
      final barcode = GeneratedBarcode(
        barcode: _generatedBarcode!,
        documentType: _selectedDocumentType!.code,
        generatedAt: DateTime.now(),
        documentId: _createdDocument!.id,
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

      // Navigate back to scan screen
      Navigator.of(context).pop();
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Échec de l\'enregistrement du code-barres : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'enregistrement du code-barres : $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSavingBarcode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un nouveau document'),
        actions: [
          if (!_isOnline)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Document Creation Form
            if (_createdDocument == null) ...[
              Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations du document',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Titre *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Status dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Statut *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info_outline),
                          ),
                          items: _statusMap.keys.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedStatus = value!);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Document Type dropdown
                        const Text('Type de document *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_isLoadingTypes)
                          const Center(child: CircularProgressIndicator())
                        else
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
                              setState(() => _selectedDocumentType = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a document type';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 16),

                        // Storage Location dropdown
                        const Text('Emplacement de stockage *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a storage location';
                              }
                              return null;
                            },
                          ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _createDocument,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: Text(_isLoading ? 'Création...' : 'Créer le document'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Barcode Generation Section
            if (_createdDocument != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Document créé avec succès',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Titre : ${_createdDocument!.title}'),
                      if (_createdDocument!.description?.isNotEmpty == true)
                        Text('Description : ${_createdDocument!.description}'),
                      Text('Statut : ${_createdDocument!.status}'),
                      Text('Type : ${_createdDocument!.documentTypeName}'),
                      Text('Emplacement : ${_createdDocument!.storageLocationCode}'),
                      const SizedBox(height: 24),
                      
                      if (_generatedBarcode == null) ...[
                        const Text('Générer un code-barres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingBarcode ? null : _generateBarcode,
                            icon: _isGeneratingBarcode
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.qr_code),
                            label: Text(_isGeneratingBarcode ? 'Génération...' : 'Générer un code-barres'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ] else ...[
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
                              'Emplacement : ${_selectedLocation!.name} (${_selectedLocation!.code})',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isSavingBarcode ? null : _saveBarcode,
                              icon: _isSavingBarcode
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
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
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _titleController.text = _createdDocument!.title;
                                  _descriptionController.text = _createdDocument!.description ?? '';
                                  _selectedStatus = _statusMap.entries
                                      .firstWhere((e) => e.value == _createdDocument!.status,
                                                  orElse: () => MapEntry('Actif', 'ACTIVE'))
                                      .key;
                                  _selectedDocumentType = _documentTypes.firstWhere(
                                      (type) => type.id == _createdDocument!.documentTypeId,
                                      orElse: () => _documentTypes.first);
                                  _selectedLocation = _locations.firstWhere(
                                      (loc) => loc.id == _createdDocument!.storageLocationId,
                                      orElse: () => _locations.first);
                                  _createdDocument = null; // Go back to form mode
                                  _generatedBarcode = null;
                                  // Reset for new creation
                                  // (ID and barcode will be set to 0/null/empty in _createDocument)
                                });
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Modifier le document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
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