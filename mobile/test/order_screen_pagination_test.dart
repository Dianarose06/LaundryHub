import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laundryhub/screens/order_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'keeps selected add-on subtotal across add-on pages',
    (WidgetTester tester) async {
      final client = _buildMockClient();

      await tester.pumpWidget(
        MaterialApp(home: OrderScreen(httpClient: client)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Soft Wash').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue →').first);
      await tester.pumpAndSettle();

      expect(find.text('Paged Add-on 01'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      await tester.ensureVisible(find.text('Paged Add-on 01'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paged Add-on 01'));
      await tester.pump();

      expect(find.text('Add-on subtotal: ₱ 11.00'), findsOneWidget);

      await tester.ensureVisible(find.text('Next').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next').first);
      await tester.pump();

      expect(find.text('Paged Add-on 01'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('Paged Add-on 07'), findsOneWidget);
      expect(find.text('Add-on subtotal: ₱ 11.00'), findsOneWidget);
    },
  );

  testWidgets(
    'keeps current page data when next page fetch fails and retries page load',
    (WidgetTester tester) async {
      int pageTwoCalls = 0;
      final client = _buildMockClient(
        onPageTwo: () {
          pageTwoCalls += 1;
          if (pageTwoCalls == 1) {
            return http.Response(
              jsonEncode({'message': 'Temporary failure'}),
              500,
              headers: const {'content-type': 'application/json'},
            );
          }

          return _jsonResponse(
            {
              'data': [
                {
                  'id': 7,
                  'name': 'Paged Add-on 07',
                  'description': 'Page 2 item',
                  'fee': 17.0,
                },
              ],
              'meta': {
                'current_page': 2,
                'per_page': 6,
                'total': 7,
                'last_page': 2,
                'from': 7,
                'to': 7,
                'has_more_pages': false,
              },
            },
          );
        },
      );

      await tester.pumpWidget(
        MaterialApp(home: OrderScreen(httpClient: client)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Soft Wash').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue →').first);
      await tester.pumpAndSettle();

      expect(find.text('Paged Add-on 01'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      await tester.ensureVisible(find.text('Next').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next').first);
      await tester.pumpAndSettle();

      expect(find.text('Paged Add-on 01'), findsOneWidget);
      expect(find.textContaining('Could not load this add-on page.'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      await tester.ensureVisible(find.text('Retry').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry').first);
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('Paged Add-on 07'), findsOneWidget);
      expect(find.textContaining('Could not load this add-on page.'), findsNothing);
    },
  );
}

MockClient _buildMockClient({http.Response Function()? onPageTwo}) {
  final addOns = List.generate(7, (index) {
    final number = index + 1;
    return <String, dynamic>{
      'id': number,
      'name': 'Paged Add-on ${number.toString().padLeft(2, '0')}',
      'description': 'Mock add-on $number',
      'fee': (10 + number).toDouble(),
    };
  });

  return MockClient((request) async {
    final path = request.url.path;

    if (path.endsWith('/services')) {
      return _jsonResponse({
        'data': [
          {
            'id': 1,
            'name': 'Soft Wash',
            'description': 'Gentle wash',
            'price_per_kg': 75.0,
          },
        ],
      });
    }

    if (path.endsWith('/barangays')) {
      return _jsonResponse({
        'data': [
          {
            'id': 1,
            'name': 'Barangay 59',
            'city': 'Tacloban City, Leyte',
            'zone': 1,
            'pickup_fee': 30.0,
            'delivery_fee': 30.0,
          },
        ],
        'meta': {
          'base_barangay': 'Barangay 47',
          'logistics_fee_explanation': {
            'delivery_can_be_higher': true,
            'pickup_applies_when': 'delivery_type is pickup',
            'delivery_applies_when': 'always',
            'reason': 'Mock logistics explanation',
          },
        },
      });
    }

    if (path.endsWith('/add-on-services')) {
      final serviceId = request.url.queryParameters['service_id'];
      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;

      if (serviceId != '1') {
        return _jsonResponse({
          'data': const [],
          'meta': {
            'current_page': 1,
            'per_page': 6,
            'total': 0,
            'last_page': 1,
            'from': null,
            'to': null,
            'has_more_pages': false,
          },
        });
      }

      if (page == 2 && onPageTwo != null) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        return onPageTwo();
      }

      if (page == 2) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        return _jsonResponse({
          'data': [addOns[6]],
          'meta': {
            'current_page': 2,
            'per_page': 6,
            'total': 7,
            'last_page': 2,
            'from': 7,
            'to': 7,
            'has_more_pages': false,
          },
        });
      }

      return _jsonResponse({
        'data': addOns.sublist(0, 6),
        'meta': {
          'current_page': 1,
          'per_page': 6,
          'total': 7,
          'last_page': 2,
          'from': 1,
          'to': 6,
          'has_more_pages': true,
        },
      });
    }

    return http.Response('Not Found', 404);
  });
}

http.Response _jsonResponse(Map<String, dynamic> body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: const {'content-type': 'application/json'},
  );
}
