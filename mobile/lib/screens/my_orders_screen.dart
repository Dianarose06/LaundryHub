import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';
import '../services/service_service.dart';

// ignore_for_file: constant_identifier_names
class _M {
  static const primary     = Color(0xFF2563EB);
  static const primaryPale = Color(0xFFEFF6FF);
  static const navy        = Color(0xFF0F172A);
  static const slate       = Color(0xFF334155);
  static const muted       = Color(0xFF94A3B8);
  static const border      = Color(0xFFE2E8F0);
  static const surface     = Color(0xFFF8FAFC);
  static const green       = Color(0xFF10B981);
  static const greenLight  = Color(0xFFECFDF5);
  static const amber       = Color(0xFFF59E0B);
  static const amberLight  = Color(0xFFFFFBEB);
  static const red         = Color(0xFFEF4444);
  static const redLight    = Color(0xFFFEF2F2);
}

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with WidgetsBindingObserver {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = 'all';
  bool _deliveryCanBeHigher = true;
  String _pickupAppliesWhen = 'delivery_type is pickup';
  String _deliveryAppliesWhen = 'always';
  String _logisticsReason =
      'Delivery includes route planning, customer handoff coordination, and possible wait time.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOrders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh orders when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - refreshing customer orders on MyOrdersScreen');
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await OrderService.getOrders();

    if (!mounted) return;

    if (result['success'] == true) {
      final rawMeta = result['meta'];
      final meta = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : const <String, dynamic>{};
      final rawExplanation = meta['logistics_fee_explanation'];
      final explanation = rawExplanation is Map
        ? Map<String, dynamic>.from(rawExplanation)
        : const <String, dynamic>{};

      setState(() {
        _orders = result['data'] as List<dynamic>;
      final deliveryCanBeHigher = explanation['delivery_can_be_higher'];
      _deliveryCanBeHigher =
        deliveryCanBeHigher is bool ? deliveryCanBeHigher : true;

      final pickupAppliesWhen =
        explanation['pickup_applies_when']?.toString().trim();
      _pickupAppliesWhen =
        (pickupAppliesWhen != null && pickupAppliesWhen.isNotEmpty)
          ? pickupAppliesWhen
          : 'delivery_type is pickup';

      final deliveryAppliesWhen =
        explanation['delivery_applies_when']?.toString().trim();
      _deliveryAppliesWhen =
        (deliveryAppliesWhen != null && deliveryAppliesWhen.isNotEmpty)
          ? deliveryAppliesWhen
          : 'always';

      final logisticsReason = explanation['reason']?.toString().trim();
      _logisticsReason =
        (logisticsReason != null && logisticsReason.isNotEmpty)
          ? logisticsReason
          : 'Delivery includes route planning, customer handoff coordination, and possible wait time.';

        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = _safeOrdersErrorMessage(result['message']?.toString());
        _isLoading = false;
      });
    }
  }

  String _safeOrdersErrorMessage(String? rawMessage) {
    if (rawMessage == null || rawMessage.trim().isEmpty) {
      return 'Unable to load your orders right now. Please try again.';
    }

    final normalized = rawMessage.toLowerCase();
    if (normalized.contains('sqlstate') ||
        normalized.contains('base table') ||
        normalized.contains('exception') ||
        normalized.contains('stack trace')) {
      return 'Unable to load your orders right now. Please try again.';
    }

    if (rawMessage.length > 150) {
      return '${rawMessage.substring(0, 147)}...';
    }

    return rawMessage;
  }

  String get _pickupFeeRuleLabel {
    final normalized = _pickupAppliesWhen.trim().toLowerCase();
    if (normalized == 'delivery_type is pickup') {
      return 'applies only when you choose Pickup';
    }

    return _pickupAppliesWhen;
  }

  String get _deliveryFeeRuleLabel {
    final normalized = _deliveryAppliesWhen.trim().toLowerCase();
    if (normalized == 'always') {
      return 'always applied';
    }

    return _deliveryAppliesWhen;
  }

  String get _logisticsReasonText {
    final reason = _logisticsReason.trim();
    return reason.isEmpty
        ? 'Delivery includes route planning, customer handoff coordination, and possible wait time.'
        : reason;
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '0xFFF57C00';
      case 'in_progress':
      case 'processing':
        return '0xFF1976D2';
      case 'completed':
        return '0xFF388E3C';
      case 'cancelled':
        return '0xFFD32F2F';
      default:
        return '0xFF757575';
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final min  = date.minute.toString().padLeft(2, '0');
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year} \u2022 ${hour.toString().padLeft(2, '0')}:$min $ampm';
    } catch (e) {
      return dateString;
    }
  }

  String _formatServiceType(String serviceType) {
    if (serviceType.isEmpty) return 'Unknown Service';
    
    // Trim and normalize underscores to spaces
    String cleaned = serviceType.replaceAll('_', ' ').trim();
    
    // Check if original contains hyphens
    bool hasHyphens = cleaned.contains('-');
    
    if (hasHyphens) {
      // For hyphenated services like "Wash-Dry-Fold"
      return cleaned
          .split('-')
          .map((part) {
            String trimmed = part.trim();
            if (trimmed.isEmpty) return '';
            return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
          })
          .join('-');
    } else {
      // For space-separated services like "Soft Wash", "Basic Dry Cleaning"
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

  String _orderBarangayLabel(Map<String, dynamic> order) {
    final raw = order['pickup_barangay'];
    final fromApi = raw?.toString().trim() ?? '';
    if (fromApi.isNotEmpty) {
      return fromApi;
    }

    final address = order['pickup_address']?.toString() ?? '';
    if (address.contains(',')) {
      final parts = address.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return parts[parts.length - 2];
      }
    }

    return 'N/A';
  }

  String _orderPickupAddressLabel(Map<String, dynamic> order) {
    final address = (order['pickup_address'] ?? '').toString().trim();
    final barangay = _orderBarangayLabel(order);
    final city = (order['pickup_city'] ?? '').toString().trim();

    if (address.isEmpty) {
      if (barangay != 'N/A' && barangay.isNotEmpty && city.isNotEmpty) {
        return '$barangay, $city';
      }
      return 'N/A';
    }

    return address;
  }

  //  Design-system status helpers 

  Color _statusTextColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return _M.amber;
      case 'in_progress': case 'processing': case 'ongoing': return _M.primary;
      case 'ready': return _M.green;
      case 'completed': return _M.muted;
      default: return _M.red;
    }
  }

  Color _statusBgColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return _M.amberLight;
      case 'in_progress': case 'processing': case 'ongoing': return _M.primaryPale;
      case 'ready': return _M.greenLight;
      case 'completed': return _M.surface;
      default: return _M.redLight;
    }
  }

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'in_progress': case 'processing': case 'ongoing': return 'Ongoing';
      case 'ready': return 'Ready';
      case 'completed': return 'Completed';
      case 'cancelled': case 'declined': return 'Declined';
      default: return _formatStatus(s);
    }
  }

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _statusBgColor(status),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status.toLowerCase() == 'completed')
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text('✓', style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: _M.green)),
          ),
        Text(
          _statusLabel(status),
          style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: _statusTextColor(status)),
        ),
      ],
    ),
  );

  //  Filter logic 

  bool _matchesFilter(Map<String, dynamic> order) {
    if (_activeFilter == 'all') return true;
    final s = (order['status'] ?? '').toString().toLowerCase();
    switch (_activeFilter) {
      case 'pending': return s == 'pending';
      case 'ongoing': return s == 'in_progress' || s == 'processing' || s == 'ongoing';
      case 'ready': return s == 'ready';
      case 'completed': return s == 'completed' || s == 'cancelled';
      default: return true;
    }
  }

  //  Build 

  @override
  Widget build(BuildContext context) {
    final filtered = _orders
        .cast<Map<String, dynamic>>()
        .where(_matchesFilter)
        .toList();

    return Scaffold(
      backgroundColor: _M.surface,
      body: Column(
        children: [
          _buildAppBar(),
          _buildFilterChips(),
          Expanded(child: _buildBody(filtered)),
        ],
      ),
    );
  }

  //  App bar 

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _M.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text('My Orders',
                    style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _M.navy)),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded,
                  size: 22, color: _M.slate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Filter chips 

  Widget _buildFilterChips() {
    const filters = ['All', 'Pending', 'Ongoing', 'Ready', 'Completed'];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: filters.map((label) {
            final key = label.toLowerCase();
            final isActive = _activeFilter == key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? _M.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? null
                        : Border.all(color: _M.border, width: 1.5),
                  ),
                  child: Text(label,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5, fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : _M.muted)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  //  Body 

  Widget _buildBody(List<Map<String, dynamic>> filtered) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _M.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _loadOrders,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _M.primary,
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Retry', style: GoogleFonts.dmSans(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: _M.primaryPale, shape: BoxShape.circle),
                child: const Icon(Icons.shopping_bag_outlined,
                  size: 64, color: _M.primary),
              ),
              const SizedBox(height: 24),
              Text('No orders yet', style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w700, color: _M.navy)),
              const SizedBox(height: 8),
              Text('Place your first laundry order to get started!',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 14, color: _M.muted)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: _M.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _buildOrderCard(filtered[i]),
      ),
    );
  }

  //  Order card 

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'pending').toString().toLowerCase();
    final serviceType = order['service_type'] ?? '';
    final orderId = '#LH-${(order['id'] ?? 0).toString().padLeft(4, '0')}';
    final svcName = _formatServiceType(serviceType);
    // Get icon from service name
    final icon = ServiceService.getServiceIcon(serviceType);
    final isActive = status == 'ongoing' || status == 'pending' ||
        status == 'ready' || status == 'in_progress' || status == 'processing';
    final isCompleted = status == 'completed' || status == 'cancelled';

    // Step progress
    const steps = ['Received', 'Washing', 'Drying', 'Ready'];
    final activeIdx = status == 'pending' ? 0
        : (status == 'in_progress' || status == 'processing' || status == 'ongoing') ? 1
        : status == 'ready' ? 3
        : status == 'completed' ? 4
        : 0;

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _M.border, width: 1.5),
          boxShadow: [BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Icon(icon, size: 28, color: _M.primary),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(orderId, style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: _M.primary)),
                        const SizedBox(width: 4),
                        Text('\u00B7 $svcName', style: GoogleFonts.dmSans(
                          fontSize: 12, color: _M.slate)),
                      ],
                    ),
                  ),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 8),

              // Info row
              Row(
                children: [
                  _infoItem(Icons.calendar_today_outlined,
                    order['delivery_type'] == 'delivery' 
                      ? _fmtShortDate(order['delivery_date'])
                      : _fmtShortDate(order['pickup_date'])),
                  const SizedBox(width: 16),
                  _infoItem(Icons.scale_outlined,
                    '${order['weight_kg'] ?? ''} kg'),
                  const SizedBox(width: 16),
                  _infoItem(
                    order['delivery_type'] == 'delivery'
                        ? Icons.directions_walk_outlined
                        : Icons.two_wheeler_outlined,
                    order['delivery_type'] == 'delivery' ? 'Drop-off' : 'Pickup'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _infoItem(
                      Icons.map_outlined,
                      _orderBarangayLabel(order),
                    ),
                  ),
                ],
              ),

              // Active order progress
              if (isActive) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: _M.border),
                const SizedBox(height: 12),
                Text('Order Progress', style: GoogleFonts.dmSans(
                  fontSize: 10.5, fontWeight: FontWeight.w700, color: _M.muted)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(steps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final stepIdx = i ~/ 2;
                      final isDone = stepIdx < activeIdx;
                      return Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? _M.green : _M.border,
                        ),
                      );
                    }
                    final idx = i ~/ 2;
                    final isActiveDot = idx == activeIdx;
                    final isDoneDot = idx < activeIdx;
                    return Column(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: isDoneDot ? _M.green
                                : isActiveDot ? _M.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDoneDot ? _M.green
                                  : isActiveDot ? _M.primary
                                  : _M.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(steps[idx], style: GoogleFonts.dmSans(
                          fontSize: 8,
                          color: isActiveDot ? _M.primary : _M.muted)),
                      ],
                    );
                  }),
                ),
              ],

              // Completed footer
              if (isCompleted) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: _M.border),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['total_price'] != null
                          ? 'Total: \u20B1${double.tryParse(order['total_price'].toString())?.toStringAsFixed(2) ?? ''}'
                          : 'Total: ',
                      style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: _M.navy)),
                    if (status == 'completed')
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                            size: 13, color: _M.green),
                          const SizedBox(width: 4),
                          Text('Completed', style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: _M.green)),
                        ],
                      )
                    else
                      Text('Cancelled', style: GoogleFonts.dmSans(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _M.red)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: _M.muted),
      const SizedBox(width: 4),
      Text(text, style: GoogleFonts.dmSans(fontSize: 11, color: _M.slate)),
    ],
  );

  String _fmtShortDate(dynamic d) {
    if (d == null) return 'N/A';
    try {
      final dt = DateTime.parse(d.toString());
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) { return d.toString(); }
  }

  //  Order details bottom sheet 

  Future<void> _showOrderDetails(Map<String, dynamic> order) async {
    final deliveryType =
      (order['delivery_type'] ?? 'pickup').toString().toLowerCase();
    final isDropOff = deliveryType == 'delivery';
    final pickupFee =
      double.tryParse((order['pickup_fee'] ?? 0).toString()) ?? 0.0;
    final deliveryFee =
      double.tryParse((order['delivery_fee'] ?? 0).toString()) ?? 0.0;
    final totalPrice =
      double.tryParse((order['total_price'] ?? 0).toString()) ?? 0.0;
    final feeZone = (order['fee_zone'] ?? 'N/A').toString();
    final addOnTotal =
      double.tryParse((order['add_on_total'] ?? 0).toString()) ?? 0.0;

    final rawAddOns = order['add_ons'];
    final addOns = rawAddOns is List
        ? rawAddOns
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList()
        : <Map<String, dynamic>>[];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Header with emoji
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ServiceService.getServiceIcon(order['service_type'] ?? ''),
                      size: 28,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B4B),
                          ),
                        ),
                        Text(
                          'Order #${order['id']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          ServiceService.getServiceIcon(order['service_type'] ?? ''),
                          size: 22,
                          color: _M.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatServiceType(order['service_type'] ?? ''),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Status',
                      _formatStatus(order['status'] ?? ''),
                      Icons.info_outline,
                      valueColor: Color(int.parse(_getStatusColor(order['status'] ?? ''))),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Pickup Address',
                      _orderPickupAddressLabel(order),
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Barangay',
                      _orderBarangayLabel(order),
                      Icons.map_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Pickup Date',
                      _formatDate(order['pickup_date']),
                      Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Delivery Date',
                      _formatDate(order['delivery_date']),
                      Icons.local_shipping_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Logistics Zone',
                      feeZone,
                      Icons.map_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Pickup Fee',
                      isDropOff
                          ? '₱ 0.00 (Drop-off selected)'
                          : '₱ ${pickupFee.toStringAsFixed(2)}',
                      Icons.two_wheeler_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Delivery Fee',
                      '₱ ${deliveryFee.toStringAsFixed(2)}',
                      Icons.local_shipping_outlined,
                    ),
                    const SizedBox(height: 16),
                    if (addOns.isNotEmpty) ...[
                      _buildDetailRow(
                        'Add-ons Total',
                        '₱ ${addOnTotal.toStringAsFixed(2)}',
                        Icons.add_circle_outline,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _M.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _M.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected add-ons',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _M.navy,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...addOns.map((addOn) {
                              final name =
                                  (addOn['name'] ?? 'Add-on').toString();
                              final fee = double.tryParse(
                                      (addOn['fee'] ?? 0).toString()) ??
                                  0.0;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: _M.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _M.slate,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₱ ${fee.toStringAsFixed(2)}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _M.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDetailRow(
                      'Total Price',
                      '₱ ${totalPrice.toStringAsFixed(2)}',
                      Icons.receipt_long_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Payment Method',
                      'Cash on Delivery (COD)',
                      Icons.payments_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildLogisticsExplanationCard(),
                    if (order['special_instructions'] != null &&
                        order['special_instructions'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Special Instructions',
                        order['special_instructions'],
                        Icons.note_outlined,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF0D1B4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsExplanationCard() {
    final title = _deliveryCanBeHigher
        ? 'Why delivery may cost more'
        : 'Logistics fee details';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _M.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _M.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _M.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _logisticsReasonText,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _M.slate,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pickup fee: $_pickupFeeRuleLabel',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: _M.slate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Delivery fee: $_deliveryFeeRuleLabel',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: _M.slate,
            ),
          ),
        ],
      ),
    );
  }
}
