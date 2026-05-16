import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picfi/main.dart';
import '../firebase_test_setup.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  testWidgets('app renders without errors', (WidgetTester tester) async {
    if (!isFirebaseSetupSuccessful) return;
    final key = GlobalKey<ScaffoldMessengerState>();
    await tester.pumpWidget(PicFiApp(scaffoldMessengerKey: key));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
