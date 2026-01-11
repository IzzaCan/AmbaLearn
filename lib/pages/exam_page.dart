import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
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

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: Text(
          provider.isAllAnswered
              ? 'You have answered all questions. Submit your exam now?'
              : 'You have answered ${provider.answeredCount} of ${provider.totalQuestions} questions. '
                'Unanswered questions will be marked as incorrect. Submit anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC85050),
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
          builder: (context) => ExamResultPage(
            courseTitle: widget.courseTitle,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit exam'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during exam
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Exam?'),
            content: const Text(
              'Are you sure you want to exit? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
            return _buildLoadingScreen();
          }

          if (provider.currentExam == null) {
            return _buildErrorScreen(provider.error ?? 'Failed to load exam');
          }

          return _buildExamScreen(provider);
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Loading exam...',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildExamScreen(ExamProvider provider) {
    final exam = provider.currentExam!;
    final currentQuestion = exam.questions[provider.currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D0005),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // Camera preview indicator
          if (_isCameraInitialized)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.videocam,
                color: Colors.green[300],
                size: 24,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(provider),

          // Question area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionNumber(provider),
                  const SizedBox(height: 16),
                  _buildQuestionText(currentQuestion),
                  const SizedBox(height: 24),
                  _buildOptions(currentQuestion, provider),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(provider),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ExamProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF4D0005).withOpacity(0.3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${provider.currentQuestionIndex + 1} of ${provider.totalQuestions}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'Answered: ${provider.answeredCount}/${provider.totalQuestions}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: provider.progressPercentage,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC85050)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNumber(ExamProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC85050),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Question ${provider.currentQuestionIndex + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuestionText(ExamQuestion question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4D0005).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        question.question,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildOptions(ExamQuestion question, ExamProvider provider) {
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
                    ? const Color(0xFFC85050)
                    : const Color(0xFF4D0005).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFC85050) : Colors.white12,
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
                            ? const Color(0xFFC85050)
                            : Colors.white54,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        optionKey,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFC85050)
                              : Colors.white,
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
                        color: isSelected ? Colors.white : Colors.white,
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

  Widget _buildNavigationButtons(ExamProvider provider) {
    final isFirstQuestion = provider.currentQuestionIndex == 0;
    final isLastQuestion =
        provider.currentQuestionIndex == provider.totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4D0005),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.arrow_back, size: 20),
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
                backgroundColor: const Color(0xFFC85050),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: provider.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
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