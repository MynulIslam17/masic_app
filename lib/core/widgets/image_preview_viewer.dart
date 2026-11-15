import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImagePreviewViewer extends StatefulWidget {
  const ImagePreviewViewer({
    super.key,
    required this.imageUrl,
    this.imageUrls,
    this.initialIndex = 0,
  });

  final String imageUrl;
  final List<String>? imageUrls;
  final int initialIndex;

  static Future<void> open(BuildContext context, {required String? imageUrl}) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return Future.value();

    return openGallery(context, imageUrls: [url]);
  }

  static Future<void> openGallery(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    final urls = imageUrls
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (urls.isEmpty) return Future.value();

    final safeIndex = initialIndex.clamp(0, urls.length - 1);

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => ImagePreviewViewer(
          imageUrl: urls[safeIndex],
          imageUrls: urls,
          initialIndex: safeIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<ImagePreviewViewer> createState() => _ImagePreviewViewerState();
}

class _ImagePreviewViewerState extends State<ImagePreviewViewer> {
  late final List<String> _urls;
  late int _currentIndex;
  late final PageController _pageController;
  bool _saving = false;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _urls = widget.imageUrls != null && widget.imageUrls!.isNotEmpty
        ? widget.imageUrls!
        : [widget.imageUrl];
    _currentIndex = widget.initialIndex.clamp(0, _urls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _currentUrl => _urls[_currentIndex];

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final currentUrl = _currentUrl;
      final response = await Dio().get<List<int>>(
        currentUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        ToastMessageHelper.show('Could not download image');
        return;
      }

      final ext = _extensionOf(currentUrl);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/announcement_${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Announcement image',
        ),
      );
    } catch (_) {
      ToastMessageHelper.show('Could not save image');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.webp')) return '.webp';
    if (path.endsWith('.gif')) return '.gif';
    return '.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = _urls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: hasMultiple
            ? Text(
                '${_currentIndex + 1} / ${_urls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.save_alt_rounded),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _urls.length,
        // While an image is zoomed, a horizontal drag pans the image instead
        // of flipping to the next page.
        physics: _zoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _zoomed = false;
          });
        },
        itemBuilder: (context, index) {
          return ZoomableNetworkImage(
            key: ValueKey('preview_$index'),
            url: _urls[index],
            active: index == _currentIndex,
            onZoomChanged: (zoomed) {
              if (index == _currentIndex && zoomed != _zoomed) {
                setState(() => _zoomed = zoomed);
              }
            },
          );
        },
      ),
    );
  }
}


/// Full-screen pinch / double-tap zoom for one image.
///
/// The zoom surface is the whole viewport (not just the image's box), so the
/// image can be enlarged past its letterboxed size and panned edge to edge.
/// Double tap zooms into the tapped point and back out; leaving the page
/// resets the zoom.
class ZoomableNetworkImage extends StatefulWidget {
  const ZoomableNetworkImage({
    super.key,
    required this.url,
    this.active = true,
    this.onZoomChanged,
    this.maxScale = 5,
    this.doubleTapScale = 2.5,
  });

  final String url;
  final bool active;
  final ValueChanged<bool>? onZoomChanged;
  final double maxScale;
  final double doubleTapScale;

  @override
  State<ZoomableNetworkImage> createState() => _ZoomableNetworkImageState();
}

class _ZoomableNetworkImageState extends State<ZoomableNetworkImage>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _animation;
  Animation<Matrix4>? _tween;
  Offset _doubleTapAt = Offset.zero;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final tween = _tween;
        if (tween != null) _transform.value = tween.value;
      });
    _transform.addListener(_reportZoom);
  }

  @override
  void didUpdateWidget(covariant ZoomableNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) {
      _animation.stop();
      _transform.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transform.removeListener(_reportZoom);
    _transform.dispose();
    _animation.dispose();
    super.dispose();
  }

  double get _scale => _transform.value.getMaxScaleOnAxis();

  void _reportZoom() {
    final zoomed = _scale > 1.01;
    if (zoomed == _zoomed) return;
    _zoomed = zoomed;
    widget.onZoomChanged?.call(zoomed);
  }

  void _animateTo(Matrix4 target) {
    _tween = Matrix4Tween(begin: _transform.value, end: target).animate(
      CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic),
    );
    _animation.forward(from: 0);
  }

  void _onDoubleTap() {
    if (_scale > 1.01) {
      _animateTo(Matrix4.identity());
      return;
    }
    final s = widget.doubleTapScale;
    final p = _doubleTapAt;
    // Keep the tapped point under the finger while scaling.
    _animateTo(
      Matrix4.identity()
        ..translateByDouble(-p.dx * (s - 1), -p.dy * (s - 1), 0, 1)
        ..scaleByDouble(s, s, 1, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: SizedBox.expand(
        child: InteractiveViewer(
          transformationController: _transform,
          minScale: 1,
          maxScale: widget.maxScale,
          // Pan only within the zoomed image, never into empty space.
          boundaryMargin: EdgeInsets.zero,
          panEnabled: true,
          onInteractionStart: (_) => _animation.stop(),
          child: SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
