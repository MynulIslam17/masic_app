import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/fonts.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class PhotoPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // ───── Photo Picker ─────
  static void showPhotoPicker({
    required BuildContext context,
    required Function(XFile file) onImagePicked,
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
                  ),
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    source: ImageSource.gallery,
                    onImagePicked: onImagePicked,
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
      }) {
    return InkWell(
      onTap: () async {
        final XFile? file = await _picker.pickImage(source: source);
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
          onFilePicked(result.files.first);
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