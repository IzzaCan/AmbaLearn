import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import 'package:translator_plus/translator_plus.dart';
import '../config/theme_config.dart';
import '../providers/language_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? time;
  final bool skipTranslation;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
    this.skipTranslation = false,
  });

  String? _getYoutubeVideoId(String message) {
    RegExp regExp = RegExp(
      r"(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})",
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(message);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final videoId = _getYoutubeVideoId(message);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: videoId != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.85),
                  ],
                )
              : null,
          color: isUser
              ? null
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isUser ? 0.15 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (videoId == null ||
                message.trim() != "https://youtu.be/$videoId" &&
                    message.trim() !=
                        "https://www.youtube.com/watch?v=$videoId")
              Padding(
                padding: videoId != null
                    ? const EdgeInsets.all(12)
                    : EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUser || skipTranslation)
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUser
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          height: 1.5,
                        ),
                      )
                    else
                      _TranslatedText(
                        text: message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          height: 1.5,
                        ),
                      ),
                    if (time != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        time!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : context.textSecondary,
                          fontSize: 10,
                        ),
                        textAlign: isUser ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ],
                ),
              ),

            if (videoId != null) _YoutubePlayerWidget(videoId: videoId),
          ],
        ),
      ),
    );
  }
}

class _TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _TranslatedText({required this.text, this.style});

  @override
  State<_TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<_TranslatedText> {
  final _translator = GoogleTranslator();
  String? _translatedText;
  String? _targetLang;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _translatedText = null;
      _translate();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLang = context.watch<LanguageProvider>().targetLanguage;

    if (_targetLang != newLang) {
      _targetLang = newLang;
      // Force reset when language changes manually
      _translatedText = null;
      _translate();
    } else if (_translatedText == null) {
      _translate();
    }
  }

  Future<void> _translate() async {
    if (_targetLang == null) return;

    // Slight delay to avoid rapid updates during scroll
    // await Future.delayed(Duration(milliseconds: 100));

    try {
      final translation = await _translator.translate(
        widget.text,
        to: _targetLang!,
      );

      if (mounted) {
        setState(() {
          _translatedText = translation.text;
        });
      }
    } catch (e) {
      debugPrint("Translation error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_translatedText ?? widget.text, style: widget.style);
  }
}

class _YoutubePlayerWidget extends StatefulWidget {
  final String videoId;

  const _YoutubePlayerWidget({required this.videoId});

  @override
  State<_YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<_YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
      ),
      onReady: () {
        _controller.addListener(() {});
      },
      bottomActions: [
        const CurrentPosition(),
        const SizedBox(width: 10),
        ProgressBar(isExpanded: true),
        const SizedBox(width: 10),
        const RemainingDuration(),
        const FullScreenButton(),
      ],
    );
  }
}
