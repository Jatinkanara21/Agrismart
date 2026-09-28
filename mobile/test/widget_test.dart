import 'package:agrismart/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AgriSmart login screen renders', (tester) async {
    await tester.pumpWidget(const AgriSmartApp());
    expect(find.text('AgriSmart'), findsOneWidget);
    expect(find.text('AI-Powered Smart Farming Assistant'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create a farmer account'), findsOneWidget);
  });

  testWidgets('AgriSmart dashboard renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardPage(),
      ),
    );
    expect(find.text('AgriSmart'), findsOneWidget);
    expect(find.text('Crop Recommendation'), findsOneWidget);
    expect(find.text('Disease Detection'), findsOneWidget);
    expect(find.text('Yield Prediction'), findsOneWidget);
    expect(find.text('AgriBot'), findsOneWidget);
  });
}
