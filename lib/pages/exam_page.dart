import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../config/theme_config.dart';
import '../providers/exam_provider.dart';
import 'dart:convert';
import 'package:image/image.dart' as img; // For image conversion
import '../services/anti_cheat_service.dart';
import '../models/exam_model.dart';
import 'exam_result_page.dart';
import '../l10n/app_localizations.dart';

/// ExamPage - Main exam interface with camera monitoring
/// Follows the pattern from web implementation
class ExamPage extends StatefulWidget {
  final String courseUid;
  final String courseTitle;

  const ExamPage({
    super.key,
    required this.courseUid,
    required this.courseTitle,
  });

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final AntiCheatService _antiCheatService = AntiCheatService();
  bool _isProcessingFrame = false;
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();

  // Violation State
  bool _showWarning = false;
  String _warningMessage = '';
  int _violationCount = 0;
  int _maxViolations = 3;
  String _liveStatus = ""; // Initialized in initState
  Color _liveStatusColor = Colors.grey;

  // Stream Subscriptions
  StreamSubscription? _statusSub;
  StreamSubscription? _alertSub;
  StreamSubscription? _autoSubmitSub;

  void initState() {
    super.initState();
    // Defer initialization of _liveStatus until we have context, or handle in build
    // But since it's a string, we can set a default empty or localized in didChangeDependencies
    _initializeExam();
    _initializeAntiCheat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_liveStatus.isEmpty) {
        _liveStatus = AppLocalizations.of(context)!.initializing;
    }
  }

  void _initializeAntiCheat() {
    // Singleton instance automatically retrieved
    _antiCheatService.init(); // Checks internal flag
    _antiCheatService.connect(); // Checks connected status
    
    _alertSub = _antiCheatService.cheatingAlertStream.listen((data) {
      if (!mounted) return;
      final detail = data['detail'];
      final count = data['count'];
      final max = data['max'];
      
      setState(() {
        _showWarning = true;
        _warningMessage = detail;
        _violationCount = count;
        _maxViolations = max;
      });

      // Hide warning after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showWarning = false);
        }
      });
    });

    _autoSubmitSub = _antiCheatService.autoSubmitStream.listen((detail) {
      if (!mounted) return;
      _showErrorDialog('⛔ VIOLATION LIMIT EXCEEDED.\nYour exam is being automatically submitted.');
      _submitExam(autoSubmit: true);
    });

    _statusSub = _antiCheatService.statusStream.listen((status) {
       if (!mounted) return;
       final msg = status['status'] as String? ?? "Normal";
       final numFaces = status['num_faces'] as int? ?? 0;
       
       String display = AppLocalizations.of(context)!.monitoringActive;
       Color color = Colors.green;
       
       if (numFaces == 0) {
         display = AppLocalizations.of(context)!.faceNotDetected;
         color = Colors.orange;
       } else if (msg != "Normal") {
         display = msg; // Messages from server might essentially be 'Multiple Faces', etc. difficult to localize without mapping
         color = Colors.red;
       }
       
       setState(() {
         _liveStatus = display;
         _liveStatusColor = color;
       });
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exam Terminated', style: TextStyle(color: Colors.red)), // This seems critical, maybe keep English or localize if added keys
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    
    _statusSub?.cancel();
    _alertSub?.cancel();
    _autoSubmitSub?.cancel();
    super.dispose();
  }

  /// Initialize exam - load exam and camera
  Future<void> _initializeExam() async {
    // Load exam from API
    final provider = context.read<ExamProvider>();
    final success = await provider.loadExam(widget.courseUid);

    if (!success && mounted) {
      _showErrorAndExit(AppLocalizations.of(context)!.failedToLoadExamRetry);
      return;
    }

    // Initialize camera
    await _initializeCamera();
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint(AppLocalizations.of(context)!.noCameras);
        return;
      }

      // Use front camera for monitoring
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        debugPrint(AppLocalizations.of(context)!.cameraInitialized);
        _cameraController?.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      // Continue without camera - anti-cheat is future feature
    }
  }

  /// Show error and exit
  void _showErrorAndExit(String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.error, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit exam page
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  /// Submit exam
  Future<void> _submitExam({bool autoSubmit = false}) async {
    final provider = context.read<ExamProvider>();
    final theme = Theme.of(context);

    if (!autoSubmit) {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.of(context)!.submitExamQuestion, style: theme.textTheme.titleLarge),
          content: Text(
            provider.isAllAnswered
                ? AppLocalizations.of(context)!.submitExamConfirmAll
                : AppLocalizations.of(context)!.submitExamConfirmPartial(provider.answeredCount, provider.totalQuestions),
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.errorColor,
              ),
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    // Submit exam
    final success = await provider.submitExam();

    if (!mounted) return;

    if (success) {
      // Navigate to result page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExamResultPage(courseTitle: widget.courseTitle),
        ),
      );
    } else {
      if (!autoSubmit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? AppLocalizations.of(context)!.failedToSubmit),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during exam
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(AppLocalizations.of(context)!.exitExam, style: theme.textTheme.titleLarge),
            content: Text(
              AppLocalizations.of(context)!.exitExamConfirm,
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context)!.stay),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.errorColor,
                ),
                child: Text(AppLocalizations.of(context)!.exit),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Consumer<ExamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingExam) {
            return _buildLoadingScreen(theme);
          }

          if (provider.currentExam == null) {
            return _buildErrorScreen(
              provider.error ?? AppLocalizations.of(context)!.failedToLoadExam,
              theme,
            );
          }

          return _buildExamScreen(provider, theme);
        },
      ),
    );
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.loadingExam,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error, ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: context.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamScreen(ExamProvider provider, ThemeData theme) {
    final exam = provider.currentExam!;
    final currentQuestion = exam.questions[provider.currentQuestionIndex];

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(
                widget.courseTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                // Camera preview indicator
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        _violationCount > 0 ? AppLocalizations.of(context)!.violationStatus(_violationCount, _maxViolations) : '',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

              ],
            ),
            body: Column(
              children: [
                // Progress bar
                _buildProgressBar(provider, theme),
      
                // Question area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionNumber(provider, theme),
                        const SizedBox(height: 16),
                        _buildQuestionText(currentQuestion, theme),
                        const SizedBox(height: 24),
                        _buildOptions(currentQuestion, provider, theme),
                        const SizedBox(height: 150), // Padding for PIP Camera
                      ],
                    ),
                  ),
                ),
      
                // Navigation buttons
                _buildNavigationButtons(provider, theme),
              ],
            ),
          ),
          
          // WARNING OVERLAY
          if (_showWarning)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFeb3349), Color(0xFFf45c43)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.cheatingDetected,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.keepEyesOnScreen(_warningMessage),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // PIP CAMERA
          if (_isCameraInitialized && _cameraController != null)
            Positioned(
              bottom: 100,
              right: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 133,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        CameraPreview(_cameraController!),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: _liveStatusColor.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _liveStatus,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 10,
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ExamProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.questionTitle(provider.currentQuestionIndex + 1, provider.totalQuestions),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.answeredStatus(provider.answeredCount, provider.totalQuestions),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: provider.progressPercentage,
            backgroundColor: context.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNumber(ExamProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        AppLocalizations.of(context)!.questionHeader(provider.currentQuestionIndex + 1),
        style: TextStyle(
          color: context.isDarkMode ? AppColors.darkBackground : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuestionText(ExamQuestion question, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Text(
        question.question,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildOptions(
    ExamQuestion question,
    ExamProvider provider,
    ThemeData theme,
  ) {
    final questionIndex = provider.currentQuestionIndex;
    final selectedAnswer = provider.getAnswer(questionIndex);

    return Column(
      children: question.sortedOptionKeys.map((optionKey) {
        final isSelected = selectedAnswer == optionKey;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => provider.setAnswer(questionIndex, optionKey),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : context.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : context.textSecondary,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        optionKey,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.options[optionKey] ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.white : context.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(ExamProvider provider, ThemeData theme) {
    final isFirstQuestion = provider.currentQuestionIndex == 0;
    final isLastQuestion =
        provider.currentQuestionIndex == provider.totalQuestions - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFirstQuestion ? null : provider.previousQuestion,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: Text(AppLocalizations.of(context)!.previous),
            ),
          ),

          const SizedBox(width: 12),

          // Next/Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: provider.isSubmitting
                  ? null
                  : (isLastQuestion ? () => _submitExam() : provider.nextQuestion),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: provider.isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      isLastQuestion
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
              label: Text(
                provider.isSubmitting
                    ? AppLocalizations.of(context)!.submitting
                    : (isLastQuestion ? AppLocalizations.of(context)!.submitExam : AppLocalizations.of(context)!.next),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _processCameraImage(CameraImage image) async {
    // Throttle: Process 1 frame every 500ms
    final now = DateTime.now();
    if (_isProcessingFrame || now.difference(_lastFrameTime).inMilliseconds < 500) {
      return;
    }

    _isProcessingFrame = true;
    _lastFrameTime = now;

    try {
      img.Image? processedImage;
      
      if (image.format.group == ImageFormatGroup.yuv420) {
        // Handle YUV420 strided (Robust implementation)
        final int width = image.width;
        final int height = image.height;
        
        processedImage = img.Image(width: width, height: height, numChannels: 1);
        
        final yPlane = image.planes[0];
        final yStride = yPlane.bytesPerRow;
        final yBytes = yPlane.bytes;
        
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
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

        // Resize to reduce bandwidth
        final resized = img.copyResize(processedImage, width: 320);
        final jpg = img.encodeJpg(resized, quality: 70);
        final base64String = base64Encode(jpg);
        
        _antiCheatService.sendFrame(base64String);
      }
    } catch (e) {
      debugPrint("Error processing frame: $e");
    } finally {
      if (mounted) {
        _isProcessingFrame = false;
      }
    }
  }


}
