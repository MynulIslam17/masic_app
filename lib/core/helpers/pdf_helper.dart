import 'dart:io';

import 'package:flutter/services.dart';
import 'package:masic_generation/core/helpers/localized_name_helper.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/features/request/data/models/request_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PdfHelper {
  PdfHelper._();

  static const _primary = PdfColor.fromInt(0xFF204F9D);
  static const _mediaStoreChannel = MethodChannel('masic_generation/media_store');

  static String fileNameFor(RequestModel request) {
    final safeName = (request.user?.localizedDisplayName ?? 'request')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    return '${safeName.isEmpty ? 'request' : safeName}_details.pdf';
  }

  static Future<Uint8List> buildRequestPdfBytes(RequestModel request) async {
    final bytes = await _buildRequestPdf(request);
    return Uint8List.fromList(bytes);
  }

  static Future<File> generateRequestPdf(RequestModel request) async {
    final bytes = await buildRequestPdfBytes(request);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${fileNameFor(request)}');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Saves PDF to the public Downloads folder on Android (MediaStore on API 29+).
  /// On iOS, saves to the app Documents folder (share/Files app can access it).
  static Future<String> downloadPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (Platform.isAndroid) {
      return _downloadPdfAndroid(bytes: bytes, fileName: fileName);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> _downloadPdfAndroid({
    required Uint8List bytes,
    required String fileName,
  }) async {
    Future<String> invokeSave() async {
      final path = await _mediaStoreChannel.invokeMethod<String>(
        'savePdfToDownloads',
        {'fileName': fileName, 'bytes': bytes},
      );
      return path ?? 'Download/$fileName';
    }

    try {
      return await invokeSave();
    } on PlatformException catch (e) {
      if (e.code != 'PERMISSION') rethrow;

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
      return await invokeSave();
    }
  }

  static Future<void> sharePdfBytes({
    required Uint8List bytes,
    required String fileName,
    String? name,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    await sharePdfFile(file, name: name);
  }

  static Future<void> sharePdfFile(File file, {String? name}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Request Details - ${name ?? 'Applicant'}',
        text: 'Request details for ${name ?? 'applicant'}',
      ),
    );
  }

  static Future<List<int>> _buildRequestPdf(RequestModel request) async {
    final applicantName = await LocalizedNameHelper.resolveForExport(
      name: request.user?.name,
      arabicName: request.user?.arabicName,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: _primary,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Request Details',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    applicantName.isNotEmpty ? applicantName : 'N/A',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (context) => [
          _section('Personal Info', [
            _row('Name', applicantName.isNotEmpty ? applicantName : null),
            _row('Email', request.contact?.email ?? request.user?.email),
            _row('Phone', request.contact?.phone),
            _row('Address', request.contact?.address),
            if (request.contact?.linkedin != null)
              _row('LinkedIn', request.contact?.linkedin),
            if (request.status != null) _row('Status', request.status),
          ]),
          if (request.bio != null && request.bio!.trim().isNotEmpty)
            _section('Short Bio', [
              pw.Text(request.bio!, style: const pw.TextStyle(fontSize: 11)),
            ]),
          if (request.jobSpec != null && request.jobSpec!.trim().isNotEmpty)
            _section('Job Specialization', [
              pw.Text(request.jobSpec!, style: const pw.TextStyle(fontSize: 11)),
            ]),
          if (request.education != null && request.education!.isNotEmpty)
            _section(
              'Education',
              request.education!.asMap().entries.map((entry) {
                final e = entry.value;
                final to = e.isCurrent == true
                    ? 'Ongoing'
                    : TimeFormatHelper.formatDateTime(e.to);
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Education ${entry.key + 1}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                      _row('University', e.school),
                      _row('Degree', e.degree),
                      _row('Major', e.major),
                      _row(
                        'Period',
                        '${TimeFormatHelper.formatDateTime(e.from)} - $to',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (request.experience != null && request.experience!.isNotEmpty)
            _section(
              'Experience',
              request.experience!.asMap().entries.map((entry) {
                final e = entry.value;
                final to = e.isCurrent == true
                    ? 'Ongoing'
                    : TimeFormatHelper.formatDateTime(e.to);
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Experience ${entry.key + 1}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                      _row('Company', e.company),
                      _row('Position', e.position),
                      _row(
                        'Period',
                        '${TimeFormatHelper.formatDateTime(e.from)} - $to',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (request.declineReason != null &&
              request.declineReason!.trim().isNotEmpty)
            _section('Decline Reason', [
              pw.Text(
                request.declineReason!,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ]),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _primary,
            ),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _row(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value?.trim().isNotEmpty == true ? value! : 'N/A',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
