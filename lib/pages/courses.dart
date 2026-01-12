import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _showAddCourseDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<CourseProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              backgroundColor: context.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text("Generate Course", style: theme.textTheme.headlineSmall),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Enter a topic and AI will generate a personalized course for you.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _topicController,
                    enabled: !provider.isGenerating,
                    decoration: InputDecoration(
                      labelText: "Topic",
                      hintText: "e.g. Python Basics, Machine Learning",
                      prefixIcon: Icon(
                        Icons.topic_rounded,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  if (provider.isGenerating) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          "Generating course...",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () {
                          _topicController.clear();
                          Navigator.pop(dialogContext);
                        },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: provider.isGenerating
                          ? context.textSecondary.withOpacity(0.5)
                          : context.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text("Generate"),
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                          if (_topicController.text.trim().isNotEmpty) {
                            final success = await provider.generateCourse(
                              _topicController.text.trim(),
                            );
                            if (success && dialogContext.mounted) {
                              _topicController.clear();
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Course generated successfully!",
                                  ),
                                  backgroundColor: context.successColor,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourseDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text("New Course"),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          // Show error snackbar
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: context.errorColor,
                ),
              );
              provider.clearError();
            });
          }

          // Loading state
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    "Loading courses...",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.courses.isEmpty) {
            return _buildEmptyState(theme);
          }

          // Course grid
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: GridView.builder(
              itemCount: provider.courses.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final course = provider.courses[index];
                return _buildCourseCard(course, theme);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text("No courses yet", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              "Create your first AI-generated course\nto start learning",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddCourseDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text("Create Course"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course, ThemeData theme) {
    // Difficulty colors
    Color difficultyColor;
    IconData difficultyIcon;
    switch (course.difficulty.toLowerCase()) {
      case 'beginner':
        difficultyColor = AppColors.lightSuccess;
        difficultyIcon = Icons.signal_cellular_alt_1_bar_rounded;
        break;
      case 'intermediate':
        difficultyColor = Colors.orange;
        difficultyIcon = Icons.signal_cellular_alt_2_bar_rounded;
        break;
      case 'advanced':
        difficultyColor = context.errorColor;
        difficultyIcon = Icons.signal_cellular_alt_rounded;
        break;
      default:
        difficultyColor = theme.colorScheme.primary;
        difficultyIcon = Icons.signal_cellular_alt_rounded;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/lessons', arguments: course.uid);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with gradient
            Expanded(
              flex: 3,
              child: Container(
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
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.school_rounded,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Center icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Difficulty badge
                    if (course.difficulty.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              difficultyIcon,
                              size: 12,
                              color: difficultyColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                course.difficulty,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: difficultyColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
