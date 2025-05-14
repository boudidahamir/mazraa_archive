import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';

class ScanResultDialog extends StatefulWidget {
  final String barcode;
  final VoidCallback onClose;

  const ScanResultDialog({
    super.key,
    required this.barcode,
    required this.onClose,
  });

  @override
  State<ScanResultDialog> createState() => _ScanResultDialogState();
}

class _ScanResultDialogState extends State<ScanResultDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _documentData;

  @override
  void initState() {
    super.initState();
    _loadDocumentData();
  }

  Future<void> _loadDocumentData() async {
    try {
      final apiService = context.read<ApiService>();
      final documentId = await apiService.extractIdFromBarcode(widget.barcode);
      final location = await apiService.getLocationForBarcode(widget.barcode);

      if (!mounted) return;

      setState(() {
        _documentData = {
          'id': documentId,
          'barcode': widget.barcode,
          'location': location,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading document data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Result',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_documentData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Barcode', _documentData!['barcode']),
                  const SizedBox(height: 8),
                  _buildInfoRow('Document ID', _documentData!['id'].toString()),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Location',
                    _documentData!['location'] ?? 'Not assigned',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onClose();
                        },
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to document details screen
                          Navigator.of(context).pop();
                          widget.onClose();
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
} 