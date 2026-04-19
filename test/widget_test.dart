import 'package:flutter_test/flutter_test.dart';
import 'package:eulalia_app/main.dart';

void main() {
  testWidgets('EulaliaApp renders login page', (WidgetTester tester) async {
    await tester.pumpWidget(const EulaliaApp());
    await tester.pumpAndSettle();

    expect(find.text('Eulalia'), findsOneWidget);
  });
}