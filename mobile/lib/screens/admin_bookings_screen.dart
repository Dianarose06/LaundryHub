import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  static const _primary  = Color(0xFF2563EB);
  static const _navy     = Color(0xFF0F172A);
  static const _surface  = Color(0xFFF8FAFC);
  static const _muted    = Color(0xFF94A3B8);
  static const _border   = Color(0xFFE2E8F0);

  int _filterIndex = 0;
  bool _isLoading = true;
  List<_AdminBooking> _allBookings = [];
  // local step UI state: orderId → step index (0=Washing,1=Drying,2=Ready,3=Done)
  final Map<int, int> _stepState = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Maps a DB status string to the corresponding chip step index.
  int _statusToStep(String status) {
    switch (status) {
      case 'Ready':     return 2;
      case 'Completed': return 3;
      default:          return 0; // Pending or Ongoing
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final result = await AdminService.fetchAllOrders();
    if (!mounted) return;
    if (result['success'] == true) {
      final list = result['data'] as List<dynamic>;
      final bookings = list.map((e) {
        final m = e as Map<String, dynamic>;
        return _AdminBooking(
          orderId:    (m['order_id'] as num).toInt(),
          id:         m['id'] as String,
          customer:   m['customer'] as String,
          service:    m['service'] as String,
          date:       m['date'] as String,
          cost:       m['cost'] as String,
          status:     m['status'] as String,
          statusStep: 0,
        );
      }).toList();
      setState(() {
        _allBookings = bookings;
        // Only initialise step from DB for orders not already being tracked
        // (preserves local Washing→Drying chip selection)
        for (final b in bookings) {
          if (!_stepState.containsKey(b.orderId)) {
            _stepState[b.orderId] = _statusToStep(b.status);
          }
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<int> get _filteredIndices {
    if (_filterIndex == 0) {
      return List.generate(_allBookings.length, (i) => i);
    }
    final filter = _filterLabels[_filterIndex];
    return [
      for (int i = 0; i < _allBookings.length; i++)
        if (_allBookings[i].status == filter) i
    ];
  }

  List<String> get _filterLabels => ['All', 'Pending', 'Ongoing', 'Ready', 'Completed', 'Cancelled'];

  int _countForFilter(int fi) {
    if (fi == 0) return _allBookings.length;
    final label = _filterLabels[fi];
    return _allBookings.where((b) => b.status == label).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 4),
            _buildFilterRow(),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredIndices.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _filteredIndices.length,
                            itemBuilder: (_, i) {
                              final idx = _filteredIndices[i];
                              return _buildCard(idx);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Bookings',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pending approval',
            style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ─────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = _filterIndex == i;
          final label  = _filterLabels[i];
          final count  = _countForFilter(i);
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isActive ? _primary : _border),
              ),
              child: Text(
                '$label $count',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : _navy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 56, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'No bookings found',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Booking card ─────────────────────────────────────────────────────────────
  Widget _buildCard(int idx) {
    final b = _allBookings[idx];
    final isPending = b.status == 'Pending';
    final isOngoing = b.status == 'Ongoing';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? const Color(0xFFFED7AA) : _border,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  b.id,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                _StatusBadge(status: b.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              b.customer,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _navy,
              ),
            ),
            const SizedBox(height: 6),
            _iconRow(Icons.local_laundry_service_outlined, b.service),
            const SizedBox(height: 4),
            _iconRow(Icons.calendar_today_outlined, b.date),
            const SizedBox(height: 10),
            Text(
              'Estimated: ${b.cost}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            if (isOngoing) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              _buildStatusChips(idx),
            ],
            if (isPending) ...[
              const SizedBox(height: 14),
              _buildActions(idx),
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _muted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Horizontal status chips for ongoing cards ────────────────────────────────
  Widget _buildStatusChips(int idx) {
    const steps = ['Washing', 'Drying', 'Ready', 'Done'];
    final b = _allBookings[idx];
    final current = _stepState[b.orderId] ?? 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i       = e.key;
          final label   = e.value;
          final isActive = i == current;
          return Padding(
            padding: EdgeInsets.only(right: i < steps.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() => _stepState[b.orderId] = i);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFEFF6FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _primary : _border,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? _primary : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Decline / Accept buttons for pending cards ───────────────────────────────
  Widget _buildActions(int idx) {
    final b = _allBookings[idx];
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await AdminService.updateOrderStatus(b.orderId, 'cancelled');
              _loadOrders();
            },
            child: const _ActionButton(
              label: 'Decline',
              bgColor: Color(0xFFFEF2F2),
              borderColor: Color(0xFFFECACA),
              textColor: Color(0xFFEF4444),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await AdminService.updateOrderStatus(b.orderId, 'ongoing');
              _loadOrders();
            },
            child: const _ActionButton(
              label: 'Accept',
              bgColor: Color(0xFF2563EB),
              borderColor: Color(0xFF2563EB),
              textColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable action button ────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final Color  bgColor;
  final Color  borderColor;
  final Color  textColor;

  const _ActionButton({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
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
      case 'Completed':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        break;
      case 'Cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _AdminBooking {
  final int    orderId;
  final String id;
  final String customer;
  final String service;
  final String date;
  final String cost;
  final String status;
  final int    statusStep;

  const _AdminBooking({
    required this.orderId,
    required this.id,
    required this.customer,
    required this.service,
    required this.date,
    required this.cost,
    required this.status,
    required this.statusStep,
  });
}
