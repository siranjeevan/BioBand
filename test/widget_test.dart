import 'package:flutter_test/flutter_test.dart';
import 'package:nadi_pariksh/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NadiParikshaApp());
    expect(find.text('Nadi Pariksh'), findsOneWidget);
  });
}
