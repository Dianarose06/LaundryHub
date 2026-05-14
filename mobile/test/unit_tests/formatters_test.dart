import 'package:flutter_test/flutter_test.dart';

// Helper functions for testing
String formatCurrency(num amount) {
  final formatted = (amount.toInt()).toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return 'PHP $formatted';
}

String? formatDateOrEmpty(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '---';
  try {
    final date = DateTime.parse(dateStr);
    return formatDate(date);
  } catch (e) {
    return '---';
  }
}

String formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatOrderId(int id) {
  return '#LH-${id.toString().padLeft(3, '0')}';
}

String getStatusText(String status) {
  return status.substring(0, 1).toUpperCase() + status.substring(1).toLowerCase();
}

void main() {
  group('Currency Formatter', () {
    test('formats currency with PHP symbol', () {
      final result = formatCurrency(150);
      expect(result, 'PHP 150');
    });

    test('formats large numbers with commas', () {
      final result = formatCurrency(1500);
      expect(result, 'PHP 1,500');
    });

    test('handles zero', () {
      final result = formatCurrency(0);
      expect(result, 'PHP 0');
    });

    test('handles decimal values rounds down', () {
      final result = formatCurrency(150.50);
      expect(result, 'PHP 150');
    });
  });

  group('Date Formatter', () {
    test('formats date correctly', () {
      final date = DateTime(2026, 5, 12);
      final result = formatDate(date);
      expect(result, equals('May 12, 2026'));
    });

    test('returns --- for null date', () {
      final result = formatDateOrEmpty(null);
      expect(result, '---');
    });

    test('returns --- for empty string', () {
      final result = formatDateOrEmpty('');
      expect(result, '---');
    });

    test('formats valid date string', () {
      final result = formatDateOrEmpty('2026-05-12');
      expect(result, isNotEmpty);
      expect(result, 'May 12, 2026');
    });
  });

  group('Order Display ID', () {
    test('formats order ID with padding', () {
      final result = formatOrderId(1);
      expect(result, '#LH-001');
    });

    test('formats double digit order ID', () {
      final result = formatOrderId(42);
      expect(result, '#LH-042');
    });

    test('formats triple digit order ID', () {
      final result = formatOrderId(123);
      expect(result, '#LH-123');
    });

    test('handles zero order ID', () {
      final result = formatOrderId(0);
      expect(result, '#LH-000');
    });
  });

  group('Status Badge Text', () {
    test('returns pending status', () {
      final result = getStatusText('pending');
      expect(result, 'Pending');
    });

    test('returns completed status', () {
      final result = getStatusText('completed');
      expect(result, 'Completed');
    });

    test('returns ongoing status', () {
      final result = getStatusText('ongoing');
      expect(result, 'Ongoing');
    });

    test('handles mixed case status', () {
      final result = getStatusText('READY');
      expect(result, 'Ready');
    });
  });
}

