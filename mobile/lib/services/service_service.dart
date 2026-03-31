import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ServiceService {
  static String get _baseUrl => ApiConfig.apiPath;

  /// Fetches all active services
  static Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/services'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'data': data['data'] as List<dynamic>? ?? [],
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch services (${response.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Get emoji for a service name
  static String getServiceEmoji(String serviceName) {
    final normalized = serviceName.toLowerCase().trim();

    if (normalized.contains('wash-dry-fold') || normalized.contains('wash–dry–fold')) {
      return '🧺';
    } else if (normalized.contains('dry cleaning') || normalized.contains('dry clean')) {
      return '✨';
    } else if (normalized.contains('beddings')) {
      return '🛏️';
    } else if (normalized.contains('express wash')) {
      return '⚡';
    } else if (normalized.contains('soft wash')) {
      return '🌸';
    }

    return '🧺'; // Default
  }

  /// Get Material Design icon for a service name
  static IconData getServiceIcon(String serviceName) {
    final normalized = serviceName.toLowerCase().trim();

    if (normalized.contains('wash-dry-fold') || normalized.contains('wash–dry–fold')) {
      return Icons.local_laundry_service;
    } else if (normalized.contains('dry cleaning') || normalized.contains('dry clean')) {
      return Icons.cleaning_services;
    } else if (normalized.contains('beddings')) {
      return Icons.bed;
    } else if (normalized.contains('express wash')) {
      return Icons.flash_on;
    } else if (normalized.contains('soft wash')) {
      return Icons.spa;
    }

    return Icons.local_laundry_service; // Default
  }

  /// Format service name properly
  static String formatServiceName(String serviceName) {
    if (serviceName.isEmpty) return 'Unknown Service';

    String cleaned = serviceName.replaceAll('_', ' ').trim();

    bool hasHyphens = cleaned.contains('-');

    if (hasHyphens) {
      return cleaned
          .split('-')
          .map((part) {
            String trimmed = part.trim();
            if (trimmed.isEmpty) return '';
            return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
          })
          .join('-');
    } else {
      return cleaned
          .split(' ')
          .map((part) {
            String trimmed = part.trim();
            if (trimmed.isEmpty) return '';
            return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
          })
          .join(' ');
    }
  }
}
