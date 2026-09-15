import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/fonts.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/document_upload_helper.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';

class PhotoPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // ───── Photo Picker ─────
  static void showPhotoPicker({
    required BuildContext context,
    required Function(XFile file) onImagePicked,
    double maxWidth = 1920,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'Select Photo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontName: FontFamily.poppins,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    source: ImageSource.camera,
                    onImagePicked: onImagePicked,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    source: ImageSource.gallery,
                    onImagePicked: onImagePicked,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───── File Picker ─────
  static void showFilePicker({
    required BuildContext context,
    required Function(PlatformFile file) onFilePicked,
    List<String> allowedExtensions = const ['pdf', 'doc', 'docx', 'txt', 'xlsx'],
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'Select File',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontName: FontFamily.poppins,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFileOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'PDF / DOC',
                    type: FileType.custom,
                    allowedExtensions: allowedExtensions,
                    onFilePicked: onFilePicked,
                  ),
                  _buildFileOption(
                    context,
                    icon: Icons.folder_open,
                    label: 'Any File',
                    type: FileType.any,
                    allowedExtensions: null,
                    onFilePicked: onFilePicked,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───── Private: Image Option ─────
  static Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required ImageSource source,
        required Function(XFile file) onImagePicked,
        double maxWidth = 1920,
        double maxHeight = 1080,
        int imageQuality = 85,
      }) {
    return InkWell(
      onTap: () async {
        final XFile? file = await _picker.pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
        Navigator.pop(context);
        if (file != null) onImagePicked(file);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: _buildOptionUI(icon: icon, label: label),
    );
  }

  // ───── Private: File Option ─────
  static Widget _buildFileOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required FileType type,
        required List<String>? allowedExtensions,
        required Function(PlatformFile file) onFilePicked,
      }) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final FilePickerResult? result = await FilePicker.pickFiles(
          type: type,
          allowedExtensions: allowedExtensions,
        );
        if (result != null && result.files.isNotEmpty) {
          final picked = result.files.first;
          try {
            DocumentUploadHelper.ensurePickSize(picked.size);
            onFilePicked(picked);
          } on AppException catch (e) {
            ToastMessageHelper.show(e.message);
          }
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: _buildOptionUI(icon: icon, label: label),
    );
  }

  // ───── Private: Shared UI ─────
  static Widget _buildOptionUI({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(16.r),
          child: Icon(icon, size: 30.r, color: AppColors.primaryColor),
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: label,
          color: AppColors.darkColor,
          fontName: FontFamily.poppins,
        ),
      ],
    );
  }
}