import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';


class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {


  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "Job"),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: CustomButton(
          label: "Save",
          onPressed: () {
            // TODO: call update API
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // ── Fields ─────────────────────────────────────────────────────
            CustomTextField(
              labelText: 'Company name',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _nameController,
              hintText: "Write here...",
            ),

            CustomTextField(
              labelText: 'Position title',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _positionController,
              hintText: "Write here...",
            ),
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'From',
                    showShadow: false,
                    borderColor: AppColors.colorE6E6E6,
                    filColor: AppColors.bgColor,
                    controller: _fromDateController,
                    hintText: "00/00/0000",
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _fromDateController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.r),
                Expanded(
                  child: CustomTextField(
                    labelText: 'To',
                    showShadow: false,
                    borderColor: AppColors.colorE6E6E6,
                    filColor: AppColors.bgColor,
                    controller: _toDateController,
                    hintText: "00/00/0000",
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _toDateController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                      }
                    },
                  ),
                ),
                ]
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
