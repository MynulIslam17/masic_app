import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/request/widgets/request_card_widget.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      appBar: CustomAppBar(title: "Request"),
      body: ListView.separated(
        physics: AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()
        ),
        itemCount: 10,
          itemBuilder: (context, index) {
        return RequestCardWidget();
      }, separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 10.h);
      },

        ),
    );

  }
}
