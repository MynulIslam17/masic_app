import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masic_generation/core/widgets/image_preview_viewer.dart';

void main() {
  Future<List<bool>> pump(WidgetTester tester) async {
    final zoomEvents = <bool>[];
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomableNetworkImage(
            url: 'https://example.invalid/a.jpg',
            onZoomChanged: zoomEvents.add,
          ),
        ),
      ),
    );
    return zoomEvents;
  }

  double scale(WidgetTester tester) => tester
      .widget<InteractiveViewer>(find.byType(InteractiveViewer))
      .transformationController!
      .value
      .getMaxScaleOnAxis();

  testWidgets('zoom surface is the full viewport, not the image box',
      (tester) async {
    await pump(tester);
    expect(tester.getSize(find.byType(InteractiveViewer)), const Size(400, 800));
  });

  testWidgets('double tap zooms in at the tap point, then back out',
      (tester) async {
    final events = await pump(tester);
    final target = tester.getCenter(find.byType(InteractiveViewer));

    await tester.tapAt(target);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(scale(tester), closeTo(2.5, 0.01));
    expect(events.last, isTrue, reason: 'parent locks page swipe');

    await tester.tapAt(target);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(scale(tester), closeTo(1, 0.01));
    expect(events.last, isFalse, reason: 'page swipe unlocked again');
  });

  testWidgets('leaving the page resets the zoom', (tester) async {
    await pump(tester);
    final target = tester.getCenter(find.byType(InteractiveViewer));
    await tester.tapAt(target);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(scale(tester), greaterThan(1));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZoomableNetworkImage(
            url: 'https://example.invalid/a.jpg',
            active: false,
          ),
        ),
      ),
    );
    expect(scale(tester), closeTo(1, 0.01));
  });
}
