import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../services/sync_service.dart';
import '../../../../core/models/document.dart';
import '../../../../core/models/storage_location.dart';
import '../widgets/scan_result_dialog.dart';
import '../../../barcode/presentation/screens/generate_barcode_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _isOnline = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  StorageLocation? location;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;
    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
      return;
    }

    final String? code = barcodes.first.rawValue;
    if (code == null) {
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
      return;
    }

    _processBarcode(code);
  }

  Future<void> _processBarcode(String barcode) async {
    try {
      final localStorage = context.read<LocalStorageService>();
      final apiService = context.read<ApiService>();
      final syncService = context.read<SyncService>();

      // First check local storage
      Document? document = await localStorage.getDocumentByBarcode(barcode);

      // If not found locally and online, try API
      if (document == null && _isOnline) {
        document = await apiService.getDocumentByBarcode(barcode);
        // If found on API, save to local storage
        if (document != null) {
          await localStorage.saveDocument(document);
        }
      }
      if (document?.storageLocationId != null) {
        // Try local storage first
        location = await localStorage.getStorageLocationById(document!.storageLocationId!);

        // If not found locally and online, fetch from API
        if (location == null && _isOnline) {
          location = await localStorage.getStorageLocationById(document!.storageLocationId!);
          if (location != null) {
            await localStorage.saveStorageLocation(location!);
          }
        }
      }
      if (!mounted) return;

      if (document != null) {
        showDialog(
          context: context,
          builder: (context) => ScanResultDialog(
            document: document!,
            isOnline: _isOnline,
            storageLocation: location,
            onClose: () {
              setState(() {
                _isScanning = true;
                _isProcessing = false;
              });
            },
            onAssignLocation: () async {
              Navigator.of(context).pop();
              await _showLocationAssignmentDialog(document!, syncService);
            },
          ),
        );
      } else {
        // Document not found, show option to generate new barcode
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Document Not Found'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_2_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _isOnline
                      ? 'This barcode is not associated with any document. Would you like to generate a new barcode?'
                      : 'This barcode is not found in local storage. Please connect to the internet to check the server or generate a new barcode.',
                  textAlign: TextAlign.center,
                ),
                if (!_isOnline) ...[
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.cloud_off,
                    size: 24,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You are currently offline',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isScanning = true;
                    _isProcessing = false;
                  });
                },
                child: const Text('Cancel'),
              ),
              if (_isOnline)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GenerateBarcodeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Generate Barcode'),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error processing barcode: $e'),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
    }
  }

  Future<void> _showLocationAssignmentDialog(Document document, SyncService syncService) async {
    try {
      final localStorage = context.read<LocalStorageService>();
      final apiService = context.read<ApiService>();
      List<StorageLocation> locations;

      if (_isOnline) {
        // Get locations from API and update local storage
        locations = await apiService.getAvailableLocations();
        for (final location in locations) {
          await localStorage.saveStorageLocation(location);
        }
      } else {
        // Get locations from local storage
        locations = await localStorage.getStorageLocations();
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Text('Assign Storage Location'),
              if (!_isOnline) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.cloud_off,
                  size: 20,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Offline',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storage_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                if (!_isOnline)
                  Container(
                    padding: const EdgeInsets.all(8),
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
                            'Changes will be synced when you are back online',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: location.hasAvailableSpace
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Theme.of(context).colorScheme.error.withOpacity(0.1),
                            child: Icon(
                              location.hasAvailableSpace
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color: location.hasAvailableSpace
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          title: Text(location.name),
                          subtitle: Text(
                            'Code: ${location.code}\n'
                            'Space: ${location.usedSpace}/${location.capacity}',
                          ),
                          trailing: location.hasAvailableSpace
                              ? const Icon(Icons.arrow_forward_ios, size: 16)
                              : null,
                          onTap: location.hasAvailableSpace
                              ? () async {
                                  try {
                                    final updatedDocument = document.copyWith(
                                      storageLocationId: location.id,
                                      storageLocationCode: location.code,
                                    );



                                    if (_isOnline) {
                                      // Update online
                                      await apiService.updateDocument(
                                        document.id!,
                                        updatedDocument,
                                      );
                                      await localStorage.saveDocument(updatedDocument);
                                    } else {
                                      // Save locally and queue for sync
                                      await localStorage.saveDocument(
                                        updatedDocument,
                                        syncStatus: 'pending',
                                      );
                                      await localStorage.addSyncLog(
                                        'document',
                                        document.id!,
                                        'update',
                                        updatedDocument.toJson(),
                                        await syncService.getDeviceId(),
                                      );
                                    }

                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _isOnline
                                                    ? 'Location assigned successfully'
                                                    : 'Location assigned (will sync when online)',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: _isOnline ? Colors.green : Colors.orange,
                                      ),
                                    );
                                    setState(() {
                                      _isScanning = true;
                                      _isProcessing = false;
                                    });
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.error_outline, color: Colors.white),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text('Failed to assign location: $e'),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isScanning = true;
                  _isProcessing = false;
                });
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error loading locations: $e'),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Scan Barcode'),
            if (!_isOnline) ...[
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
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          CustomPaint(
            painter: ScannerOverlayPainter(
              animation: _animation,
              isProcessing: _isProcessing,
            ),
            child: Container(),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isOnline
                        ? 'Position the barcode within the frame'
                        : 'Offline Mode - Changes will sync when online',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isOnline)
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GenerateBarcodeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate Barcode'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isProcessing;

  ScannerOverlayPainter({
    required this.animation,
    required this.isProcessing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    // Draw semi-transparent overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, scanArea.top),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, scanArea.top, scanArea.left, scanArea.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        scanArea.right,
        scanArea.top,
        size.width - scanArea.right,
        scanArea.height,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        scanArea.bottom,
        size.width,
        size.height - scanArea.bottom,
      ),
      paint,
    );

    // Draw scan area border
    final borderPaint = Paint()
      ..color = isProcessing ? Colors.red : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(scanArea, borderPaint);

    // Draw corner markers
    final markerLength = scanArea.width * 0.1;
    final markerPaint = Paint()
      ..color = isProcessing ? Colors.red : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw animated scanning line
    if (!isProcessing) {
      final scanLinePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final scanLineY = scanArea.top +
          (scanArea.height * animation.value);

      canvas.drawLine(
        Offset(scanArea.left, scanLineY),
        Offset(scanArea.right, scanLineY),
        scanLinePaint,
      );
    }

    // Top-left corner
    canvas.drawLine(
      scanArea.topLeft,
      scanArea.topLeft.translate(markerLength, 0),
      markerPaint,
    );
    canvas.drawLine(
      scanArea.topLeft,
      scanArea.topLeft.translate(0, markerLength),
      markerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      scanArea.topRight,
      scanArea.topRight.translate(-markerLength, 0),
      markerPaint,
    );
    canvas.drawLine(
      scanArea.topRight,
      scanArea.topRight.translate(0, markerLength),
      markerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      scanArea.bottomLeft,
      scanArea.bottomLeft.translate(markerLength, 0),
      markerPaint,
    );
    canvas.drawLine(
      scanArea.bottomLeft,
      scanArea.bottomLeft.translate(0, -markerLength),
      markerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      scanArea.bottomRight,
      scanArea.bottomRight.translate(-markerLength, 0),
      markerPaint,
    );
    canvas.drawLine(
      scanArea.bottomRight,
      scanArea.bottomRight.translate(0, -markerLength),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 