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
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  List<_AdminBooking> _allBookings = [];
  final Map<int, int> _stepState = {};
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage < _lastPage && !_isLoadingMore) {
        _loadMoreOrders();
      }
    }
  }

  // Maps a DB status string to the corresponding chip step index.
  int _statusToStep(String status) {
    switch (status) {
      case 'Ready':     return 2;
      case 'Completed': return 3;
      default:          return 0; // Pending or Ongoing
    }
  }

  // Maps step index to database status
  String _stepToStatus(int step) {
    switch (step) {
      case 0: return 'ongoing';    // Washing
      case 1: return 'ongoing';    // Drying
      case 2: return 'ready';      // Ready
      case 3: return 'completed';  // Done
      default: return 'ongoing';
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    _currentPage = 1;
    final result = await AdminService.fetchAllOrders(page: _currentPage, perPage: 20);
    if (!mounted) return;
    if (result['success'] == true) {
      final list = result['data'] as List<dynamic>;
      final pagination = result['pagination'] as Map<String, dynamic>?;
      _lastPage = pagination?['last_page'] as int? ?? 1;
      
      final bookings = list.map((e) {
        final m = e as Map<String, dynamic>;
        return _AdminBooking(
          orderId:       (m['order_id'] as num?)?.toInt() ?? (m['id'] as num?)?.toInt() ?? 0,
          id:            (m['id']?.toString() ?? '#${m['order_id']}'),
          customer:      (m['customer_name']?.toString() ?? m['customer']?.toString() ?? 'N/A'),
          serviceType:   (m['service_type']?.toString() ?? m['service']?.toString() ?? 'N/A'),
          pickupDate:    (m['pickup_date']?.toString() ?? m['date']?.toString() ?? ''),
          deliveryDate:  (m['delivery_date']?.toString() ?? ''),
          deliveryType:  (m['delivery_type']?.toString() ?? 'pickup'),
          weightKg:      (m['weight_kg']?.toString() ?? m['weight']?.toString() ?? '0'),
          cost:          (m['total_price']?.toString() ?? m['cost']?.toString() ?? m['amount']?.toString() ?? '0'),
          status:        (m['status']?.toString() ?? 'pending'),
          pickupAddress: (m['pickup_address']?.toString() ?? ''),
        );
      }).toList();
      setState(() {
        _allBookings = bookings;
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

  Future<void> _loadMoreOrders() async {
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final result = await AdminService.fetchAllOrders(page: nextPage, perPage: 20);
    if (!mounted) return;
    if (result['success'] == true) {
      final list = result['data'] as List<dynamic>;
      final pagination = result['pagination'] as Map<String, dynamic>?;
      _lastPage = pagination?['last_page'] as int? ?? _lastPage;
      
      final bookings = list.map((e) {
        final m = e as Map<String, dynamic>;
        return _AdminBooking(
          orderId:       (m['order_id'] as num?)?.toInt() ?? (m['id'] as num?)?.toInt() ?? 0,
          id:            (m['id']?.toString() ?? '#${m['order_id']}'),
          customer:      (m['customer_name']?.toString() ?? m['customer']?.toString() ?? 'N/A'),
          serviceType:   (m['service_type']?.toString() ?? m['service']?.toString() ?? 'N/A'),
          pickupDate:    (m['pickup_date']?.toString() ?? m['date']?.toString() ?? ''),
          deliveryDate:  (m['delivery_date']?.toString() ?? ''),
          deliveryType:  (m['delivery_type']?.toString() ?? 'pickup'),
          weightKg:      (m['weight_kg']?.toString() ?? m['weight']?.toString() ?? '0'),
          cost:          (m['total_price']?.toString() ?? m['cost']?.toString() ?? m['amount']?.toString() ?? '0'),
          status:        (m['status']?.toString() ?? 'pending'),
          pickupAddress: (m['pickup_address']?.toString() ?? ''),
        );
      }).toList();
      setState(() {
        _allBookings.addAll(bookings);
        for (final b in bookings) {
          if (!_stepState.containsKey(b.orderId)) {
            _stepState[b.orderId] = _statusToStep(b.status);
          }
        }
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    } else {
      setState(() => _isLoadingMore = false);
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

  String _formatDateDisplay(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
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
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _filteredIndices.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (_, i) {
                              // Show loading indicator at the end when loading more
                              if (i == _filteredIndices.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(color: _primary),
                                  ),
                                );
                              }
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
    final isReady = b.status == 'Ready';

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
            _iconRow(Icons.local_laundry_service_outlined, b.serviceType),
            const SizedBox(height: 4),
            _iconRow(Icons.calendar_today_outlined, _formatDateDisplay(b.pickupDate)),
            const SizedBox(height: 4),
            _iconRow(
              b.deliveryType == 'delivery' 
                ? Icons.delivery_dining_outlined 
                : Icons.two_wheeler_outlined,
              '${b.deliveryType == 'delivery' ? 'Delivery' : 'Pickup'} - ${_formatDateDisplay(b.deliveryDate.isNotEmpty ? b.deliveryDate : b.pickupDate)}',
            ),
            const SizedBox(height: 4),
            _iconRow(Icons.scale_outlined, '${b.weightKg} kg'),
            const SizedBox(height: 10),
            Text(
              'Total: ₱${b.cost}',
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
            if (isReady) ...[
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
        children: [
          ...steps.asMap().entries.map((e) {
            final i       = e.key;
            final label   = e.value;
            final isActive = i == current;
            return Padding(
              padding: EdgeInsets.only(right: i < steps.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () async {
                  final newStatus = _stepToStatus(i);
                  await AdminService.updateOrderStatus(b.orderId, newStatus);
                  if (!mounted) return;
                  setState(() => _stepState[b.orderId] = i);
                  await _loadOrders();
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await AdminService.updateOrderStatus(b.orderId, 'completed');
              _loadOrders();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                    color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Complete',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  final String serviceType;
  final String pickupDate;
  final String deliveryDate;
  final String deliveryType;
  final String weightKg;
  final String cost;
  final String status;
  final String pickupAddress;

  const _AdminBooking({
    required this.orderId,
    required this.id,
    required this.customer,
    required this.serviceType,
    required this.pickupDate,
    required this.deliveryDate,
    required this.deliveryType,
    required this.weightKg,
    required this.cost,
    required this.status,
    required this.pickupAddress,
  });
}
