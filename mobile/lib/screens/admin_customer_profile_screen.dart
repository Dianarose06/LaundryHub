import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../services/admin_profile_service.dart';

class AdminCustomerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const AdminCustomerProfileScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<AdminCustomerProfileScreen> createState() =>
      _AdminCustomerProfileScreenState();
}

class _AdminCustomerProfileScreenState
    extends State<AdminCustomerProfileScreen> {
  static const _primary = Color(0xFF2563EB);
  static const _navy = Color(0xFF0F172A);
  static const _surface = Color(0xFFF8FAFC);
  static const _muted = Color(0xFF94A3B8);
  static const _border = Color(0xFFE2E8F0);

  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _orders = [];
  late AdminProfileService _profileService;

  @override
  void initState() {
    super.initState();
    _profileService = AdminProfileService(Dio());
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    _loadCustomerProfile();
    await _loadOrders();
  }

  Future<void> _loadCustomerProfile() async {
    try {
      final profile = await _profileService.getCustomerProfile(
        widget.customer['id'] as int,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile['data'] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _loadOrders() async {
    try {
      final result = await _profileService.getCustomerOrders(
        widget.customer['id'] as int,
      );
      if (!mounted) return;
      final ordersList = List<Map<String, dynamic>>.from(
        result['data'] as List? ?? [],
      );
      setState(() => _orders = ordersList);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customer Profile',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? Center(
                  child: Text(
                    'Failed to load profile',
                    style: GoogleFonts.outfit(color: _muted),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      _buildOrdersSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final picture = _profile?['profile_picture_url'] as String?;
    final name = _profile?['name'] as String? ?? 'Unknown';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: _primary.withValues(alpha: 0.1),
                backgroundImage:
                    picture != null ? NetworkImage(picture) : null,
                child: picture == null
                    ? Text(
                        (name)[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile?['email'] as String? ?? 'N/A',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _dateBadge(
                          '${_profile?['orders_count'] ?? 0} Orders',
                        ),
                        const SizedBox(width: 8),
                        _dateBadge(
                          '₱${_profile?['total_spent'] ?? '0'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            'Email',
            _profile?['email'] as String? ?? 'N/A',
          ),
          _infoRow(
            'Phone',
            _profile?['phone'] as String? ?? 'Not provided',
          ),
          _infoRow(
            'Address',
            '${_profile?['address'] ?? 'N/A'}, ${_profile?['city'] ?? 'N/A'}, ${_profile?['country'] ?? 'N/A'}',
          ),
          _infoRow(
            'Date of Birth',
            _profile?['date_of_birth'] as String? ?? 'Not provided',
          ),
          _infoRow(
            'Gender',
            _profile?['gender'] as String? ?? 'Not provided',
          ),
          _infoRow(
            'Loyalty Points',
            '${_profile?['loyalty_points'] ?? 0} pts',
          ),
          _infoRow(
            'Notifications',
            (_profile?['notifications_enabled'] as bool? ?? true)
                ? 'Enabled'
                : 'Disabled',
          ),
          _infoRow(
            'Email Verified',
            (_profile?['email_verified_at'] != null) ? 'Yes' : 'No',
          ),
          _infoRow(
            'Profile Completed',
            (_profile?['profile_completed_at'] != null) ? 'Yes' : 'No',
          ),
          _infoRow(
            'Member Since',
            _profile?['created_at'] as String? ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order History (${_orders.length})',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 12),
          _orders.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Center(
                    child: Text(
                      'No orders yet',
                      style: GoogleFonts.dmSans(color: _muted),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _orders.length,
                  itemBuilder: (_, i) => _buildOrderCard(_orders[i]),
                ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = '#LH-${(order['id'] ?? 0).toString().padLeft(4, '0')}';
    final status = (order['status'] ?? 'pending').toString().toLowerCase();
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service: ${order['service_type'] ?? 'N/A'}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Weight: ${order['weight_kg'] ?? '0'} kg',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _muted,
                    ),
                  ),
                ],
              ),
              Text(
                '₱${order['total_price'] ?? '0'}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'ongoing':
        return Colors.blue;
      case 'ready':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return _muted;
    }
  }
}
