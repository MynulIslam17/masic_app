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
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final url = _urls[index];
          return Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) => const CircularProgressIndicator(
                  color: AppColors.white,
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
