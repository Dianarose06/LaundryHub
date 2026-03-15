import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';

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

class _MyOrdersScreenState extends State<MyOrdersScreen> {
    // Emoji mapping for service types (match home_screen.dart)
    String _getServiceEmoji(String serviceType) {
      switch (serviceType.toLowerCase()) {
        case 'wash-dry-fold':
        case 'wash–dry–fold':
          return '\u{1F9FA}';
        case 'dry_clean':
        case 'dry clean':
          return '\u2728';
        case 'beddings':
        case 'beddings & linens':
          return '\u{1F6CF}';
        case 'express wash':
          return '\u26A1';
        case 'soft wash':
          return '\u{1F338}';
        default:
          return '\u{1F9FA}';
      }
    }
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await OrderService.getOrders();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _orders = result['data'] as List<dynamic>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] as String?;
        _isLoading = false;
      });
    }
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
    return serviceType
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' & ');
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
              Text(_errorMessage!, textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16, color: Colors.grey.shade600)),
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
    // Get emoji from API response, fallback to local mapping if not present
    final emoji = (order['service_emoji'] ?? _getServiceEmoji(serviceType)).toString();
    final isActive = status == 'ongoing' || status == 'pending' ||
        status == 'ready' || status == 'in_progress' || status == 'processing';
    final isCompleted = status == 'completed' || status == 'cancelled';

    // Step progress
    const steps = ['Received', 'Washing', 'Drying', 'Ready'];
    final activeIdx = status == 'pending' ? 0
        : (status == 'in_progress' || status == 'processing' || status == 'ongoing') ? 1
        : status == 'ready' ? 3 : 0;

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _M.border, width: 1.5),
          boxShadow: [BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with emoji
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
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
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getServiceEmoji(order['service_type'] ?? ''),
                      style: const TextStyle(fontSize: 28),
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
                        Text(
                          _getServiceEmoji(order['service_type'] ?? ''),
                          style: const TextStyle(fontSize: 22),
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
                      order['pickup_address'] ?? 'N/A',
                      Icons.location_on_outlined,
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
}
