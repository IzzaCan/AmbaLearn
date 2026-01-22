import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../config/theme_config.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
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
                    MarkdownBody(
                      data: message,
                      selectable: true,
                      onTapLink: (text, href, title) async {
                        if (href != null) {
                          final uri = Uri.parse(href);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: theme.textTheme.bodyMedium!.copyWith(
                          color: isUser
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                          height: 1.5,
                        ),
                        strong: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUser
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                        a: theme.textTheme.bodyMedium!.copyWith(
                          color: isUser ? Colors.white : Colors.blue,
                        ),
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
      topActions: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _controller.metadata.title,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20.0),
          onPressed: () async {
            final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          tooltip: 'Open in YouTube',
        ),
      ],
      bottomActions: [
        const CurrentPosition(),
        const SizedBox(width: 10),
        ProgressBar(isExpanded: true),
        const SizedBox(width: 10),
        const RemainingDuration(),
        IconButton(
          icon: const Icon(Icons.fullscreen, color: Colors.white),
          onPressed: () {
            final currentPosition = _controller.value.position;
            _controller.pause();
            Navigator.of(context, rootNavigator: true)
                .push(
                  MaterialPageRoute(
                    builder: (context) => _FullScreenVideoPage(
                      videoId: widget.videoId,
                      startAt: currentPosition,
                    ),
                  ),
                )
                .then((newPosition) {
                  if (newPosition != null && newPosition is Duration) {
                    _controller.seekTo(newPosition);
                  }
                  _controller.play();
                });
          },
        ),
      ],
    );
  }
}

class _FullScreenVideoPage extends StatefulWidget {
  final String videoId;
  final Duration startAt;

  const _FullScreenVideoPage({required this.videoId, required this.startAt});

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: 0, // We will seek in onReady
      ),
    );

    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Force back to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          onReady: () {
            _controller.seekTo(widget.startAt);
          },
          topActions: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.open_in_new,
                color: Colors.white,
                size: 20.0,
              ),
              onPressed: () async {
                final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              tooltip: 'Open in YouTube',
            ),
          ],
          bottomActions: [
            const CurrentPosition(),
            const SizedBox(width: 10),
            ProgressBar(isExpanded: true),
            const SizedBox(width: 10),
            const RemainingDuration(),
            IconButton(
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, _controller.value.position);
              },
            ),
          ],
        ),
      ),
    );
  }
}
