import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';
import 'order_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;

  static const _primary = Color(0xFF2563EB);
  static const _surface = Color(0xFFF8FAFC);
  static const _muted   = Color(0xFF94A3B8);
  static const _border  = Color(0xFFE2E8F0);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      HomeScreen(onNavigateToTab: (index) => setState(() => _selectedIndex = index)),
      const MyOrdersScreen(),
      OrderScreen(onBack: () => setState(() => _selectedIndex = 0)),
      const _AlertsPlaceholder(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _pages[0],
                _pages[1],
                _pages[2],
                _pages[3],
                _pages[4],
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    // Map display index (skipping the FAB slot) to actual page index
    // displayed tab indices: 0=Home, 1=Orders, [FAB], 2=Alerts, 3=Profile
    const items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home', pageIdx: 0),
      _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders', pageIdx: 1),
      _NavItem(icon: null, label: 'Book', pageIdx: 2), // FAB
      _NavItem(icon: Icons.notifications_outlined, label: 'Alerts', pageIdx: 3),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', pageIdx: 4),
    ];

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
            children: items.map((item) {
              if (item.pageIdx == 2) {
                // Centre FAB button
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Map page index to display-tab index (page 3=Alerts, 4=Profile
              // are stored at display indices 2 and 3 in the IndexedStack)
              final isActive = _selectedIndex == item.pageIdx;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(item.pageIdx),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isActive ? _primary : _muted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive ? _primary : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData? icon;
  final String label;
  final int pageIdx;
  const _NavItem({required this.icon, required this.label, required this.pageIdx});
}

// ── Alerts placeholder (no screen exists yet per sprint plan) ─────────────────
class _AlertsPlaceholder extends StatelessWidget {
  const _AlertsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none_rounded,
                  size: 64, color: Color(0xFF94A3B8)),
              SizedBox(height: 16),
              Text('No notifications yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF94A3B8),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
