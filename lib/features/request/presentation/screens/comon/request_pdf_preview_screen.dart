import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_pdf_preview_controller.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

class RequestPdfPreviewScreen extends StatelessWidget {
  const RequestPdfPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestPdfPreviewController>();

    return CustomScaffold(
      backgroundColor: AppColors.bgColor,
      appBar: const CustomAppBar(title: 'PDF Preview'),
      body: Obx(() => _buildBody(controller)),
      bottomNavigationBar: Obx(() {
        if (controller.pdfBytes.value == null) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: CustomButton(
              label: 'Share',
              prefixIconShow: true,
              prefixIcon: Icons.share_rounded,
              foregroundColor: Colors.white,
              isLoading: controller.isSharing.value,
              onPressed: controller.share,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBody(RequestPdfPreviewController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CustomLoader());
    }
    if (controller.error.value != null) {
      return Center(child: CustomText(text: controller.error.value!));
    }
    final bytes = controller.pdfBytes.value;
    if (bytes == null) {
      return const Center(child: CustomText(text: 'No PDF available'));
    }

    return PdfPreview(
      build: (_) async => bytes,
      pdfFileName: controller.fileName.value,
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      useActions: false,
      padding: EdgeInsets.zero,
      scrollViewDecoration: const BoxDecoration(color: AppColors.bgColor),
      pdfPreviewPageDecoration: const BoxDecoration(color: Colors.white),
      previewPageMargin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }
}
