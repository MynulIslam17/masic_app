import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/helpers/dialog_close_helper.dart';

void main() {
  Future<BuildContext> pumpApp(WidgetTester tester) async {
    Get.reset();
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('home'))),
    );
    Get.to(() => const Scaffold(body: Text('page')));
    await tester.pumpAndSettle();
    return tester.element(find.text('page'));
  }

  testWidgets('bug repro: Get.isDialogOpen is false for showDialog',
      (tester) async {
    final ctx = await pumpApp(tester);
    showDialog(context: ctx, builder: (_) => const AlertDialog(title: Text('d')));
    await tester.pumpAndSettle();
    expect(find.text('d'), findsOneWidget);
    expect(Get.isDialogOpen, isNot(true)); // why the old check never closed it
  });

  testWidgets('action dialog closes after the action completes',
      (tester) async {
    final ctx = await pumpApp(tester);
    showDialog(context: ctx, builder: (_) => const AlertDialog(title: Text('d')));
    await tester.pumpAndSettle();

    expect(DialogCloseHelper.closeIfOpen(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('d'), findsNothing);
    expect(find.text('page'), findsOneWidget); // page underneath untouched
  });

  testWidgets('never pops the page when no dialog is open', (tester) async {
    await pumpApp(tester);
    expect(DialogCloseHelper.closeIfOpen(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('page'), findsOneWidget);
  });
}
