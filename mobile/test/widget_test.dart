import 'package:flutter_test/flutter_test.dart';
import 'package:agrismart/main.dart';
void main(){ testWidgets('AgriSmart dashboard renders', (tester) async { await tester.pumpWidget(const AgriSmartApp()); expect(find.text('AgriSmart'), findsOneWidget); expect(find.text('Crop Recommendation'), findsOneWidget); }); }
