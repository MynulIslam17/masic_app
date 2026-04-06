// import 'package:masic/app/utils/app_colors.dart';
// import 'package:masic/custom_assets/assets.gen.dart';
// import 'package:masic/feature/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
// import 'package:masic/routes/app_routes.dart';
// import 'package:masic/services/auth_service.dart';
// import 'package:masic/widgets/custom_app_bar.dart';
// import 'package:masic/widgets/custom_button.dart';
// import 'package:masic/widgets/custom_container.dart';
// import 'package:masic/widgets/custom_scaffold.dart';
// import 'package:masic/widgets/custom_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
//
// class RoleScreen extends StatelessWidget {
//   const RoleScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       appBar: CustomAppBar(
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 8.0.w),
//             child: GestureDetector(
//               child: const Icon(Icons.more_vert, color: AppColors.primaryColor),
//               onTapDown: (TapDownDetails details) async {
//                 final tapPosition = details.globalPosition;
//                 final selected = await showMenu(
//                   color: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   surfaceTintColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   context: context,
//                   elevation: 0,
//                   constraints: BoxConstraints(maxWidth: double.infinity),
//                   position: RelativeRect.fromLTRB(
//                     tapPosition.dx,
//                     tapPosition.dy,
//                     tapPosition.dx,
//                     tapPosition.dy,
//                   ),
//                   items: [
//                     PopupMenuItem(
//                       value: 'edit',
//                       child: CustomContainer(
//                         color: AppColors.primaryColor100,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.primaryColor.withOpacity(0.1),
//                             blurRadius: 23.r,
//                             offset: Offset(0, 0),
//                           ),
//                         ],
//                         paddingTop: 24.h,
//                         paddingBottom: 10.h,
//                         paddingLeft: 16.w,
//                         paddingRight: 16.w,
//                         radiusAll: 12.r,
//                         width: double.infinity,
//                         //height: 120,
//                         child: _buildCustomContainer(
//                           icon: Assets.icons.seller.path,
//                           title: 'Use as Seller',
//                           description:
//                               'Grow your business by showcasing products through reels, engaging buyers directly, and building trust in a social marketplace.',
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//
//                 if (selected == 'edit') {
//                   Get.toNamed(AppRoutes.shopSignUpScreen);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Assets.icons.logo.svg(),
//           CustomText(text: "Let's get started!", top: 8.h),
//           CustomText(
//             left: 16.w,
//             right: 16.w,
//             top: 44.h,
//             bottom: 16.h,
//             fontWeight: FontWeight.w600,
//             fontSize: 24.sp,
//             color: AppColors.primaryColor,
//             text: "Choose how you want to use the app",
//           ),
//
//           _buildCustomContainer(
//             onTap: () {
//               Get.toNamed(AppRoutes.signUpScreen);
//               //Get.offAllNamed(AppRoutes.customBottomNavUserBar);
//               //Get.find<CustomBottomNavBarController>().onChange(0);
//             },
//             icon: Assets.icons.user.path,
//             title: 'Use as Customer',
//             description:
//                 'Shop smarter by browsing products, watching reels from sellers, and connecting directly with the people behind your favorite finds',
//           ),
//
//           SizedBox(height: 20.h),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: CustomContainer(
//                   height: 1.h,
//                   begin: Alignment.centerRight,
//                   end: Alignment.centerLeft,
//                   linearColors: [
//                     AppColors.primaryRedColor,
//                     AppColors.bgColor,
//                   ],
//                 ),
//               ),
//               CustomText(text: 'Or log in with',fontSize: 12.sp,fontWeight: FontWeight.w600,left: 9.w,right: 9.w),
//               Expanded(
//                 child: CustomContainer(
//                   height: 1.h,
//                   linearColors: [
//                     AppColors.primaryRedColor,
//                     AppColors.bgColor,
//                   ],
//                   end: Alignment.centerRight,
//                   begin: Alignment.centerLeft,
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 20.h),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Flexible(
//                 child: GestureDetector(
//                   onTap: () async{
//                     // onPressApple();
//                     await AuthService().signInWithGoogle();
//                   },
//                   child: Assets.icons.google.svg(),
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Flexible(
//                 child: GestureDetector(
//                   onTap: () async{
//                     // onPressApple();
//                     await AuthService().signInWithApple();
//                   },
//                   child: Assets.icons.apple.svg(),
//                 ),
//               ),
//
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCustomContainer({
//     required String icon,
//     required String title,
//     required String description,
//      VoidCallback? onTap,
//   }) {
//     return CustomContainer(
//       onTap: onTap,
//       paddingAll: 2.r,
//       radiusAll: 14.r,
//       width: double.infinity,
//       bordersColor: AppColors.color444444,
//       borderWidth: 0.8,
//       child: Row(
//         children: [
//           SvgPicture.asset(icon, height: 117.h, width: 117.w),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CustomText(
//                   textAlign: TextAlign.start,
//                   text: title,
//                   fontSize: 16.sp,
//                 ),
//                 CustomText(
//                   top: 6.h,
//                   textAlign: TextAlign.start,
//                   text: description,
//                   fontSize: 10.sp,
//                 ),
//
//                 SizedBox(height: 12.h),
//                 Align(
//                   alignment: Alignment(0.8, 0),
//                     child: CustomButton(onPressed: onTap, label: 'Sign Up', height: 24.h, width: 100.w, fontSize: 10.sp))
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
