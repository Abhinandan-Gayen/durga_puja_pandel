import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PandalMediaSlider extends StatelessWidget {
  const PandalMediaSlider({
    super.key,
    required this.images,
    required this.videos,
    this.height = 240,
  });

  final List<String> images;
  final List<String> videos;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mediaUrls = [...images, ...videos];
    if (mediaUrls.isEmpty) {
      return Container(
        height: height,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Center(child: Icon(Icons.temple_hindu, size: 56)),
      );
    }

    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          final url = mediaUrls[index];
          final isVideo = index >= images.length;
          if (isVideo) {
            return _VideoPreview(url: url);
          }
          return CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, _, _) => const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({
    required this.url,
    this.autoPlay = false,
    this.fit = BoxFit.cover,
    this.controlsEnabled = true,
  });

  final String url;
  final bool autoPlay;
  final BoxFit fit;
  final bool controlsEnabled;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.initialize().then((_) async {
      if (widget.autoPlay) {
        await _controller.play();
      }
      if (!mounted) {
        return;
      }
      setState(() => _isReady = true);
      if (widget.controlsEnabled) _hideControlsAfterDelay();
    });
  }

  void _hideControlsAfterDelay() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _handleVideoTap() {
    if (!_showControls) {
      setState(() => _showControls = true);
      _hideControlsAfterDelay();
      return;
    }

    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
      _showControls = true;
    });
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const ColoredBox(
        color: Colors.black87,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: widget.fit,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        if (widget.controlsEnabled) Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleVideoTap,
            child: AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PandalVideoPlayer extends StatelessWidget {
  const PandalVideoPlayer({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.fit = BoxFit.contain,
    this.controlsEnabled = true,
  });

  final String url;
  final bool autoPlay;
  final BoxFit fit;
  final bool controlsEnabled;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: _VideoPreview(
        url: url,
        autoPlay: autoPlay,
        fit: fit,
        controlsEnabled: controlsEnabled,
      ),
    );
  }
}
