import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import '../providers/exam_provider.dart';
import '../services/anti_cheat_service.dart';
import 'exam_page.dart';
import '../l10n/app_localizations.dart';

class ExamPermissionPage extends StatefulWidget {
  final String courseUid;
  final String courseTitle;

  const ExamPermissionPage({
    super.key,
    required this.courseUid,
    required this.courseTitle,
  });

  @override
  State<ExamPermissionPage> createState() => _ExamPermissionPageState();
}

class _ExamPermissionPageState extends State<ExamPermissionPage> with WidgetsBindingObserver {
  bool _isRequestingPermission = false;
  bool _hasPermission = false;
  
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final AntiCheatService _antiCheatService = AntiCheatService();
  
  // Calibration State
  String _statusMessage = ""; // Initialized in didChange
  Color _statusColor = Colors.orange;
  bool _isReady = false;
  
  // Frame Processing
  bool _isProcessingFrame = false;
  DateTime _lastFrameTime = DateTime.now();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statusMessage.isEmpty) {
        _statusMessage = AppLocalizations.of(context)!.waitingForConnection;
    }
  }

  // Stream Subscriptions
  StreamSubscription? _connSub;
  StreamSubscription? _statusSub;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_hasPermission) {
        _initializeCamera();
      }
    }
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (mounted) {
        setState(() => _hasPermission = true);
        context.read<ExamProvider>().setCameraPermission(true);
        _initializeCamera();
        _initializeAntiCheat();
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    if (_isRequestingPermission) return;
    setState(() => _isRequestingPermission = true);

    try {
      final status = await Permission.camera.request();
      if (!mounted) return;

      if (status.isGranted) {
        setState(() => _hasPermission = true);
        context.read<ExamProvider>().setCameraPermission(true);
        _initializeCamera();
        _initializeAntiCheat();
      } else if (status.isDenied) {
        _showPermissionDeniedDialog();
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      }
    } catch (e) {
      debugPrint("Error requesting permission: $e");
    } finally {
      if (mounted) {
        setState(() => _isRequestingPermission = false);
      }
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _cameraController?.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void _initializeAntiCheat() {
    _antiCheatService.init();
    
    // Force reconnect ensures backend recognizes fresh session
    // This fixes the "zombie connection" issue on re-entry
    if (_antiCheatService.isConnected) {
       _antiCheatService.disconnect();
       Future.delayed(const Duration(milliseconds: 500), () {
         if (mounted) _antiCheatService.connect();
       });
    } else {
       _antiCheatService.connect();
    }

    // Listen for connection changes
    _connSub = _antiCheatService.connectionChangeStream.listen((connected) {
      if (!mounted) return;
      _updateConnectionUI(connected);
    });

    // Check immediate state (if already connected from singleton)
    if (_antiCheatService.isConnected) {
      _updateConnectionUI(true);
    }

    _statusSub = _antiCheatService.statusStream.listen((status) {
      if (!mounted) return;
      
      final numFaces = status['num_faces'] as int? ?? 0;
      final headAlert = status['head_alert'] as bool? ?? false;
      final msg = status['status'] as String? ?? "Unknown";

      bool ready = false;
      String displayText = msg;
      Color color = Colors.orange;

      if (numFaces == 0) {
        displayText = AppLocalizations.of(context)!.faceNotDetectedStatus;
        color = Colors.red;
      } else if (numFaces > 1) {
        displayText = AppLocalizations.of(context)!.multipleFacesStatus;
        color = Colors.red;
      } else if (headAlert) {
         displayText = AppLocalizations.of(context)!.faceScreenStatus;
         color = Colors.orange;
      } else {
        displayText = AppLocalizations.of(context)!.readyForExam;
        color = Colors.green;
        ready = true;
      }

      setState(() {
        _statusMessage = displayText;
        _statusColor = color;
        _isReady = ready;
      });
    });
  }

  void _updateConnectionUI(bool connected) {
    setState(() {
      if (connected) {
        // If we were waiting for connection, update to waiting for face
        if (_statusMessage == AppLocalizations.of(context)!.waitingForConnection) {
          _statusMessage = AppLocalizations.of(context)!.waitingForFace;
        }
      } else {
        _statusMessage = AppLocalizations.of(context)!.disconnectedStart;
        _statusColor = Colors.red;
        _isReady = false;
      }
    });
  }

  void _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    if (_isProcessingFrame || now.difference(_lastFrameTime).inMilliseconds < 500) {
      return;
    }

    _isProcessingFrame = true;
    _lastFrameTime = now;

    try {
      img.Image? processedImage;
      if (image.format.group == ImageFormatGroup.yuv420) {
        // Handle YUV420 strided
        final int width = image.width;
        final int height = image.height;
        // uv strides unused for grayscale
        
        // Create grayscale image from Y plane (most efficient for face detection)
        // We manually copy considering bytesPerRow (stride)
        processedImage = img.Image(width: width, height: height, numChannels: 1);
        
        final yPlane = image.planes[0];
        final yStride = yPlane.bytesPerRow;
        final yBytes = yPlane.bytes;
        
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
             // Avoid out of bounds
             final index = y * yStride + x;
             if (index < yBytes.length) {
               processedImage.setPixelR(x, y, yBytes[index]);
             }
          }
        }
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
         processedImage = img.Image.fromBytes(
            width: image.width,
            height: image.height,
            bytes: image.planes[0].bytes.buffer,
            order: img.ChannelOrder.bgra,
        );
      }

      if (processedImage != null) {
        // Rotate 270 degrees (common for front camera portrait on Android)
        processedImage = img.copyRotate(processedImage, angle: -90);

        final resized = img.copyResize(processedImage, width: 320);
        final jpg = img.encodeJpg(resized, quality: 70);
        final base64String = base64Encode(jpg);
        _antiCheatService.sendFrame(base64String);
      }
    } catch (e) {
      debugPrint("Frame processing error: $e");
    } finally {
      if (mounted) _isProcessingFrame = false;
    }
  }

  void _startExam() {
    // Stop camera here so ExamPage can take over
    _cameraController?.stopImageStream();
    // Disposal will happen in dispose() when navigating, 
    // or we can explicitly dispose here if we want to be safe before pushReplacement.
    // However, ExamPage creates its own controller. 
    // Android camera hardware might validly support only 1 active open camera.
    // So we should dispose here or await logic.
    
    // We navigate to ExamPage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ExamPage(
          courseUid: widget.courseUid,
          courseTitle: widget.courseTitle,
        ),
      ),
    );
  }

  // Dialog helpers (kept from original)
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissionDenied),
        content: Text(AppLocalizations.of(context)!.cameraPermissionMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissionRequired),
        content: Text(AppLocalizations.of(context)!.enableCameraMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(AppLocalizations.of(context)!.settings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionRequestUI();
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.calibrationCheck)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AspectRatio(
                          aspectRatio: _cameraController!.value.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_cameraController!),
                                // Face overlay
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _statusColor.withOpacity(0.5),
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isReady ? _startExam : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isReady ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.startExam,
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequestUI() {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.examPermission)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.cameraAccessRequired, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: Text(AppLocalizations.of(context)!.grantAccess),
            )
          ],
        ),
      ),
    );
  }
}
