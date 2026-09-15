import 'dart:io';

import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/image_upload_helper.dart';
import 'package:simple_pdf_compression/simple_pdf_compression.dart';

/// Prepares CV, certificate, and other documents for multipart upload (nginx ~1MB limit).
class DocumentUploadHelper {
  DocumentUploadHelper._();

  static const int defaultMaxDocumentBytes = 450 * 1024;

  /// Reject obviously oversized picks before the user fills the form.
  static const int maxPickBytes = 15 * 1024 * 1024;

  static const _documentExtensions = {
    'pdf',
    'doc',
    'docx',
    'txt',
    'xlsx',
    'xls',
    'odt',
    'rtf',
  };

  static bool isDocumentFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return _documentExtensions.contains(ext);
  }

  static bool isPdfFile(File file) =>
      file.path.split('.').last.toLowerCase() == 'pdf';

  static void ensurePickSize(int? bytes) {
    if (bytes != null && bytes > maxPickBytes) {
      throw PayloadTooLargeException(
        'File is too large to upload. Choose a smaller PDF or document.',
      );
    }
  }

  static Future<File> prepareForUpload(
    File file, {
    int maxBytes = defaultMaxDocumentBytes,
  }) async {
    if (ImageUploadHelper.isImageFile(file)) {
      return ImageUploadHelper.prepareForUpload(
        file,
        minWidth: 1920,
        minHeight: 1080,
        maxBytes: maxBytes,
        tooLargeMessage:
            'Document image is too large. Use a smaller photo or export as PDF.',
      );
    }

    if (isPdfFile(file)) {
      return _preparePdf(file, maxBytes);
    }

    final label = isDocumentFile(file) ? 'Document' : 'File';
    return _ensureWithinLimit(
      file,
      maxBytes,
      '$label is too large. Use a file under ${_formatKb(maxBytes)} or compress it before uploading.',
    );
  }

  static Future<File> _preparePdf(File file, int maxBytes) async {
    final originalSize = await file.length();
    if (originalSize <= maxBytes) return file;

    try {
      final compressed = await PDFCompression().compressPdf(
        file,
        thresholdSize: maxBytes,
      );
      final compressedSize = await compressed.length();
      if (compressedSize <= maxBytes) return compressed;

      if (compressedSize < originalSize) {
        return _ensureWithinLimit(
          compressed,
          maxBytes,
          'PDF is still too large after compression. Remove pages or use a smaller file.',
        );
      }
    } catch (_) {
      // Encrypted/corrupt PDF — fall through to size check on original.
    }

    return _ensureWithinLimit(
      file,
      maxBytes,
      'PDF is too large. Compress it or use a shorter document (max ${ _formatKb(maxBytes)}).',
    );
  }

  static Future<File> _ensureWithinLimit(
    File file,
    int maxBytes,
    String message,
  ) async {
    if (await file.length() <= maxBytes) return file;
    throw PayloadTooLargeException(message);
  }

  static String _formatKb(int bytes) =>
      '${(bytes / 1024).round()} KB';
}
