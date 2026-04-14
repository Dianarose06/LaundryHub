import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late ProfileService _profileService;
  late Future<CustomerProfile> _profileFuture;
  bool _notificationsEnabled = true;
  bool _orderConfirmationEnabled = true;
  bool _statusUpdateEnabled = true;
  bool _paymentReceiptEnabled = true;
  bool _readyForPickupEnabled = true;
  bool _deliveryScheduledEnabled = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(Dio());
    _profileFuture = _profileService.getProfile();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _notificationsEnabled = profile.notificationsEnabled;
          // These would come from extended profile fields if implemented
          _orderConfirmationEnabled = true;
          _statusUpdateEnabled = true;
          _paymentReceiptEnabled = true;
          _readyForPickupEnabled = true;
          _deliveryScheduledEnabled = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMainNotificationSettings(bool value) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      _notificationsEnabled = value;
    });

    try {
      await _profileService.updateProfile(
        notificationsEnabled: value,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Notifications enabled'
                  : 'Notifications disabled',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _notificationsEnabled = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master Toggle
              _buildNotificationHeader(),
              const SizedBox(height: 24),

              // Notification Types (only visible if enabled)
              if (_notificationsEnabled) ...[
                const Text(
                  'Notification Types',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNotificationTypeCard(
                  icon: Icons.check_circle_outline,
                  title: 'Order Confirmation',
                  subtitle: 'Get confirmation when your order is placed',
                  enabled: _orderConfirmationEnabled,
                  onChanged: null, // Disabled for now - just info
                ),
                _buildNotificationTypeCard(
                  icon: Icons.update_outlined,
                  title: 'Order Status Updates',
                  subtitle: 'Receive updates when your order status changes',
                  enabled: _statusUpdateEnabled,
                  onChanged: null,
                ),
                _buildNotificationTypeCard(
                  icon: Icons.receipt_outlined,
                  title: 'Payment Receipts',
                  subtitle: 'Get payment confirmation and receipt',
                  enabled: _paymentReceiptEnabled,
                  onChanged: null,
                ),
                _buildNotificationTypeCard(
                  icon: Icons.local_shipping_outlined,
                  title: 'Ready for Pickup',
                  subtitle: 'Notification when your laundry is ready',
                  enabled: _readyForPickupEnabled,
                  onChanged: null,
                ),
                _buildNotificationTypeCard(
                  icon: Icons.schedule_outlined,
                  title: 'Delivery Scheduled',
                  subtitle: 'Confirm your delivery appointment',
                  enabled: _deliveryScheduledEnabled,
                  onChanged: null,
                ),
                const SizedBox(height: 24),
              ],

              // Email Settings
              _buildEmailSettingsSection(),
              const SizedBox(height: 24),

              // Notification History
              _buildNotificationHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage how we contact you',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: _notificationsEnabled,
                    onChanged: _isUpdating
                        ? null
                        : _updateMainNotificationSettings,
                    activeColor: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required Function(bool)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: enabled ? const Color(0xFF1565C0) : Colors.grey,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: onChanged != null
              ? Switch(
                  value: enabled,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF1565C0),
                )
              : Icon(
                  enabled ? Icons.check : Icons.close,
                  color: enabled ? Colors.green : Colors.grey,
                ),
        ),
      ),
    );
  }

  Widget _buildEmailSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 12),
                    FutureBuilder<CustomerProfile>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  snapshot.data?.email ?? 'Not provided',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Notification Frequency',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will receive emails immediately when important events occur on your orders.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Order Confirmation',
                  'Sent when your order is successfully placed',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Status Updates',
                  'Receive updates as your order progresses',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Payment Receipt',
                  'Get confirmation when payment is received',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Ready Notification',
                  'Alert when your laundry is ready for pickup',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Delivery Scheduled',
                  'Confirmation of your delivery appointment',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: const Color(0xFFFFF3E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFB74D)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: const [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFF57C00),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Disable notifications only if you prefer not to receive emails. You can always check your order status in the app.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Icon(
            Icons.check_circle,
            size: 18,
            color: Colors.green.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
