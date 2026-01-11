import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'exam_page.dart';

/// ExamPermissionPage - Request camera permission before starting exam
/// This follows the web pattern of permission check before exam
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

class _ExamPermissionPageState extends State<ExamPermissionPage> {
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  /// Check if camera permission is already granted
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (mounted) {
        context.read<ExamProvider>().setCameraPermission(true);
      }
    }
  }

  /// Request camera permission
  Future<void> _requestCameraPermission() async {
    if (_isRequestingPermission) return;

    setState(() => _isRequestingPermission = true);

    try {
      final status = await Permission.camera.request();

      if (!mounted) return;

      if (status.isGranted) {
        // Permission granted - set state and navigate to exam
        context.read<ExamProvider>().setCameraPermission(true);
        _navigateToExam();
      } else if (status.isDenied) {
        _showPermissionDeniedDialog();
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      }
    } catch (e) {
      debugPrint("Error requesting permission: $e");
      if (mounted) {
        _showErrorDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingPermission = false);
      }
    }
  }

  /// Navigate to exam page
  void _navigateToExam() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ExamPage(
          courseUid: widget.courseUid,
          courseTitle: widget.courseTitle,
        ),
      ),
    );
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera access is required for exam monitoring. '
          'Please grant camera permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestCameraPermission();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Show open settings dialog (for permanently denied)
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Permanently Denied'),
        content: const Text(
          'Camera permission has been permanently denied. '
          'Please enable it in app settings to take the exam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text(
          'An error occurred while requesting camera permission. '
          'Please try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D0005),
        title: const Text(
          'Exam Permission',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D0005).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam,
                  size: 80,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                widget.courseTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Final Exam',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),

              const SizedBox(height: 48),

              // Permission explanation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D0005).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC85050).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orangeAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Camera Access Required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We need camera access to monitor exam integrity. '
                      'Your camera will be active during the exam.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Request Permission Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isRequestingPermission
                      ? null
                      : _requestCameraPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC85050),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF4D0005),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  icon: _isRequestingPermission
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 24),
                  label: Text(
                    _isRequestingPermission
                        ? 'Requesting Permission...'
                        : 'Grant Camera Access',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: _isRequestingPermission
                    ? null
                    : () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
