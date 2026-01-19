import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import '../l10n/app_localizations.dart';

/// ExamResultPage - Display exam results
/// Matches the web version's score.html pattern
class ExamResultPage extends StatelessWidget {
  final String courseTitle;

  const ExamResultPage({super.key, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear exam state when leaving
        context.read<ExamProvider>().resetExamState();
        return true;
      },
      child: Consumer<ExamProvider>(
        builder: (context, provider, child) {
          final result = provider.examResult;

          if (result == null) {
            return _buildErrorScreen(context);
          }

          final theme = Theme.of(context);
          final bottomPadding = MediaQuery.of(context).padding.bottom;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.examResults,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
              child: Column(
                children: [
                  _buildScoreCard(result, theme, context),
                  const SizedBox(height: 32),
                  _buildGradeSection(result, theme, context),
                  const SizedBox(height: 32),
                  _buildStatistics(result, theme, context),
                  const SizedBox(height: 32),
                  _buildDetailedResults(result, theme, context),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: context.errorColor,
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.noExamResults, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    ExamResult result,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: result.isPassing
              ? [context.successColor, context.successColor.withOpacity(0.8)]
              : [context.errorColor, context.errorColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (result.isPassing ? context.successColor : context.errorColor)
                    .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            courseTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.yourScore,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.score}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.isPassing ? AppLocalizations.of(context)!.passed : AppLocalizations.of(context)!.failed,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSection(
    ExamResult result,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGradeItem(
            AppLocalizations.of(context)!.grade,
            result.grade,
            Icons.star_rounded,
            theme,
            context,
          ),
          Container(width: 1, height: 40, color: context.dividerColor),
          _buildGradeItem(
            AppLocalizations.of(context)!.correct,
            '${result.correctCount}/${result.totalQuestions}',
            Icons.check_circle_rounded,
            theme,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(
    ExamResult result,
    ThemeData theme,
    BuildContext context,
  ) {
    final incorrectCount = result.totalQuestions - result.correctCount;
    final accuracy = result.totalQuestions > 0
        ? (result.correctCount / result.totalQuestions * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.statistics,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.dividerColor),
          ),
          child: Column(
            children: [
              _buildStatRow(
                AppLocalizations.of(context)!.totalQuestions,
                result.totalQuestions.toString(),
                Icons.quiz_rounded,
                theme,
                context,
              ),
              Divider(color: context.dividerColor, height: 24),
              _buildStatRow(
                AppLocalizations.of(context)!.correctAnswers,
                result.correctCount.toString(),
                Icons.check_circle_outline_rounded,
                theme,
                context,
                color: context.successColor,
              ),
              Divider(color: context.dividerColor, height: 24),
              _buildStatRow(
                AppLocalizations.of(context)!.incorrectAnswers,
                incorrectCount.toString(),
                Icons.cancel_outlined,
                theme,
                context,
                color: context.errorColor,
              ),
              Divider(color: context.dividerColor, height: 24),
              _buildStatRow(
                AppLocalizations.of(context)!.accuracy,
                '${accuracy.toStringAsFixed(1)}%',
                Icons.percent_rounded,
                theme,
                context,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    BuildContext context, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color ?? context.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color ?? context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedResults(
    ExamResult result,
    ThemeData theme,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.questionDetails,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...result.details.asMap().entries.map((entry) {
          final index = entry.key;
          final detail = entry.value;
          return _buildQuestionDetail(index + 1, detail, theme, context);
        }),
      ],
    );
  }

  Widget _buildQuestionDetail(
    int questionNumber,
    QuestionResult detail,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: detail.isCorrect
            ? context.successColor.withOpacity(0.1)
            : context.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: detail.isCorrect ? context.successColor : context.errorColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: detail.isCorrect
                  ? context.successColor
                  : context.errorColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$questionNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      detail.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: detail.isCorrect
                          ? context.successColor
                          : context.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      detail.isCorrect ? AppLocalizations.of(context)!.correctStatus : AppLocalizations.of(context)!.incorrectStatus,
                      style: TextStyle(
                        color: detail.isCorrect
                            ? context.successColor
                            : context.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (!detail.isCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.yourAnswer(detail.userAnswer ?? AppLocalizations.of(context)!.notAnswered),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.correctAnswer(detail.correctAnswer),
                    style: TextStyle(
                      color: context.successColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<ExamProvider>().resetExamState();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.home_rounded),
            label: Text(
              AppLocalizations.of(context)!.backToHome,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<ExamProvider>().resetExamState();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(AppLocalizations.of(context)!.backToCourse, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
