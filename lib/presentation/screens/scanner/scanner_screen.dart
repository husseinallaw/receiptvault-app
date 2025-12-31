import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../providers/scanner_provider.dart';
import 'widgets/camera_overlay.dart';
import 'widgets/scanner_controls.dart';

/// Camera availability provider
final cameraProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

/// Main scanner screen with camera preview
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await ref.read(cameraProvider.future);
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final scannerNotifier = ref.read(scannerProvider.notifier);
      scannerNotifier.startCapturing();

      final XFile photo = await _controller!.takePicture();
      final bytes = await photo.readAsBytes();

      await scannerNotifier.captureImage(bytes);
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final scannerNotifier = ref.read(scannerProvider.notifier);
        await scannerNotifier.captureImage(bytes);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  void _toggleFlash() async {
    if (_controller == null) return;

    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scannerState = ref.watch(scannerProvider);
    final camerasAsync = ref.watch(cameraProvider);

    // Listen for state changes to navigate
    ref.listen<ScannerState>(scannerProvider, (previous, next) {
      if (next.isReviewing && next.scannedReceipt != null) {
        context.push('/scanner/review');
      } else if (next.isSuccess) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.receiptSaved)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            ref.read(scannerProvider.notifier).reset();
            context.pop();
          },
        ),
        actions: [
          if (_isInitialized)
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: camerasAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.cameraError,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFromGallery,
                child: Text(l10n.pickFromGallery),
              ),
            ],
          ),
        ),
        data: (cameras) {
          if (cameras.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_photography,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCameraAvailable,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickFromGallery,
                    child: Text(l10n.pickFromGallery),
                  ),
                ],
              ),
            );
          }

          // Initialize camera if not done
          if (!_isInitialized) {
            _initializeCamera();
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview
              if (_controller != null && _controller!.value.isInitialized)
                CameraPreview(_controller!),

              // Overlay
              const CameraOverlay(),

              // Processing indicator
              if (scannerState.isProcessing)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: scannerState.processingProgress,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.processingReceipt,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              // Error message
              if (scannerState.hasError)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            scannerState.errorMessage ?? l10n.unknownError,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () =>
                              ref.read(scannerProvider.notifier).reset(),
                        ),
                      ],
                    ),
                  ),
                ),

              // Controls
              if (!scannerState.isProcessing && !scannerState.hasError)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ScannerControls(
                    onCapture: _captureImage,
                    onGallery: _pickFromGallery,
                    isCapturing: scannerState.isCapturing,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
