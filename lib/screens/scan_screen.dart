import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/scan_history.dart';
import '../services/database_service.dart';
import '../utils/action_helper.dart';
import '../widgets/result_panel.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  bool _isCameraActive = true;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _initializeCamera();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller?.dispose();
        break;
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted && mounted) {
      setState(() {
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );
        _isCameraActive = true;
      });
    }
  }

  Future<void> _handleBarcodeDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    // Pause scanner temporarily
    await _controller?.stop();

    // Vibrate and beep
    await ActionHelper.vibrateIfEnabled();
    await ActionHelper.beepIfEnabled();

    // Auto-copy if enabled
    await ActionHelper.autoCopyIfEnabled(code);

    // Detect type
    final type = ScanHistory.detectType(code);

    // Save to history
    final scan = ScanHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: code,
      type: type,
      timestamp: DateTime.now(),
    );
    await DatabaseService.addScan(scan);

    // Check if should auto-open URL
    if (type == 'url' && await ActionHelper.shouldAutoOpenUrl()) {
      await ActionHelper.openUrl(code);
      // Resume scanner after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _controller?.start();
      }
    } else {
      // Show result panel
      if (mounted) {
        ResultPanel.show(context, code, type);
        // Resume scanner when bottom sheet is closed
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && _isCameraActive) {
          await _controller?.start();
        }
      }
    }
  }

  Future<void> _pickImageAndScan() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      // Analyze image for barcode
      final barcode = await _controller?.analyzeImage(image.path);
      
      if (barcode == null || barcode.barcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No code found in image')),
          );
        }
        return;
      }

      final code = barcode.barcodes.first.rawValue;
      if (code == null || code.isEmpty) return;

      // Same handling as live scan
      await ActionHelper.vibrateIfEnabled();
      await ActionHelper.beepIfEnabled();
      await ActionHelper.autoCopyIfEnabled(code);

      final type = ScanHistory.detectType(code);
      final scan = ScanHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: code,
        type: type,
        timestamp: DateTime.now(),
      );
      await DatabaseService.addScan(scan);

      if (mounted) {
        ResultPanel.show(context, code, type);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning image: $e')),
        );
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller?.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_controller != null)
            MobileScanner(
              controller: _controller,
              onDetect: _handleBarcodeDetect,
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Viewfinder overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),

          // Controls at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flashlight
                  _ControlButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    label: 'Flash',
                    onPressed: _toggleFlash,
                  ),

                  // Upload Image
                  _ControlButton(
                    icon: Icons.image,
                    label: 'Gallery',
                    onPressed: _pickImageAndScan,
                  ),

                  // Switch Camera
                  _ControlButton(
                    icon: Icons.cameraswitch,
                    label: 'Switch',
                    onPressed: () => _controller?.switchCamera(),
                  ),
                ],
              ),
            ),
          ),

          // Title at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: const Text(
              'Scan QR Code or Barcode',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    // Draw dark overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)))
          ..close(),
      ),
      paint,
    );

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final bracketLength = 30.0;
    
    // Top-left
    canvas.drawLine(scanArea.topLeft, scanArea.topLeft + Offset(bracketLength, 0), bracketPaint);
    canvas.drawLine(scanArea.topLeft, scanArea.topLeft + Offset(0, bracketLength), bracketPaint);
    
    // Top-right
    canvas.drawLine(scanArea.topRight, scanArea.topRight + Offset(-bracketLength, 0), bracketPaint);
    canvas.drawLine(scanArea.topRight, scanArea.topRight + Offset(0, bracketLength), bracketPaint);
    
    // Bottom-left
    canvas.drawLine(scanArea.bottomLeft, scanArea.bottomLeft + Offset(bracketLength, 0), bracketPaint);
    canvas.drawLine(scanArea.bottomLeft, scanArea.bottomLeft + Offset(0, -bracketLength), bracketPaint);
    
    // Bottom-right
    canvas.drawLine(scanArea.bottomRight, scanArea.bottomRight + Offset(-bracketLength, 0), bracketPaint);
    canvas.drawLine(scanArea.bottomRight, scanArea.bottomRight + Offset(0, -bracketLength), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
