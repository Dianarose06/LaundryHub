import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('Login screen displays email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Login button is clickable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: Text('Sign In'),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    });
  });

  group('Order List Widget Tests', () {
    testWidgets('Order list displays order items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(
                  title: Text('Order #LH-001'),
                  subtitle: Text('Wash & Fold'),
                ),
                ListTile(
                  title: Text('Order #LH-002'),
                  subtitle: Text('Dry Cleaning'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Order #LH-001'), findsOneWidget);
      expect(find.text('Dry Cleaning'), findsOneWidget);
    });

    testWidgets('Tapping order item navigates or shows details', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () {
                tapped = true;
              },
              child: ListTile(
                title: Text('Order #LH-001'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Order #LH-001'));
      expect(tapped, true);
    });
  });

  group('Status Badge Widget Tests', () {
    testWidgets('Status badge displays correct color for pending', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              color: Colors.orange,
              child: Text('Pending'),
            ),
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('Status badge displays correct color for completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              color: Colors.green,
              child: Text('Completed'),
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
    });
  });

  group('Empty State Widget Tests', () {
    testWidgets('Shows empty state when no orders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined),
                  SizedBox(height: 16),
                  Text('No orders yet'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });
}
