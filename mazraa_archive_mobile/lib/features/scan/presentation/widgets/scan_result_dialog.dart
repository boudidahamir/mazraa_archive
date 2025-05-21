import 'package:flutter/material.dart';
import '../../../../core/models/document.dart';
import '../../../../core/models/storage_location.dart';

class ScanResultDialog extends StatelessWidget {
  final Document document;
  final bool isOnline;
  final VoidCallback onClose;
  final VoidCallback onAssignLocation;
  final StorageLocation? storageLocation;

  const ScanResultDialog({
    super.key,
    required this.document,
    required this.isOnline,
    required this.onClose,
    required this.onAssignLocation,
    this.storageLocation
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('Document Details'),
          if (!isOnline) ...[
            const SizedBox(width: 8),
            Container(
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
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are viewing cached data. Changes will sync when online.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildInfoSection(
              context,
              'Document Information',
              [
                _buildInfoRow('Type', document.documentTypeName),
                _buildInfoRow('Title', document.title),
                if (document.description != null)
                  _buildInfoRow('Description', document.description!),
                _buildInfoRow('Status', document.status),
                _buildInfoRow(
                  'Created',
                  '${document.createdAt.day}/${document.createdAt.month}/${document.createdAt.year}',
                ),
                if (document.updatedAt != null)
                  _buildInfoRow(
                    'Last Updated',
                    '${document.updatedAt!.day}/${document.updatedAt!.month}/${document.updatedAt!.year}',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (document.storageLocationId != null)
              _buildInfoSection(
                context,
                'Storage Location',
                [
                  _buildInfoRow('Code', document.storageLocationCode),
                  if (storageLocation != null) ...[
                    _buildInfoRow('Name', storageLocation!.name),
                    _buildInfoRow('Shelf', storageLocation!.shelf),
                    _buildInfoRow('Row', storageLocation!.row),
                    _buildInfoRow('Box', storageLocation!.box),
                    _buildInfoRow(
                      'Space Used',
                      '${storageLocation!.usedSpace}/${storageLocation!.capacity}',
                    ),
                  ],
                ],
              ),

          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: onClose,
          icon: const Icon(Icons.close),
          label: const Text('Close'),
        ),
        if (document.storageLocationId == null)
          ElevatedButton.icon(
            onPressed: onAssignLocation,
            icon: const Icon(Icons.storage),
            label: const Text('Assign Location'),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 