import 'package:capstone_layout/pages/exampage.dart';
import 'package:capstone_layout/pages/homepage.dart';
import 'package:capstone_layout/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';

/// LessonsPage - Following web implementation pattern
/// Web pattern: GET first to check status, then render appropriate UI
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        final provider = context.read<CourseProvider>();
        // Load course detail first
        provider.loadCourseDetail(args).then((success) {
          if (success) {
            // Then load first step status (like web redirects to first lesson)
            provider.loadStepStatus(1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Start button handler - Like web's start_lesson form POST
  Future<void> _onStartStep() async {
    final provider = context.read<CourseProvider>();
    
    // Get current active step number
    final stepNumber = provider.activeStepNumber ?? 1;
    
    debugPrint("🎯 User clicked Start for step $stepNumber");
    
    // Call startLessonStep which will POST then reload
    await provider.startLessonStep(stepNumber);
  }

  /// Select step from drawer - Like web's navigation
  Future<void> _onSelectStep(int stepNumber) async {
    final provider = context.read<CourseProvider>();
    
    // Close drawer
    Navigator.pop(context);
    
    debugPrint("🎯 User selected step $stepNumber from drawer");
    
    // Load status for selected step (GET request)
    await provider.loadStepStatus(stepNumber);
  }

  /// Send message
  void _onSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    _messageController.clear();
    context.read<CourseProvider>().sendChatMessage(message);
  }

  /// Auto-scroll to bottom
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
                backgroundColor: Colors.red,
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

        // Auto-scroll when messages change
        if (chatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF252525),
          appBar: AppBar(
            backgroundColor: const Color(0xFF4D0005),
            title: Text(
              course?.courseTitle ?? "Loading...",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: _buildDrawer(course, activeStep),
          body: Column(
            children: [
              // Show loading indicator at top when fetching data
              if (provider.isSendingMessage && chatMessages.isEmpty)
                const LinearProgressIndicator(
                  backgroundColor: Color(0xFF4D0005),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              
              Expanded(
                child: provider.isLoadingDetail
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : hasStarted
                    ? _buildChatArea(chatMessages, provider.isSendingMessage)
                    : _buildNotStartedArea(course, activeStep, isLoading),
              ),
              _buildInputArea(hasStarted, provider.isSendingMessage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(Course? course, int? activeStep) {
    return Drawer(
      backgroundColor: const Color(0xFF252525),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4D0005)),
            child: Center(
              child: Text(
                "AmbaLearn Lessons",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.white),
            title: const Text(
              "Back to Home",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              context.read<CourseProvider>().clearCurrentCourse();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text(
              "Lessons",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: course?.steps == null || course!.steps.isEmpty
                ? const Center(
                    child: Text(
                      "No lessons available",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: course.steps.length,
                    itemBuilder: (context, index) {
                      final step = course.steps[index];
                      final isActive = step.stepNumber == activeStep;
                      return ListTile(
                        leading: Icon(
                          isActive
                              ? Icons.play_circle_filled
                              : Icons.menu_book_outlined,
                          color: isActive ? Colors.orangeAccent : Colors.white,
                        ),
                        title: Text(
                          "Step ${step.stepNumber}: ${step.title}",
                          style: TextStyle(
                            color: isActive
                                ? Colors.orangeAccent
                                : Colors.white,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () => _onSelectStep(step.stepNumber),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 5, bottom: 5),
            child: Text(
              "Exam",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined, color: Colors.white),
            title: const Text(
              "Final Exam",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExamPage()),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Not started view - Like web's lesson_not_started.html
  Widget _buildNotStartedArea(Course? course, int? stepNumber, bool isLoading) {
    // Find the current step details
    final currentStep = course?.steps.firstWhere(
      (s) => s.stepNumber == stepNumber,
      orElse: () => course.steps.first,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.white24),
            const SizedBox(height: 24),
            
            if (currentStep != null) ...[
              Text(
                "Step ${currentStep.stepNumber}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentStep.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
            ],

            // Start Button - Like web's form action
            SizedBox(
              width: 220,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _onStartStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC85050),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF4D0005),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 28),
                label: Text(
                  isLoading ? "Starting Lesson..." : "Start Lesson",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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
              style: TextStyle(
                fontSize: 13,
                color: isLoading ? Colors.orangeAccent : Colors.white38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chat area - Like web's lesson_chat.html
  Widget _buildChatArea(List<ChatMessage> messages, bool isSending) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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

  Widget _buildInputArea(bool hasStarted, bool isSending) {
    if (!hasStarted) {
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
        child: const Center(
          child: Text(
            "Press 'Start Lesson' to begin this step",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 16, left: 12, right: 12),
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
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isSending,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: isSending ? null : (_) => _onSendMessage(),
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic, color: Color(0xFF870005)),
              tooltip: "Voice input (coming soon)",
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: IconButton(
              onPressed: isSending ? null : _onSendMessage,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF870005)),
                      ),
                    )
                  : const Icon(Icons.send, color: Color(0xFF870005)),
              tooltip: "Send message",
            ),
          ),
        ],
      ),
    );
  }
}