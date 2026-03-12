import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_services_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _primary = Color(0xFF2563EB);
  static const _muted   = Color(0xFF94A3B8);
  static const _border  = Color(0xFFE2E8F0);
  static const _surface = Color(0xFFF8FAFC);

  late final _pages = <Widget>[
    AdminDashboardScreen(onViewAllBookings: () => setState(() => _selectedIndex = 1)),
    const AdminBookingsScreen(),
    const _CustomersPlaceholder(),
    const AdminAnalyticsScreen(),
    const AdminServicesScreen(),
  ];

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.dashboard_rounded,    label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Bookings'),
    _NavItem(icon: Icons.people_rounded,       label: 'Customers'),
    _NavItem(icon: Icons.bar_chart_rounded,    label: 'Analytics'),
    _NavItem(icon: Icons.store_rounded,        label: 'Services'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final isActive = _selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_items[i].icon, size: 22,
                          color: isActive ? _primary : _muted),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? _primary : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _CustomersPlaceholder extends StatelessWidget {
  const _CustomersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_rounded, size: 64,
                  color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                'Customers',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coming soon',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
