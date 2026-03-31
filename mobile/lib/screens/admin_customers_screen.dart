import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../services/admin_profile_service.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  static const _primary = Color(0xFF2563EB);
  static const _navy = Color(0xFF0F172A);
  static const _surface = Color(0xFFF8FAFC);
  static const _muted = Color(0xFF94A3B8);
  static const _border = Color(0xFFE2E8F0);

  bool _isLoading = true;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filtered = [];
  final _searchController = TextEditingController();
  late AdminProfileService _profileService;

  @override
  void initState() {
    super.initState();
    _profileService = AdminProfileService(Dio());
    _loadCustomers();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _customers
          : _customers
                .where(
                  (c) =>
                      (c['name'] as String).toLowerCase().contains(q) ||
                      (c['email'] as String).toLowerCase().contains(q),
                )
                .toList();
    });
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final result = await _profileService.getCustomers();
      if (!mounted) return;
      final list = List<Map<String, dynamic>>.from(result['data'] as List);
      setState(() {
        _customers = list;
        _filtered = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading customers: $e')));
      setState(() => _isLoading = false);
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
            _buildSearchBar(),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadCustomers,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _buildCard(_filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customers',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_customers.length} registered customers',
            style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: GoogleFonts.dmSans(color: _muted, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 56, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'No customers found',
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

  Widget _buildCard(Map<String, dynamic> c) {
    final status = c['status'] as String? ?? 'active';
    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openProfile(c),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  (c['name'] as String? ?? '?')[0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['name'] as String? ?? 'Unknown',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c['email'] as String? ?? '',
                      style: GoogleFonts.dmSans(fontSize: 12, color: _muted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoChip(
                          Icons.receipt_long_outlined,
                          '${c['orders_count'] ?? c['total_orders'] ?? 0} orders',
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.payments_outlined,
                          '₱${c['total_spent'] ?? '0'}',
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.stars_rounded,
                          '${c['loyalty_points'] ?? 0} pts',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(isActive: isActive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _muted),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  void _openProfile(Map<String, dynamic> customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminCustomerProfileScreen(customer: customer),
      ),
    ).then((_) => _loadCustomers());
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Banned',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

// ── Customer Profile Screen ───────────────────────────────────────────────────

class AdminCustomerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  const AdminCustomerProfileScreen({super.key, required this.customer});

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
  List<Map<String, dynamic>> _orders = [];
  late Map<String, dynamic> _customer;
  late AdminProfileService _profileService;

  @override
  void initState() {
    super.initState();
    _profileService = AdminProfileService(Dio());
    _customer = Map.from(widget.customer);
    // ✅ Run independently
    _loadCustomerProfile();
    _loadOrders();
  }

  Future<void> _loadDetails() async {
    _loadCustomerProfile();
    await _loadOrders();
  }

  Future<void> _loadCustomerProfile() async {
    try {
      final profile = await _profileService.getCustomerProfile(
        _customer['id'] as int,
      );
      if (!mounted) return;
      setState(() {
        _customer = {..._customer, ...profile};
      });
    } catch (_) {
      // Silently fail — profile card shows existing data
    }
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await _profileService.getCustomerOrders(
        _customer['id'] as int,
      );
      if (!mounted) return;
      final data = result['data'];
      setState(() {
        _orders = data is List ? List<Map<String, dynamic>>.from(data) : [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _orders = [];
      });
    }
  }

  Map<String, String> _parseNameParts(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return {'lastName': '', 'firstName': '', 'middleInitial': ''};
    }

    if (trimmed.contains(',')) {
      final commaIndex = trimmed.indexOf(',');
      final lastName = trimmed.substring(0, commaIndex).trim();
      final rightSide = trimmed.substring(commaIndex + 1).trim();
      final tokens = rightSide
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .toList();

      String firstName = '';
      String middleInitial = '';

      if (tokens.isNotEmpty) {
        final lastToken = tokens.last.replaceAll('.', '');
        if (tokens.length > 1 && RegExp(r'^[A-Za-z]$').hasMatch(lastToken)) {
          middleInitial = lastToken.toUpperCase();
          firstName = tokens.sublist(0, tokens.length - 1).join(' ');
        } else {
          firstName = tokens.join(' ');
        }
      }

      return {
        'lastName': lastName,
        'firstName': firstName,
        'middleInitial': middleInitial,
      };
    }

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return {'lastName': '', 'firstName': parts.first, 'middleInitial': ''};
    }

    return {
      'lastName': parts.last,
      'firstName': parts.sublist(0, parts.length - 1).join(' '),
      'middleInitial': '',
    };
  }

  void _showEditDialog() {
    final parsedName = _parseNameParts(_customer['name'] as String? ?? '');
    final lastNameCtrl = TextEditingController(text: parsedName['lastName']);
    final firstNameCtrl = TextEditingController(text: parsedName['firstName']);
    final middleInitialCtrl = TextEditingController(
      text: parsedName['middleInitial'],
    );
    final emailCtrl = TextEditingController(
      text: _customer['email'] as String?,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Customer',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: lastNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDeco('Last Name', Icons.person_outline),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: firstNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDeco('First Name', Icons.badge_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: middleInitialCtrl,
                    maxLength: 1,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: _inputDeco(
                      'MI',
                      Icons.short_text,
                    ).copyWith(counterText: ''),
                    onChanged: (value) {
                      final upper = value.toUpperCase();
                      if (upper != value) {
                        middleInitialCtrl.value = middleInitialCtrl.value
                            .copyWith(
                              text: upper,
                              selection: TextSelection.collapsed(
                                offset: upper.length,
                              ),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: _inputDeco('Email', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: _muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final lastName = lastNameCtrl.text.trim();
              final firstName = firstNameCtrl.text.trim();
              final middleInitial = middleInitialCtrl.text.trim().toUpperCase();

              if (lastName.isEmpty || firstName.isEmpty) {
                _showSnack('Last name and first name are required', Colors.red);
                return;
              }

              if (middleInitial.isNotEmpty &&
                  !RegExp(r'^[A-Za-z]$').hasMatch(middleInitial)) {
                _showSnack(
                  'Middle initial must be a single letter',
                  Colors.red,
                );
                return;
              }

              Navigator.pop(context);
              try {
                final updated = await _profileService.updateCustomerProfile(
                  _customer['id'] as int,
                  firstName: firstName,
                  lastName: lastName,
                  middleInitial: middleInitial.isEmpty ? null : middleInitial,
                );
                if (!mounted) return;
                setState(() {
                  _customer = {..._customer, ...updated};
                });
                await _loadOrders();
                _showSnack('Customer updated!', Colors.green);
              } catch (e) {
                _showSnack('Failed to update: $e', Colors.red);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.dmSans()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: _muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF0F172A),
          ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
            onPressed: _showEditDialog,
            tooltip: 'Edit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildOrderHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              (_customer['name'] as String? ?? '?')[0].toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customer['name'] as String? ?? 'Unknown',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _customer['email'] as String? ?? '',
                  style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined ${_formatDate(_customer['created_at'] as String?)}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.receipt_long_outlined,
                label: 'Total Orders',
                value:
                    '${_customer['orders_count'] ?? _customer['total_orders'] ?? 0}',
                color: _primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.payments_outlined,
                label: 'Total Spent',
                value: '₱${_customer['total_spent'] ?? '0'}',
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.stars_rounded,
                label: 'Loyalty Points',
                value: '${_customer['loyalty_points'] ?? 0}',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: _muted)),
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order History',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Center(
              child: Text(
                'No orders yet',
                style: GoogleFonts.dmSans(color: _muted),
              ),
            ),
          )
        else
          ...(_orders.map((o) => _orderItem(o))),
      ],
    );
  }

  Widget _orderItem(Map<String, dynamic> o) {
    final status = (o['status'] as String? ?? 'pending').toLowerCase();
    final Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'ongoing':
        statusColor = _primary;
        break;
      case 'ready':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o['id'] as String? ?? '#',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  o['service_type'] as String? ?? 'Service',
                  style: GoogleFonts.dmSans(fontSize: 13, color: _navy),
                ),
                Text(
                  _formatDate(o['created_at'] as String?),
                  style: GoogleFonts.dmSans(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${o['total_price'] ?? '0'}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
