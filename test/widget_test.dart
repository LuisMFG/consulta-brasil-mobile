import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_brasil/main.dart'; // já está correto

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Corrigir aqui ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    await tester.pumpWidget(const ConsultaBrasilApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
