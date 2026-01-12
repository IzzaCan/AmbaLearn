import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../config/theme_config.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import 'exam_result_page.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeExam();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Initialize exam - load exam and camera
  Future<void> _initializeExam() async {
    // Load exam from API
    final provider = context.read<ExamProvider>();
    final success = await provider.loadExam(widget.courseUid);

    if (!success && mounted) {
      _showErrorAndExit('Failed to load exam. Please try again.');
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
        debugPrint('⚠️ No cameras available');
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
        debugPrint('✅ Camera initialized');
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
        title: Text('Error', style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit exam page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Submit exam
  Future<void> _submitExam() async {
    final provider = context.read<ExamProvider>();
    final theme = Theme.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Submit Exam?', style: theme.textTheme.titleLarge),
        content: Text(
          provider.isAllAnswered
              ? 'You have answered all questions. Submit your exam now?'
              : 'You have answered ${provider.answeredCount} of ${provider.totalQuestions} questions. '
                    'Unanswered questions will be marked as incorrect. Submit anyway?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit exam'),
          backgroundColor: context.errorColor,
        ),
      );
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
            title: Text('Exit Exam?', style: theme.textTheme.titleLarge),
            content: Text(
              'Are you sure you want to exit? Your progress will be lost.',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.errorColor,
                ),
                child: const Text('Exit'),
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
              provider.error ?? 'Failed to load exam',
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
              'Loading exam...',
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
                child: const Text('Go Back'),
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
      appBar: AppBar(
        title: Text(
          widget.courseTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // Camera preview indicator
          if (_isCameraInitialized)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.videocam_rounded,
                color: context.successColor,
                size: 24,
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
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(provider, theme),
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
                'Question ${provider.currentQuestionIndex + 1} of ${provider.totalQuestions}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Answered: ${provider.answeredCount}/${provider.totalQuestions}',
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
        'Question ${provider.currentQuestionIndex + 1}',
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
              label: const Text('Previous'),
            ),
          ),

          const SizedBox(width: 12),

          // Next/Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: provider.isSubmitting
                  ? null
                  : (isLastQuestion ? _submitExam : provider.nextQuestion),
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
                    ? 'Submitting...'
                    : (isLastQuestion ? 'Submit Exam' : 'Next'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
