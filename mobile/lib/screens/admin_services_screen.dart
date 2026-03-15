import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_service.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  static const _navy    = Color(0xFF0F172A);
  static const _primary = Color(0xFF2563EB);
  static const _surface = Color(0xFFF8FAFC);
  static const _muted   = Color(0xFF64748B);
  static const _border  = Color(0xFFE2E8F0);

  bool _loadingServices  = true;
  bool _loadingCustomers = true;
  List<_ServiceItem> _services  = [];
  List<_TopCustomer> _customers = [];

  static const _serviceEmojis = <String, String>{
    'wash-dry-fold':      '🧺',
    'wash–dry–fold':      '🧺',
    'dry clean':          '✨',
    'dry cleaning':       '✨',
    'beddings':           '🛏',
    'beddings & linens':  '🛏',
    'beddings and linens': '🛏',
    'express wash':       '⚡',
    'soft wash':          '🌸',
  };

  String _emojiFor(String name) =>
      _serviceEmojis[name.toLowerCase()] ?? '🧺';

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadTopCustomers();
  }

  Future<void> _loadServices() async {
    try {
      final result = await AdminService.fetchServices();
      if (!mounted) return;
      if (result['success'] == true) {
        final list = result['data'] as List<dynamic>;
        setState(() {
          _services = list.map((e) {
            final m = e as Map<String, dynamic>;
            final name = m['name'] as String;
            final rawPrice = m['price_per_kg'];
            final priceVal = rawPrice is num
                ? rawPrice.toDouble()
                : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;
            return _ServiceItem(
              id: (m['id'] as num).toInt(),
              emoji: _emojiFor(name),
              name:  name,
              description: m['description'] as String? ?? '',
              price: '₱${priceVal % 1 == 0 ? priceVal.toInt() : priceVal}/kg',
              pricePerKg: priceVal,
              category: m['category'] as String? ?? 'general',
              imageUrl: m['image_url'] as String?,
            );
          }).toList();
          _loadingServices = false;
        });
      } else {
        if (mounted) setState(() => _loadingServices = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  Future<void> _loadTopCustomers() async {
    final result = await AdminService.fetchTopCustomers();
    if (!mounted) return;
    setState(() {
      if (result['success'] == true) {
        final list = result['data'] as List<dynamic>;
        _customers = list.map((e) {
          final m = e as Map<String, dynamic>;
          return _TopCustomer(
            name:   m['name']   as String,
            orders: (m['orders'] as num).toInt(),
            spend:  m['spend']  as String,
          );
        }).toList();
      }
      _loadingCustomers = false;
    });
  }

  Future<void> _showAddServiceDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String category = 'Basic';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New Service', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price per kg (₱)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Basic', 'Premium', 'Specialty', 'Express']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => category = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final desc = descController.text.trim();
      final price = double.tryParse(priceController.text.trim()) ?? 0;

      if (name.isEmpty || price <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide valid service details'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final apiResult = await AdminService.createService(
        name: name,
        description: desc,
        pricePerKg: price,
        category: category.toLowerCase(),
      );

      if (mounted) {
        if (apiResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service "$name" added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadServices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResult['message'] ?? 'Failed to add service'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteService(_ServiceItem service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Service', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${service.name}"? This cannot be undone.',
          style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await AdminService.deleteService(service.id);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service "${service.name}" deleted'),
              backgroundColor: Colors.green,
            ),
          );
          _loadServices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete service'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditServiceDialog(_ServiceItem service) async {
    final nameController  = TextEditingController(text: service.name);
    final descController  = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.pricePerKg.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Service', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price per kg (₱)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final price = double.tryParse(priceController.text.trim()) ?? 0;

      if (name.isEmpty || price <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide valid service details'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final desc = descController.text.trim();
      final apiResult = await AdminService.updateService(
        serviceId: service.id,
        name: name,
        description: desc.isEmpty ? service.description : desc,
        pricePerKg: price,
        category: service.category,
        imageUrl: service.imageUrl,
      );

      if (mounted) {
        if (apiResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service "$name" updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadServices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResult['message'] ?? 'Failed to update service'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _loadingServices  = true;
                    _loadingCustomers = true;
                  });
                  await Future.wait([_loadServices(), _loadTopCustomers()]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      _buildServicesCard(),
                      const SizedBox(height: 20),
                      _buildTopCustomersCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services & Pricing',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Manage your offerings',
            style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
          ),
        ],
      ),
    );
  }

  // ── Active Services card ──────────────────────────────────────────────────────
  Widget _buildServicesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Services',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            // "+ Add" pill
            GestureDetector(
              onTap: _showAddServiceDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 14,
                        color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Services list card
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
              if (_loadingServices)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_services.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('No services found',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: _muted)),
                  ),
                )
              else
                ..._services.asMap().entries.map((entry) {
                final i    = entry.key;
                final svc  = entry.value;
                final isLast = i == _services.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(svc.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            svc.name,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _navy,
                            ),
                          ),
                        ),
                        Text(
                          svc.price,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showEditServiceDialog(svc),
                          child: const Icon(Icons.edit_outlined,
                              size: 18, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _confirmDeleteService(svc),
                          child: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 16, endIndent: 16,
                        color: Color(0xFFE2E8F0)),
                ],
              );
            }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Top Customers card ────────────────────────────────────────────────────────
  Widget _buildTopCustomersCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Customers',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        const SizedBox(height: 12),
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
              if (_loadingCustomers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_customers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('No customer data yet',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: _muted)),
                  ),
                )
              else
                ..._customers.asMap().entries.map((entry) {
                final i      = entry.key;
                final c      = entry.value;
                final isLast = i == _customers.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Avatar circle
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFBFDBFE)),
                          ),
                          child: Center(
                            child: Text(
                              c.name[0],
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c.orders} orders',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          c.spend,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 16, endIndent: 16,
                        color: Color(0xFFE2E8F0)),
                ],
              );
            }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _ServiceItem {
  final int id;
  final String emoji;
  final String name;
  final String description;
  final String price;
  final double pricePerKg;
  final String category;
  final String? imageUrl;
  
  const _ServiceItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.price,
    required this.pricePerKg,
    required this.category,
    this.imageUrl,
  });
}

class _TopCustomer {
  final String name;
  final int    orders;
  final String spend;
  const _TopCustomer({
    required this.name,
    required this.orders,
    required this.spend,
  });
}
