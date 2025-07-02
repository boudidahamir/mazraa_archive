import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/models/document.dart';
import '../widgets/document_list_item.dart';
import '../widgets/document_search_bar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Document> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final localStorage = context.read<LocalStorageService>();
      final documents = await localStorage.getDocuments();
      setState(() {
        _documents = documents;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Échec de la chargement des documents';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    // TODO: Implement search functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add document screen
            },
            tooltip: 'Ajouter un document',
          ),
        ],
      ),
      body: Column(
        children: [
          DocumentSearchBar(onSearch: _onSearch),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDocuments,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _documents.isEmpty
                        ? const Center(
                            child: Text('Aucun document trouvé'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _documents.length,
                            itemBuilder: (context, index) {
                              final document = _documents[index];
                              return DocumentListItem(
                                document: document,
                                onTap: () {
                                  // TODO: Navigate to document details
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
} 