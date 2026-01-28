import 'package:flutter_test/flutter_test.dart';
import 'package:babygamesdemo/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const BabyGamesApp());
    expect(find.text('Baby Learning Games'), findsOneWidget);
  });
}