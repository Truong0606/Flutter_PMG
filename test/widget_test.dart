// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/main.dart';

void main() {
  testWidgets('App builds and shows HomePage', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Basic smoke checks for app bar title parts on HomePage
    expect(find.text('MerryStar'), findsOneWidget);
    expect(find.text('KINDERGARTEN'), findsOneWidget);
  });
}
