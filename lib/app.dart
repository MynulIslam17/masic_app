import 'package:flutter/material.dart';
import 'package:masic_generation/core/helpers/app_log.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_pages.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/theme_data.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'masic',
          debugShowCheckedModeBanner: false,
          // GetX logs every controller/worker lifecycle event; keep only
          // navigation and errors so the console stays readable.
          logWriterCallback: (text, {bool isError = false}) {
            if (isError) {
              AppLog.error('GetX', text);
            } else if (text.contains('ROUTE')) {
              AppLog.info('Route', text);
            }
          },
          initialRoute: AppRoutes.splashScreen,
          getPages: AppPages.routes,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
        );
      },
    );
  }
}
