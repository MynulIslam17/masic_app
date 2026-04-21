import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});
  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final QuestionModel question = QuestionModel.question;

    return CustomScaffold(
      appBar: CustomAppBar(title: "Polls Answers"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          CustomText(text: question.title,fontSize: 16.sp,bottom: 6.h,fontWeight: FontWeight.w500,),
          CustomText(
            textAlign: TextAlign.start,
           color: AppColors.primaryColor,
           fontSize: 12.sp,
           text:  question.description,),
          Divider(height: 44.h,),
          ...question.options.asMap().entries.map((e) => _buildOption(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildOption(int index, OptionModel opt) {
    final isSelected = _selected == index;
    final selected = _selected != null;
    return Stack(
      children: [
        if (selected)
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: opt.pct / 100,
              child: CustomContainer(
                marginBottom: 10.h,
                color: AppColors.primaryColor.withOpacity(0.1),
                radiusAll: 12.r,
              ),
            ),
          ),
        CustomContainer(
          onTap: (){
            if(selected) return;
            setState(() {
              _selected = index;
            });

          },
          marginBottom: 10.h,
          paddingHorizontal: 16.w,
          paddingVertical: 12.h,
          radiusAll: 12.r,
          bordersColor: isSelected ? AppColors.primaryColor : AppColors.colorB0B0B0,
          child: Row(
            children: [
              CustomContainer(
                shape: BoxShape.circle,
                bordersColor: isSelected ? AppColors.primaryColor : AppColors.colorB0B0B0,
                child: CustomContainer(
                  marginAll: 4.r,
                  shape: BoxShape.circle,
                  width: 20.w,
                  height: 20.h,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),

                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w,),
              Expanded(child: CustomText(
                textAlign: TextAlign.start,
                text: opt.label,fontSize: 14.sp,fontWeight: FontWeight.w500,)),
              if(selected)
              CustomText(text: '${opt.pct.toString()}%',fontSize: 14.sp,fontWeight: FontWeight.w500,),
              ]),
        ),
      ],
    );
  }
}