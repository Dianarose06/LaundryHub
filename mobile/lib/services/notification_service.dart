import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? deviceToken;

  static String _getDeviceType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  static Future<void> initialize() async {
    try {
      // Initialize Firebase Messaging
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryForward: true,
        critical: false,
        provisional: false,
        sound: true,
      );

      // Get device token
      deviceToken = await _firebaseMessaging.getToken();
      print('[FCM] Device Token: $deviceToken');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[FCM] Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('[FCM] Message opened app: ${message.notification?.title}');
        _handleMessageClick(message);
      });

      // Handle background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Register device token with backend
      if (deviceToken != null) {
        await registerDeviceToken(deviceToken!);
      }
    } catch (e) {
      print('[FCM] Error initializing: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('[FCM] Background message received: ${message.notification?.title}');
    _handleMessage(message);
  }

  static void _handleMessage(RemoteMessage message) {
    print('[FCM] Handling message:');
    print('  Title: ${message.notification?.title}');
    print('  Body: ${message.notification?.body}');
    print('  Data: ${message.data}');
  }

  static void _handleMessageClick(RemoteMessage message) {
    final data = message.data;
    // Handle notification click - could navigate to order details, etc.
    if (data['order_id'] != null) {
      print('[FCM] Navigating to order: ${data['order_id']}');
    }
  }

  static Future<bool> registerDeviceToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        print('[FCM] No auth token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.apiPath}/device-tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': token,
          'device_type': _getDeviceType(),
          'device_name': '${Platform.operatingSystem} Device',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[FCM] Device token registered successfully');
        return true;
      } else {
        print('[FCM] Failed to register token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[FCM] Error registering token: $e');
      return false;
    }
  }

  static Future<bool> unregisterDeviceToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.apiPath}/device-tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[FCM] Error unregistering token: $e');
      return false;
    }
  }
}
