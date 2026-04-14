import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/service_service.dart';
import 'login_screen.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class _C {
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

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic>? _user;
  List<dynamic> _orders = [];
  bool _ordersLoading = true;
  List<dynamic> _services = [];
  bool _servicesLoading = true;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
    _loadOrders();
    _loadServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastLifecycleState = state;
    // Refresh orders when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - refreshing customer orders');
      _loadOrders();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when widget updates (e.g., when coming back to this tab)
    _loadOrders();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _loadOrders() async {
    setState(() => _ordersLoading = true);
    final result = await OrderService.getOrders();
    if (!mounted) return;
    setState(() {
      _orders = result['success'] == true ? result['data'] as List<dynamic> : [];
      _ordersLoading = false;
    });
  }

  Future<void> _loadServices() async {
    setState(() => _servicesLoading = true);
    final result = await ServiceService.getServices();
    if (!mounted) return;
    setState(() {
      _services = result['success'] == true ? result['data'] as List<dynamic> : [];
      _servicesLoading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: _C.primary),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _logout();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Map<String, dynamic>? get _activeOrder {
    for (final o in _orders) {
      final m = o as Map<String, dynamic>;
      final s = (m['status'] ?? '').toString().toLowerCase();
      if (s == 'pending' || s == 'ongoing' || s == 'ready' ||
          s == 'in_progress' || s == 'processing') return m;
    }
    return null;
  }

  List<Map<String, dynamic>> get _recentOrders => _orders
      .cast<Map<String, dynamic>>()
      .where((o) {
        final s = (o['status'] ?? '').toString().toLowerCase();
        return s == 'completed' || s == 'cancelled';
      })
      .take(3)
      .toList();

  Color _statusTextColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return _C.amber;
      case 'in_progress': case 'ongoing': case 'processing': return _C.primary;
      case 'ready': return _C.green;
      case 'completed': return _C.muted;
      default: return _C.red;
    }
  }

  Color _statusBgColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return _C.amberLight;
      case 'in_progress': case 'ongoing': case 'processing': return _C.primaryPale;
      case 'ready': return _C.greenLight;
      case 'completed': return _C.surface;
      default: return _C.redLight;
    }
  }

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'in_progress': case 'ongoing': case 'processing': return 'Ongoing';
      case 'ready': return 'Ready';
      case 'completed': return 'Completed';
      case 'cancelled': case 'declined': return 'Declined';
      default: return s;
    }
  }

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _statusBgColor(status),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _statusLabel(status),
      style: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: _statusTextColor(status),
      ),
    ),
  );

  double _orderProgress(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return 0.15;
      case 'in_progress': case 'ongoing': case 'processing': return 0.50;
      case 'ready': return 0.85;
      default: return 0.15;
    }
  }

  String _fmtServiceName(String s) => s;

  // Removed - using ServiceService.getServiceIcon() instead
  @deprecated
  String _serviceEmoji(String t) => '';

  String _fmtOrderDate(String? d) {
    if (d == null) return 'N/A';
    try {
      final dt = DateTime.parse(d);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) { return d; }
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: GoogleFonts.outfit(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: _C.navy, letterSpacing: -0.3)),
      GestureDetector(
        onTap: onTap,
        child: Text(action, style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.primary)),
      ),
    ],
  );

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final name = _user?['name'] as String? ?? 'User';
    final active = _activeOrder;
    final recent = _recentOrders;
    final totalOrders = _orders.length;
    final activeCount = _orders.where((o) {
      final s = (o as Map)['status']?.toString().toLowerCase() ?? '';
      return ['pending','in_progress','ongoing','processing','ready'].contains(s);
    }).length;
    final spent = _orders.cast<Map<String, dynamic>>().fold<double>(0.0, (sum, o) {
      if ((o['status'] ?? '').toString().toLowerCase() != 'completed') return sum;
      return sum + (double.tryParse(o['total_price']?.toString() ?? '0') ?? 0.0);
    });

    return Scaffold(
      backgroundColor: _C.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUser();
          await _loadOrders();
          await _loadServices();
        },
        color: _C.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(name, totalOrders, activeCount, spent),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildServicesGrid(),
                  if (active != null) ...[
                    const SizedBox(height: 24),
                    _buildActiveOrderCard(active),
                  ],
                  const SizedBox(height: 24),
                  _buildRecentOrdersList(recent),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader(String name, int total, int activeCount, double spent) {
    return Container(
      width: double.infinity,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(),
                        style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                      Text(name,
                        style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    ],
                  ),
                  Row(
                    children: [
                      _headerBtn(Icons.notifications_outlined,
                        onTap: () => widget.onNavigateToTab?.call(3)),
                      const SizedBox(width: 8),
                      _headerBtn(Icons.logout_rounded, onTap: _confirmLogout),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _statChip('$total', 'Total Orders'),
                  const SizedBox(width: 10),
                  _statChip('$activeCount', 'Active'),
                  const SizedBox(width: 10),
                  _statChip('₱${spent.toStringAsFixed(0)}', 'Spent'),
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
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _statChip(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.outfit(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.dmSans(
            color: Colors.white60, fontSize: 9.5)),
        ],
      ),
    ),
  );

  // ── Services Grid ─────────────────────────────────────────────────────────────

  Widget _buildServicesGrid() => Column(
    children: [
      _sectionHeader('Our Services', 'See all →',
        () => widget.onNavigateToTab?.call(2)),
      const SizedBox(height: 14),
      _servicesLoading
          ? SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: _C.primary),
              ),
            )
          : _services.isEmpty
              ? SizedBox(
                  height: 120,
                  child: Center(
                    child: Text('No services available',
                      style: GoogleFonts.dmSans(color: _C.muted, fontSize: 12)),
                  ),
                )
              : GridView.builder(
                  key: ValueKey('services_${_services.length}'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _services.isEmpty ? 0 : (_services.length > 3 ? 3 : _services.length),
                  itemBuilder: (ctx, i) {
                    final svc = _services[i] as Map<String, dynamic>;
                    final name = svc['name'] as String? ?? '';
                    final icon = ServiceService.getServiceIcon(name);
                    final formattedName = ServiceService.formatServiceName(name);
                    
                    return GestureDetector(
                      onTap: () => widget.onNavigateToTab?.call(2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _C.border, width: 1.5),
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.05),
                            blurRadius: 12, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(icon, size: 40, color: _C.primary),
                            const SizedBox(height: 12),
                            Text(formattedName, textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 12, fontWeight: FontWeight.w600, color: _C.slate)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    ],
  );

  // ── Active Order Card ─────────────────────────────────────────────────────────

  Widget _buildActiveOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'pending').toString().toLowerCase();
    final orderId = '#LH-${(order['id'] ?? 0).toString().padLeft(4, '0')}';
    final svcName = _fmtServiceName(order['service_type'] ?? '');
    final progress = _orderProgress(status);
    const steps = ['Received', 'Washing', 'Drying', 'Ready'];
    final activeIdx = status == 'pending' ? 0
        : (status == 'in_progress' || status == 'ongoing' || status == 'processing') ? 1
        : status == 'ready' ? 3 : 0;

    return Column(
      children: [
        _sectionHeader('Active Order', 'Track →',
          () => widget.onNavigateToTab?.call(1)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.primary, width: 1.5),
            boxShadow: [BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.30),
              blurRadius: 18, offset: const Offset(0, 6))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(orderId, style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w800, color: _C.primary)),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 6),
              Text('$svcName · ${order['weight_kg'] ?? '–'} kg',
                style: GoogleFonts.dmSans(fontSize: 12, color: _C.slate)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress, minHeight: 6,
                  backgroundColor: _C.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(_C.primary),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: steps.asMap().entries.map((e) {
                  final isActive = e.key == activeIdx;
                  final isDone = e.key < activeIdx;
                  return Text(e.value, style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: (isActive || isDone) ? FontWeight.w700 : FontWeight.w400,
                    color: isDone ? _C.green : isActive ? _C.primary : _C.muted,
                  ));
                }).toList(),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _C.primaryPale, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_outlined, size: 14, color: _C.primary),
                    const SizedBox(width: 6),
                    Text('Ready for pickup in approx. ',
                      style: GoogleFonts.dmSans(fontSize: 10.5, color: _C.slate)),
                    Text('1 hour', style: GoogleFonts.dmSans(
                      fontSize: 10.5, fontWeight: FontWeight.w700, color: _C.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Recent Orders List ────────────────────────────────────────────────────────

  Widget _buildRecentOrdersList(List<Map<String, dynamic>> orders) => Column(
    children: [
      _sectionHeader('Recent Orders', 'View all →',
        () => widget.onNavigateToTab?.call(1)),
      const SizedBox(height: 14),
      if (_ordersLoading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: _C.primary)))
      else if (orders.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border, width: 1.5)),
          child: Center(child: Text('No recent orders yet',
            style: GoogleFonts.dmSans(color: _C.muted, fontSize: 13))))
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (_, i) => _buildRecentOrderTile(orders[i]),
        ),
    ],
  );

  Widget _buildRecentOrderTile(Map<String, dynamic> order) {
    final status = (order['status'] ?? '').toString().toLowerCase();
    final emoji  = _serviceEmoji(order['service_type'] ?? '');
    final id     = '#LH-${(order['id'] ?? 0).toString().padLeft(4, '0')}';
    final name   = _fmtServiceName(order['service_type'] ?? '');
    final date   = _fmtOrderDate(order['pickup_date'] ?? order['created_at']);
    final total  = order['total_price'] != null
        ? '₱${double.tryParse(order['total_price'].toString())?.toStringAsFixed(0) ?? '–'}'
        : '–';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border, width: 1.5),
        boxShadow: [BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.05),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _C.primaryPale, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _C.navy)),
                  const SizedBox(height: 2),
                  Text('$id · $date',
                    style: GoogleFonts.dmSans(fontSize: 10.5, color: _C.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusBadge(status),
                const SizedBox(height: 4),
                Text(total, style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w800, color: _C.navy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
