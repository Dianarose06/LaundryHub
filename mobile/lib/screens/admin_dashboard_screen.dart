import 'package:flutter/material.dart';
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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const _navy      = Color(0xFF0F172A);
  static const _primary   = Color(0xFF2563EB);
  static const _surface   = Color(0xFFF8FAFC);
  static const _muted     = Color(0xFF475569);
  static const _border    = Color(0xFFE2E8F0);


  bool _isLoading = true;
  int _totalBookings = 0;
  int _pendingCount = 0;
  double _revenueToday = 0;
  int _customerCount = 0;
  List<_BookingRow> _recentBookings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      AdminService.fetchStats(),
      AdminService.fetchRecentOrders(),
    ]);

    if (!mounted) return;

    final statsRes  = results[0];
    final ordersRes = results[1];

    // Parse stats
    int totalBookings = 0;
    int pendingCount  = 0;
    double revenueToday = 0;
    int customerCount = 0;
    if (statsRes['success'] == true) {
      final s    = statsRes['data'] as Map<String, dynamic>;
      totalBookings = int.tryParse(s['total_bookings']?.toString() ?? '0') ?? 0;
      pendingCount  = int.tryParse(s['pending_count']?.toString()  ?? '0') ?? 0;
      revenueToday  = double.tryParse(s['revenue_today']?.toString() ?? '0') ?? 0;
      customerCount = int.tryParse(s['customer_count']?.toString() ?? '0') ?? 0;
    }

    // Parse recent orders outside setState to avoid silent failures
    List<_BookingRow> bookings = [];
    if (ordersRes['success'] == true) {
      final list = ordersRes['data'] as List<dynamic>;
      for (final e in list) {
        try {
          final m = e as Map<String, dynamic>;
          bookings.add(_BookingRow(
            orderId:  (m['order_id'] as num).toInt(),
            id:       m['id']       as String,
            customer: m['customer'] as String,
            service:  m['service']  as String,
            status:   m['status']   as String,
            amount:   m['amount']   as String,
          ));
        } catch (_) {
          // Skip malformed row
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _totalBookings  = totalBookings;
      _pendingCount   = pendingCount;
      _revenueToday   = revenueToday;
      _customerCount  = customerCount;
      _recentBookings = bookings;
      _isLoading      = false;
    });
  }

  String _formatRevenue(double amount) {
    if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₱${amount.toStringAsFixed(0)}';
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
                  const SizedBox(height: 24),
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
              const SizedBox(height: 20),
              // Stat chips row (same style as customer dash)
              Row(
                children: [
                  _statChip(_isLoading ? '--' : _totalBookings.toString(), 'Bookings'),
                  const SizedBox(width: 10),
                  _statChip(_isLoading ? '--' : _pendingCount.toString(), 'Pending'),
                  const SizedBox(width: 10),
                  _statChip(_isLoading ? '--' : _formatRevenue(_revenueToday), 'Revenue'),
                ],
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

  Widget _statChip(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.outfit(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.dmSans(
            color: Colors.white.withValues(alpha: 0.85), fontSize: 9.5)),
        ],
      ),
    ),
  );

  // ── KPI grid (now in scrollable body) ────────────────────────────────────────
  Widget _buildKpiGrid() {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final kpis = [
      _KpiData(emoji: '👥', value: _customerCount.toString(),     label: 'Customers',
          trend: 'Total registered',    trendPositive: true),
      _KpiData(emoji: '📦', value: _totalBookings.toString(),     label: 'Total Bookings',
          trend: 'All time',            trendPositive: true),
      _KpiData(emoji: '⏳', value: _pendingCount.toString(),      label: 'Pending',
          trend: 'Needs attention',     trendPositive: true),
      _KpiData(emoji: '💰', value: _formatRevenue(_revenueToday), label: 'Revenue Today',
          trend: "Today's earnings",    trendPositive: true),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: kpis.map((k) => _KpiCard(data: k)).toList(),
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
              if (_isLoading) ...[const Padding(
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
              ] else ..._recentBookings.asMap().entries.map((entry) {
                final i = entry.key;
                final b = entry.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(height: 1, color: _border),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              b.id,
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
                              b.customer,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: _navy),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              b.service,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: _muted),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _StatusBadge(status: b.status),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              b.amount,
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
                    ),
                  ],
                );
              }),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 28)),
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
              const SizedBox(height: 2),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
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

// ── Status badge ───────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (status) {
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
      default: // Completed / fallback
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
        status,
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
