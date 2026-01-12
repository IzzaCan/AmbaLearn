import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Camera Permission Required',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Camera access is required for exam monitoring. '
          'Please grant camera permission to continue.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Permission Permanently Denied',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Camera permission has been permanently denied. '
          'Please enable it in app settings to take the exam.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Error', style: theme.textTheme.titleLarge),
        content: Text(
          'An error occurred while requesting camera permission. '
          'Please try again.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Permission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(32, 32, 32, 32 + bottomPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.secondary.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                widget.courseTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Final Exam',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),

              const SizedBox(height: 48),

              // Permission explanation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Camera Access Required',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We need camera access to monitor exam integrity. '
                      'Your camera will be active during the exam.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  icon: _isRequestingPermission
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 24,
                        ),
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
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.textSecondary, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
