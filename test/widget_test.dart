import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiddylingo/main.dart';

void main() {
  testWidgets('App displays title parts', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const KiddyLingoApp());

    // 2. Pump for a few frames to let everything settle
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 3. Check for known text parts that should be visible
    final kiddyLingoFinder = find.text('KiddyLingo');
    final adventureFinder = find.text('Adventure');
    
    expect(kiddyLingoFinder, findsOneWidget);
    expect(adventureFinder, findsOneWidget);
  });
}