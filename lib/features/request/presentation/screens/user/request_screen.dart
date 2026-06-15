import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/request/data/models/request_local_model.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';
import 'package:masic_generation/features/request/presentation/widgets/request_widget.dart';
import 'package:get/get.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      appBar: CustomAppBar(title: "Request"),
      body: Padding(
        padding:  EdgeInsets.only(top: 24.h),
        child: Column(
          children: RequestLocalModel.requestDemoList
              .map((e) => Padding(
                padding:  EdgeInsets.only(bottom: 10.h),
                child: RequestWidget(request: e),
              ))
              .toList(),
        ),
      ),
    );
  }
}
