import 'package:flutter_test/flutter_test.dart';
import 'package:agrismart/app.dart';

void main() {
  testWidgets('AgriSmart app starts', (tester) async {
    await tester.pumpWidget(const AgriSmartApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('AgriSmart'), findsWidgets);
  });
}
