import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../../../../services/local_storage_service.dart';
import '../widgets/scan_result_dialog.dart';
import '../../../barcode/presentation/screens/generate_barcode_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    _processBarcode(code);
  }

  Future<void> _processBarcode(String barcode) async {
    try {
      final apiService = context.read<ApiService>();
      final isValid = await apiService.validateBarcode(barcode);

      if (!mounted) return;

      if (isValid) {
        showDialog(
          context: context,
          builder: (context) => ScanResultDialog(
            barcode: barcode,
            onClose: () {
              setState(() {
                _isScanning = true;
              });
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid barcode'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isScanning = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing barcode: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isScanning = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
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
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'Position the barcode within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
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
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(scanArea, borderPaint);

    // Draw corner markers
    final markerLength = scanArea.width * 0.1;
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 