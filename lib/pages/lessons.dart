import 'package:capstone_layout/pages/exam_permission_page.dart';
import 'package:capstone_layout/pages/homepage.dart';
import 'package:capstone_layout/widgets/chat_bubble.dart';
import 'package:capstone_layout/widgets/feedback_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../config/theme_config.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';
import '../l10n/app_localizations.dart';

/// LessonsPage - Modern redesign with theme support
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _startText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        final provider = context.read<CourseProvider>();
        provider.loadCourseDetail(args).then((success) {
          if (success) {
            provider.loadStepStatus(1);
          }
        });
      }
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    _startText = _messageController.text;
    await _speechToText.listen(onResult: _onSpeechResult, localeId: "id_ID");
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      String newText = result.recognizedWords;
      if (_startText.isNotEmpty) {
        _messageController.text = "$_startText $newText";
      } else {
        _messageController.text = newText;
      }
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onStartStep() async {
    final provider = context.read<CourseProvider>();
    final stepNumber = provider.activeStepNumber ?? 1;

    // 1. Kick off the loading process in the background
    // We don't await this immediately so the dialog can show up while it loads
    final startFuture = provider.startLessonStep(stepNumber);

    // 2. Check if this is the last step and show feedback dialog immediately
    if (provider.currentCourse != null &&
        provider.currentCourse!.steps.isNotEmpty &&
        provider.currentCourse!.steps.last.stepNumber == stepNumber) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false, // Cannot skip
          builder: (_) => WillPopScope(
            onWillPop: () async => false, // Prevent back button
            child: FeedbackDialog(courseUid: provider.currentCourse!.uid),
          ),
        );
      }
    }

    // 3. Await the start process to finish
    await startFuture;
  }

  Future<void> _onSelectStep(int stepNumber) async {
    final provider = context.read<CourseProvider>();
    Navigator.pop(context);
    await provider.loadStepStatus(stepNumber);

    // Check if this is the last step and show feedback dialog
    // REMOVED: Logic moved to _onStartStep as requested
  }

  void _onSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    _messageController.clear();
    context.read<CourseProvider>().sendChatMessage(message);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final course = provider.currentCourse;
        final isLoading = provider.isLoadingDetail || provider.isSendingMessage;
        final hasStarted = provider.isStepStarted;
        final chatMessages = provider.chatMessages;
        final activeStep = provider.activeStepNumber;

        // Show error snackbar
        if (provider.chatError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.chatError!),
                backgroundColor: context.errorColor,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    if (activeStep != null) {
                      provider.loadStepStatus(activeStep);
                    }
                  },
                ),
              ),
            );
            provider.clearError();
          });
        }

        if (chatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              course?.courseTitle ?? "Loading...",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: _buildDrawer(course, activeStep, theme),
          body: Column(
            children: [
              // Progress indicator
              if (provider.isSendingMessage && chatMessages.isEmpty)
                LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),

              Expanded(
                child: provider.isLoadingDetail
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Loading lesson...",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : hasStarted
                    ? _buildChatArea(
                        chatMessages,
                        provider.isSendingMessage,
                        theme,
                      )
                    : _buildNotStartedArea(
                        course,
                        activeStep,
                        isLoading,
                        theme,
                      ),
              ),
              _buildInputArea(hasStarted, provider.isSendingMessage, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(Course? course, int? activeStep, ThemeData theme) {
    return Drawer(
      backgroundColor: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  course?.courseTitle ?? "Loading...",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Back to Home
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: context.textSecondary,
                ),
              ),
              title: Text("Back to Home", style: theme.textTheme.titleSmall),
              onTap: () {
                context.read<CourseProvider>().clearCurrentCourse();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              "LESSONS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
          ),

          // Lesson List
          Expanded(
            child: course?.steps == null || course!.steps.isEmpty
                ? Center(
                    child: Text(
                      "No lessons available",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: course.steps.length,
                    itemBuilder: (context, index) {
                      final step = course.steps[index];
                      final isActive = step.stepNumber == activeStep;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.secondary.withOpacity(0.2)
                                  : context.dividerColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isActive
                                  ? Icon(
                                      Icons.play_circle_filled_rounded,
                                      size: 20,
                                      color: theme.colorScheme.secondary,
                                    )
                                  : Text(
                                      "${step.stepNumber}",
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: context.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                            ),
                          ),
                          title: Text(
                            step.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isActive
                                  ? theme.colorScheme.secondary
                                  : null,
                            ),
                          ),
                          dense: true,
                          onTap: () => _onSelectStep(step.stepNumber),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: isActive
                              ? theme.colorScheme.secondary.withOpacity(0.1)
                              : null,
                        ),
                      );
                    },
                  ),
          ),

          Divider(color: context.dividerColor),

          // Exam Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              "ASSESSMENT",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                "Final Exam",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: context.textSecondary,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamPermissionPage(
                      courseUid: course!.uid,
                      courseTitle: course.courseTitle,
                    ),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildNotStartedArea(
    Course? course,
    int? stepNumber,
    bool isLoading,
    ThemeData theme,
  ) {
    final currentStep = course?.steps.firstWhere(
      (s) => s.stepNumber == stepNumber,
      orElse: () => course.steps.first,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            Container(
              padding: const EdgeInsets.all(28),
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
                Icons.play_lesson_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            if (currentStep != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Step ${currentStep.stepNumber}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentStep.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),
            ],

            // Start Button
            SizedBox(
              width: 220,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _onStartStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: context.isDarkMode
                      ? AppColors.darkBackground
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                ),
                icon: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  isLoading ? "Starting..." : "Start Lesson",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              isLoading
                  ? "Please wait, initializing lesson..."
                  : "Select other lessons from the menu",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isLoading
                    ? theme.colorScheme.secondary
                    : context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(
    List<ChatMessage> messages,
    bool isSending,
    ThemeData theme,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: messages.length + (isSending && messages.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: ChatBubble(message: "Thinking...", isUser: false),
          );
        }

        final message = messages[index];
        return ChatBubble(message: message.content, isUser: message.isUser);
      },
    );
  }

  Widget _buildInputArea(bool hasStarted, bool isSending, ThemeData theme) {
    if (!hasStarted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: context.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                "Press 'Start Lesson' to begin",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: context.dividerColor),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !isSending,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeMessage,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: isSending ? null : (_) => _onSendMessage(),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Mic Button
            Container(
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.redAccent.withOpacity(0.2)
                    : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _speechEnabled ? _toggleListening : null,
                icon: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: _isListening
                      ? Colors.redAccent
                      : theme.colorScheme.primary,
                ),
                tooltip: AppLocalizations.of(context)!.voiceInput,
              ),
            ),
            const SizedBox(width: 8),
            // Send Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: isSending ? null : _onSendMessage,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                tooltip: AppLocalizations.of(context)!.sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
