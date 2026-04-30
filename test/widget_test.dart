// Smoke test — renders an isolated MaterialApp with a placeholder child
// so the test boots without invoking main.dart's Supabase / Hive init.
// Real routing logic is exercised by route_decision_test.dart which
// avoids pulling in those services.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp boots without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('SafeLink Aid')),
    ));
    expect(find.text('SafeLink Aid'), findsOneWidget);
  });
}
