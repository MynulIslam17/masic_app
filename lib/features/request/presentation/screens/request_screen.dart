import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/home/presentation/widgets/home_simmer.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:flutter_task/features/request/presentation/widgets/request_card_widget.dart';
import 'package:get/get.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RequestController.to;
    return CustomScaffold(
      paddingSide: 0,
      appBar: CustomAppBar(title: "Requested"),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Column(
          children: [
            Obx(
                    () {
                  switch (controller.loadingState) {
                    case LoadingState.initial:
                    case LoadingState.loading:
                      return HomeShimmer();

                    case LoadingState.offline:
                    case LoadingState.error:
                      return EmptyDataWidget(
                        message: '',
                        onRefresh: () async => await controller.refresh(),
                      );

                    case LoadingState.loaded:
                      return ListView.separated(
                        controller: controller.scrollController,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: controller.requests.length,
                        itemBuilder: (context, index) {
                          final request = controller.requests[index];
                          return RequestCardWidget(request: request);
                        }, separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 10.h);
                      },

                      );

                  }
                }
            ),
            Obx(
                  () => controller.isLoadingMore
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(child: CustomLoader()),
              )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),

    );
  }
}
