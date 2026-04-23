import 'package:flutter_test/flutter_test.dart';
import 'package:cev_2ddoc_reader/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CevApp()); // ← CevApp au lieu de MyApp
  });
}