import 'package:flutter_test/flutter_test.dart';

import 'package:laundryhub/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LaundryHubApp());
    await tester.pumpAndSettle();

    expect(find.text('LaundryHub'), findsWidgets);
  });
}
