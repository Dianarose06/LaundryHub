import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  static const _navy    = Color(0xFF0F172A);
  static const _primary = Color(0xFF2563EB);
  static const _surface = Color(0xFFF8FAFC);
  static const _muted   = Color(0xFF64748B);

  bool _isLoading = true;

  // Weekly revenue Mon–Sun (raw amounts)
  List<double> _weeklyRevenue = List.filled(7, 0);
  // Service breakdown [{name, pct}]
  List<Map<String, dynamic>> _serviceBreakdown = [];
  double _monthlyRevenue = 0;
  String _monthLabel = '';

  static const _donutColors = [
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
    Color(0xFF93C5FD),
    Color(0xFFBFDBFE),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAndLoadAnalytics();
  }

  Future<void> _initializeAndLoadAnalytics() async {
    // Load persistent cache first
    await AdminService.loadPersistentCache();
    await _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminService.fetchAnalytics();
      if (!mounted) return;
      if (result['success'] == true) {
        final d = result['data'] as Map<String, dynamic>;
        final rawWeekly = (d['weekly_revenue'] as List<dynamic>? ?? [])
            .map((e) => (e as num?)?.toDouble() ?? 0.0)
            .toList();
        final rawBreakdown = (d['service_breakdown'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        debugPrint('📊 Analytics Raw Data - Monthly Revenue: ${d['monthly_revenue']}, Month Label: ${d['month_label']}');
        final monthlyRev = (d['monthly_revenue'] as num?)?.toDouble() ?? 0;
        debugPrint('💰 Monthly Revenue Calculation: Raw=$monthlyRev → Formatted=${_formatRevenue(monthlyRev)}');
        debugPrint('📈 Weekly Revenue: ${rawWeekly.map((v) => '₱${v.toStringAsFixed(2)}').join(", ")}');
        setState(() {
          _weeklyRevenue    = rawWeekly.length == 7 ? rawWeekly : List.filled(7, 0);
          _serviceBreakdown = rawBreakdown;
          _monthlyRevenue   = monthlyRev;
          _monthLabel       = (d['month_label'] as String?) ?? '';
          _isLoading        = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatRevenue(double amount) {
    if (amount >= 1000) return '₱${(amount / 1000).toStringAsFixed(1)}K';
    return '₱${amount.toStringAsFixed(0)}';
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadAnalytics,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          children: [
                            _buildBarChart(),
                            const SizedBox(height: 16),
                            _buildServiceBreakdown(),
                            const SizedBox(height: 16),
                            _buildMetricsRow(),
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
            'Analytics & Reports',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _monthLabel.isEmpty ? '—' : _monthLabel,
            style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
          ),
        ],
      ),
    );
  }

  // ── Weekly revenue bar chart ──────────────────────────────────────────────────
  Widget _buildBarChart() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Highlight today's bar (weekday: 1=Mon … 7=Sun → index 0–6)
    final todayIdx = DateTime.now().weekday - 1;
    final maxVal   = _weeklyRevenue.fold(0.0, math.max);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Revenue',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This Week',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final isActive = i == todayIdx;
                final normalized = maxVal > 0 ? _weeklyRevenue[i] / maxVal : 0.0;
                final barH = 90.0 * normalized;
                final hasRevenue = _weeklyRevenue[i] > 0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasRevenue)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            _formatRevenue(_weeklyRevenue[i]),
                            style: GoogleFonts.dmSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isActive ? _primary : _muted,
                            ),
                          ),
                        ),
                      Container(
                        height: barH < 4 ? 4 : barH,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isActive ? _primary : const Color(0xFFDBEAFE),
                        ),
                        child: isActive
                            ? null
                            : Column(children: [
                                Container(
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF93C5FD),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                ),
                              ]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[i],
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? _primary : _muted,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Service breakdown (donut + legend) ────────────────────────────────────────
  Widget _buildServiceBreakdown() {
    if (_serviceBreakdown.isEmpty) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Breakdown',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _navy)),
            const SizedBox(height: 20),
            Center(
                child: Text('No service data yet',
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: _muted))),
          ],
        ),
      );
    }

    final segments = _serviceBreakdown
        .map((e) => (e['pct'] as num).toDouble() / 100.0)
        .toList();
    // Normalize so segments sum to 1 (rounding may cause tiny drift)
    final segSum = segments.fold(0.0, (a, b) => a + b);
    final normSegments =
        segSum > 0 ? segments.map((s) => s / segSum).toList() : segments;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Breakdown',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: normSegments,
                    colors: _donutColors
                        .take(normSegments.length)
                        .toList(),
                    ringColor: _surface,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _serviceBreakdown.asMap().entries.map((entry) {
                    final i     = entry.key;
                    final item  = entry.value;
                    final color = i < _donutColors.length
                        ? _donutColors[i]
                        : _donutColors.last;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['name'] as String,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: const Color(0xFF334155)),
                            ),
                          ),
                          Text(
                            '${item['pct']}%',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _navy),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2-column metrics row ──────────────────────────────────────────────────────
  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            emoji: '💵',
            value: _formatRevenue(_monthlyRevenue),
            label: 'Monthly Revenue',
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _MetricCard(
            emoji: '⭐',
            value: '—',
            label: 'Avg Rating',
          ),
        ),
      ],
    );
  }
}

// ── Shared card scaffold ──────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Metric card ───────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _MetricCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donut chart painter ───────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<double> segments;
  final List<Color>  colors;
  final Color        ringColor;

  const _DonutPainter({
    required this.segments,
    required this.colors,
    required this.ringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width  / 2;
    final cy     = size.height / 2;
    final outerR = math.min(cx, cy);
    final innerR = outerR * 0.58;
    var   angle  = -math.pi / 2; // start at top

    for (int i = 0; i < segments.length; i++) {
      final sweep = segments[i] * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(
          cx + outerR * math.cos(angle),
          cy + outerR * math.sin(angle),
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
          angle,
          sweep,
          false,
        )
        ..lineTo(
          cx + innerR * math.cos(angle + sweep),
          cy + innerR * math.sin(angle + sweep),
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
          angle + sweep,
          -sweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
      angle += sweep;
    }

    // Centre ring (surface colour)
    canvas.drawCircle(
      Offset(cx, cy),
      innerR - 1,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segments != segments || old.colors != colors;
}
