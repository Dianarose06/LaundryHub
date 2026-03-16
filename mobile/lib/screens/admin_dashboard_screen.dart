import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onViewAllBookings;
  const AdminDashboardScreen({super.key, this.onViewAllBookings});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with WidgetsBindingObserver {
  static const _navy      = Color(0xFF0F172A);
  static const _primary   = Color(0xFF2563EB);
  static const _surface   = Color(0xFFF8FAFC);
  static const _muted     = Color(0xFF475569);
  static const _border    = Color(0xFFE2E8F0);


  bool _isStatsLoading = true;
  bool _isRecentLoading = true;
  int _totalBookings = 0;
  int _pendingCount = 0;
  double _revenueToday = 0;
  int _customerCount = 0;
  List<_BookingRow> _recentBookings = [];
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAndLoadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastLifecycleState = state;
    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - refreshing dashboard data');
      _loadData();
    }
  }

  Future<void> _initializeAndLoadData() async {
    // Load persistent cache first for instant display
    await AdminService.loadPersistentCache();
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isStatsLoading = true;
      _isRecentLoading = true;
    });

    // Wait for both to complete in parallel
    await Future.wait([
      _loadStats(),
      _loadRecentOrders(),
    ]).catchError((e) {
      debugPrint('Error waiting for data to load: $e');
    });
  }

  Future<void> _loadStats() async {
    try {
      final statsRes = await AdminService.fetchStats();
      if (!mounted) return;

      debugPrint('🔍 Stats Response Full: $statsRes');

      int totalBookings = 0;
      int pendingCount  = 0;
      double revenueToday = 0;
      int customerCount = 0;

      if (statsRes['success'] == true) {
        final s = statsRes['data'] as Map<String, dynamic>?;
        debugPrint('📊 Stats Data: $s');
        debugPrint('📊 Stats Keys: ${s?.keys.toList()}');
        
        if (s != null) {
          // Log raw values
          debugPrint('📊 total_bookings (raw): ${s['total_bookings']} (type: ${s['total_bookings'].runtimeType})');
          debugPrint('📊 pending_count (raw): ${s['pending_count']} (type: ${s['pending_count'].runtimeType})');
          debugPrint('📊 revenue_today (raw): ${s['revenue_today']} (type: ${s['revenue_today'].runtimeType})');
          debugPrint('📊 customer_count (raw): ${s['customer_count']} (type: ${s['customer_count'].runtimeType})');
          
          // Parse with better handling for num/int/string types
          if (s['total_bookings'] != null) {
            totalBookings = (s['total_bookings'] is num) 
              ? (s['total_bookings'] as num).toInt()
              : int.tryParse(s['total_bookings'].toString()) ?? 0;
          }
          
          if (s['pending_count'] != null) {
            pendingCount = (s['pending_count'] is num)
              ? (s['pending_count'] as num).toInt()
              : int.tryParse(s['pending_count'].toString()) ?? 0;
          }
          
          if (s['revenue_today'] != null) {
            revenueToday = (s['revenue_today'] is num)
              ? (s['revenue_today'] as num).toDouble()
              : double.tryParse(s['revenue_today'].toString()) ?? 0.0;
          }
          
          if (s['customer_count'] != null) {
            customerCount = (s['customer_count'] is num)
              ? (s['customer_count'] as num).toInt()
              : int.tryParse(s['customer_count'].toString()) ?? 0;
          }
        }
        
        debugPrint('✅ Parsed - Bookings: $totalBookings, Pending: $pendingCount, Revenue Today: ₱${revenueToday.toStringAsFixed(2)}, Customers: $customerCount');
        debugPrint('💰 Revenue Today Calculation: Raw=$revenueToday → Formatted=${_formatRevenue(revenueToday)}');
      } else {
        debugPrint('❌ Stats fetch failed: ${statsRes['message']}');
      }

      setState(() {
        _totalBookings = totalBookings;
        _pendingCount = pendingCount;
        _revenueToday = revenueToday;
        _customerCount = customerCount;
        _isStatsLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading stats: $e');
      debugPrint('Stack: $stackTrace');
      if (!mounted) return;
      setState(() => _isStatsLoading = false);
    }
  }

  Future<void> _loadRecentOrders() async {
    try {
      final ordersRes = await AdminService.fetchRecentOrders();
      if (!mounted) return;

      debugPrint('Recent Orders Response: $ordersRes');

      final bookings = <_BookingRow>[];
      if (ordersRes['success'] == true && ordersRes['data'] != null) {
        final list = ordersRes['data'] as List<dynamic>;
        debugPrint('Recent Orders Count: ${list.length}');
        
        bookings.addAll(list.map((e) {
          final m = e as Map<String, dynamic>? ?? {};
          debugPrint('Order item keys: ${m.keys.toList()}');
          
          // Safe parsing with multiple fallback keys
          final orderId = int.tryParse(
            (m['order_id'] ?? m['id'] ?? '0').toString()
          ) ?? 0;
          
          final id = (m['id']?.toString() ?? m['order_id']?.toString() ?? '#$orderId').trim();
          
          final customer = (m['customer']?.toString() ?? 
                           m['customer_name']?.toString() ?? 
                           m['user_name']?.toString() ?? 
                           'Unknown').trim();
          
          final service = (m['service']?.toString() ?? 
                          m['service_type']?.toString() ?? 
                          m['service_name']?.toString() ?? 
                          'Unknown Service').trim();
          
          final status = (m['status']?.toString() ?? 
                         m['order_status']?.toString() ?? 
                         'Pending').trim();
          
          final amount = (m['amount']?.toString() ?? 
                         m['total_price']?.toString() ?? 
                         m['price']?.toString() ?? 
                         '0').trim();
          
          debugPrint('Parsed Order: id=$id, customer=$customer, service=$service, status=$status, amount=$amount');
          
          return _BookingRow(
            orderId: orderId,
            id: id,
            customer: customer,
            service: service,
            status: status,
            amount: amount,
          );
        }));
      } else {
        debugPrint('Recent orders fetch failed: success=${ordersRes['success']}, data=${ordersRes['data']}');
      }

      setState(() {
        _recentBookings = bookings;
        _isRecentLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading recent orders: $e');
      if (!mounted) return;
      setState(() => _isRecentLoading = false);
    }
  }

  String _formatRevenue(double amount) {
    if (amount >= 1000) {
      final formatted = '₱${(amount / 1000).toStringAsFixed(1)}K';
      debugPrint('📊 Format ₱${amount.toStringAsFixed(2)} → $formatted');
      return formatted;
    }
    final formatted = '₱${amount.toStringAsFixed(0)}';
    debugPrint('📊 Format ₱${amount.toStringAsFixed(2)} → $formatted');
    return formatted;
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _primary),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildGradientHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildKpiGrid(),
                  _buildRecentBookings(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Compact dark gradient header (matches customer dash size) ─────────────────
  Widget _buildGradientHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: pill + icon buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "ADMIN PANEL" pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: Text(
                      'ADMIN PANEL',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  // Notif + logout buttons
                  Row(
                    children: [
                      _headerBtn(Icons.notifications_outlined, onTap: () {}),
                      const SizedBox(width: 8),
                      _headerBtn(Icons.logout_rounded, onTap: _confirmLogout),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Dashboard',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Overview for today',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBtn(IconData icon, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  // ── Simple stat chips in header ────────────────────────────────────────────
  Widget _buildHeaderStats() {
    if (_isStatsLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            value: _totalBookings.toString(),
            label: 'Bookings',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            value: _pendingCount.toString(),
            label: 'Pending',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            value: _formatRevenue(_revenueToday),
            label: 'Revenue',
          ),
        ),
      ],
    );
  }

  // ── KPI grid (in scrollable body) ──────────────────────────────────────────
  Widget _buildKpiGrid() {
    if (_isStatsLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final kpis = [
      _KpiData(
        emoji: '👥',
        value: _customerCount.toString(),
        label: 'Customers',
        trend: 'Total registered',
        trendPositive: true,
      ),
      _KpiData(
        emoji: '📦',
        value: _totalBookings.toString(),
        label: 'Total Bookings',
        trend: 'All time',
        trendPositive: true,
      ),
      _KpiData(
        emoji: '⏳',
        value: _pendingCount.toString(),
        label: 'Pending',
        trend: 'Needs attention',
        trendPositive: true,
      ),
      _KpiData(
        emoji: '💰',
        value: _formatRevenue(_revenueToday),
        label: 'Revenue Today',
        trend: "Today's earnings",
        trendPositive: true,
      ),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: kpis.map((k) => _KpiCard(data: k)).toList(),
      ),
    );
  }

  // ── Recent Bookings table ────────────────────────────────────────────────────
  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bookings',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            GestureDetector(
              onTap: widget.onViewAllBookings,
              child: Text(
                'View all →',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _headerCell('Order ID')),
                    Expanded(flex: 3, child: _headerCell('Customer')),
                    Expanded(flex: 3, child: _headerCell('Service')),
                    Expanded(flex: 3, child: _headerCell('Status')),
                    Expanded(
                        flex: 2,
                        child: _headerCell('Amount',
                            align: TextAlign.right)),
                  ],
                ),
              ),
              // Data rows
              if (_isRecentLoading) ...[const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ] else if (_recentBookings.isEmpty) ...[const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('No bookings yet',
                        style: TextStyle(color: Color(0xFF475569), fontSize: 13)),
                  ),
                ),
              ] else ...<Widget>[
                for (int i = 0; i < _recentBookings.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: _border),
                  _BookingRowWidget(booking: _recentBookings[i]),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _muted,
      ),
      textAlign: align,
    );
  }
}

// ── Stat chip (simple header stats) ────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── KPI card ───────────────────────────────────────────────────────────────────
class _KpiData {
  final String emoji;
  final String value;
  final String label;
  final String trend;
  final bool trendPositive;
  const _KpiData({
    required this.emoji,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendPositive,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  static const _green = Color(0xFF34D399);
  static const _gray  = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                data.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.trend,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: data.trendPositive ? _green : _gray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Booking row widget ─────────────────────────────────────────────────────────
class _BookingRowWidget extends StatelessWidget {
  final _BookingRow booking;

  const _BookingRowWidget({required this.booking});

  static const _navy = Color(0xFF0F172A);
  static const _primary = Color(0xFF2563EB);
  static const _muted = Color(0xFF475569);

  String _formatAmount() {
    try {
      // Remove any currency symbols first
      String cleanAmount = booking.amount.replaceAll(RegExp(r'[₱\s]'), '');
      final value = double.parse(cleanAmount);
      return '₱${value.toStringAsFixed(2)}';
    } catch (_) {
      // If already formatted or invalid, return as-is with peso sign if not present
      if (booking.amount.isEmpty || booking.amount == '0' || booking.amount == '--') {
        return '₱0.00';
      }
      return booking.amount.contains('₱') ? booking.amount : '₱${booking.amount}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              booking.id.isNotEmpty ? booking.id : '--',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              booking.customer.isNotEmpty ? booking.customer : 'N/A',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(fontSize: 12, color: _navy),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              booking.service.isNotEmpty ? booking.service : 'N/A',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(fontSize: 12, color: _muted),
            ),
          ),
          Expanded(
            flex: 3,
            child: _StatusBadge(status: booking.status.isNotEmpty ? booking.status : 'Unknown'),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _navy,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  String _normalizeStatus(String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized.contains('pending')) return 'Pending';
    if (normalized.contains('progress') || normalized.contains('ongoing') || normalized.contains('processing')) return 'Ongoing';
    if (normalized.contains('ready') || normalized.contains('completed') && normalized.contains('ready')) return 'Ready';
    if (normalized.contains('complete')) return 'Completed';
    if (normalized.contains('cancel')) return 'Cancelled';
    return status.isNotEmpty ? status : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = _normalizeStatus(status);
    
    final Color bg;
    final Color fg;
    switch (normalizedStatus) {
      case 'Pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'Ongoing':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'Ready':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case 'Completed':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case 'Cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        normalizedStatus,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────────────────────
class _BookingRow {
  final int orderId;
  final String id;
  final String customer;
  final String service;
  final String status;
  final String amount;
  const _BookingRow({
    required this.orderId,
    required this.id,
    required this.customer,
    required this.service,
    required this.status,
    required this.amount,
  });
}
