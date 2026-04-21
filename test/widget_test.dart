// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:picfi/main.dart';

void main() {
  testWidgets('PicFi app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PicFiApp());
    expect(find.text('PicFi'), findsWidgets);
  });
}
