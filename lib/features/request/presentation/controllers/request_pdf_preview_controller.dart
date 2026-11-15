import 'dart:typed_data';

import 'package:masic_generation/core/helpers/localized_name_helper.dart';
import 'package:masic_generation/core/helpers/pdf_helper.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class RequestPdfPreviewController extends GetxController {
  static RequestPdfPreviewController get to => Get.find();

  final Rxn<Uint8List> pdfBytes = Rxn<Uint8List>();
  final RxString fileName = 'request_details.pdf'.obs;
  final RxnString applicantName = RxnString();
  final RxnString error = RxnString();
  final RxBool isLoading = true.obs;
  final RxBool isDownloading = false.obs;
  final RxBool isSharing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPdf();
  }

  Future<void> loadPdf() async {
    isLoading.value = true;
    error.value = null;

    final requestId = Get.arguments as String;
    final controller = RequestController.to;
    if (controller.findRequest(requestId) == null) {
      await controller.loadRequestDetails(requestId);
    }
    final request = controller.findRequest(requestId);

    if (request == null) {
      isLoading.value = false;
      error.value = 'Request not found';
      return;
    }

    try {
      pdfBytes.value = await PdfHelper.buildRequestPdfBytes(request);
      fileName.value = PdfHelper.fileNameFor(request);
      applicantName.value = await LocalizedNameHelper.resolveForExport(
        name: request.user?.name,
        arabicName: request.user?.arabicName,
      );
    } catch (_) {
      error.value = 'Failed to generate PDF';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> download() async {
    final bytes = pdfBytes.value;
    if (bytes == null || isDownloading.value) return;

    isDownloading.value = true;
    try {
      final path = await PdfHelper.downloadPdf(
        bytes: bytes,
        fileName: fileName.value,
      );
      ToastMessageHelper.show('PDF saved to $path');
    } catch (_) {
      ToastMessageHelper.show('Failed to download PDF');
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> share() async {
    final bytes = pdfBytes.value;
    if (bytes == null || isSharing.value) return;

    isSharing.value = true;
    try {
      await PdfHelper.sharePdfBytes(
        bytes: bytes,
        fileName: fileName.value,
        name: applicantName.value,
      );
    } catch (_) {
      ToastMessageHelper.show('Failed to share PDF');
    } finally {
      isSharing.value = false;
    }
  }
}
