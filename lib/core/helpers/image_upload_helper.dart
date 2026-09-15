import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:path_provider/path_provider.dart';

/// Resizes and compresses images so multipart uploads stay under typical nginx limits.
class ImageUploadHelper {
  ImageUploadHelper._();

  /// Target size aligned with common default `client_max_body_size` (1m) minus form fields.
  static const int defaultMaxUploadBytes = 900 * 1024;

  static const List<int> _qualitySteps = [85, 70, 55, 40, 30];

  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'heic', 'webp'};

  static bool isImageFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return _imageExtensions.contains(ext);
  }

  static Future<File> prepareBannerImage(File file) => prepareForUpload(
        file,
        minWidth: 1920,
        minHeight: 1080,
        maxBytes: defaultMaxUploadBytes,
        tooLargeMessage:
            'Banner image is too large. Choose a smaller photo or crop it before uploading.',
      );

  static Future<File> prepareProfileImage(File file) => prepareForUpload(
        file,
        minWidth: 1024,
        minHeight: 1024,
        maxBytes: 400 * 1024,
        tooLargeMessage:
            'Profile photo is too large. Choose a smaller image.',
      );

  /// Compresses only when the file looks like an image (e.g. CV/certificate scans).
  static Future<File> prepareIfImageFile(File file) async {
    if (!isImageFile(file)) return file;
    return prepareBannerImage(file);
  }

  static Future<File> prepareForUpload(
    File file, {
    required int minWidth,
    required int minHeight,
    required int maxBytes,
    required String tooLargeMessage,
  }) async {
    final dir = await getTemporaryDirectory();
    File? smallest;

    for (final quality in _qualitySteps) {
      final path =
          '${dir.path}/upload_${DateTime.now().millisecondsSinceEpoch}_$quality.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        path,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );
      if (compressed == null) continue;

      final candidate = File(compressed.path);
      final size = await candidate.length();
      if (smallest == null || size < await smallest.length()) {
        smallest = candidate;
      }
      if (size <= maxBytes) return candidate;
    }

    if (smallest != null && await smallest.length() <= maxBytes) {
      return smallest;
    }

    throw PayloadTooLargeException(tooLargeMessage);
  }
}
