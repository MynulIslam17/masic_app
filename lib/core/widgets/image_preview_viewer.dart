import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImagePreviewViewer extends StatefulWidget {
  const ImagePreviewViewer({super.key, required this.imageUrl});

  final String imageUrl;

  static Future<void> open(BuildContext context, {required String? imageUrl}) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return Future.value();

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => ImagePreviewViewer(imageUrl: url),
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
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final response = await Dio().get<List<int>>(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        ToastMessageHelper.show('Could not download image');
        return;
      }

      final ext = _extensionOf(widget.imageUrl);
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
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
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
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
      ),
    );
  }
}
