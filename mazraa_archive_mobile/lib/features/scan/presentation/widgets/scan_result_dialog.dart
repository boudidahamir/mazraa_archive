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
          const Icon(Icons.description_outlined, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Détails du document'),
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
                        'Vous consultez des données en cache. Les modifications seront synchronisées lorsque vous serez en ligne.',
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
              'Informations du document',
              [
                _buildInfoRow('Type', document.documentTypeName),
                _buildInfoRow('Titre', document.title),
                if (document.description != null)
                  _buildInfoRow('Description', document.description!),
                _buildInfoRow('Statut', document.status),
                _buildInfoRow(
                  'Créé le',
                  '${document.createdAt.day.toString().padLeft(2, '0')}/${document.createdAt.month.toString().padLeft(2, '0')}/${document.createdAt.year}',
                ),
                if (document.updatedAt != null)
                  _buildInfoRow(
                    'Dernière modification',
                    '${document.updatedAt!.day.toString().padLeft(2, '0')}/${document.updatedAt!.month.toString().padLeft(2, '0')}/${document.updatedAt!.year}',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (document.storageLocationId != null)
              _buildInfoSection(
                context,
                'Emplacement de stockage',
                [
                  _buildInfoRow('Code', document.storageLocationCode ?? ""),
                  if (storageLocation != null) ...[
                    _buildInfoRow('Nom', storageLocation!.name),
                    _buildInfoRow('Étagère', storageLocation!.shelf),
                    _buildInfoRow('Rangée', storageLocation!.row),
                    _buildInfoRow('Boîte', storageLocation!.box),
                    _buildInfoRow(
                      'Espace utilisé',
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
          label: const Text('Fermer'),
        ),
        if (document.storageLocationId == null)
          ElevatedButton.icon(
            onPressed: onAssignLocation,
            icon: const Icon(Icons.storage),
            label: const Text('Assigner l\'emplacement'),
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