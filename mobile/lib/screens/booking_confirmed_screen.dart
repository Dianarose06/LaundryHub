import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_shell.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String orderId;
  final String serviceName;

  const BookingConfirmedScreen({
    super.key,
    required this.orderId,
    required this.serviceName,
  });

  // Design system colors
  static const _primary      = Color(0xFF2563EB);
  static const _primaryLight = Color(0xFF3B82F6);
  static const _navy         = Color(0xFF0F172A);
  static const _muted        = Color(0xFF94A3B8);
  static const _border       = Color(0xFFE2E8F0);
  static const _surface      = Color(0xFFF8FAFC);
  static const _green        = Color(0xFF10B981);
  static const _greenLight   = Color(0xFFECFDF5);
  static const _amber        = Color(0xFFF59E0B);
  static const _amberLight   = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSuccessIcon(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 28),
              _buildOrderSummaryCard(),
              const SizedBox(height: 20),
              _buildTrackOrderButton(context),
              const SizedBox(height: 12),
              _buildBackToHomeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success Icon ──────────────────────────────────────────────────────────────
  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _green, width: 2),
      ),
      child: const Center(
        child: Text(
          '✅',
          style: TextStyle(fontSize: 36),
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Text(
      'Booking Confirmed!',
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: _navy,
      ),
    );
  }

  // ── Subtitle ──────────────────────────────────────────────────────────────────
  Widget _buildSubtitle() {
    return Text(
      'Your booking $orderId has been submitted\nand is awaiting admin approval.',
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        color: _muted,
        height: 1.5,
      ),
    );
  }

  // ── Order Summary Card ────────────────────────────────────────────────────────
  Widget _buildOrderSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: ORDER ID
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ORDER ID',
                  style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  orderId,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _border, height: 1),

          // Row 2: SERVICE
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SERVICE',
                  style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  serviceName,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _border, height: 1),

          // Row 3: STATUS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STATUS',
                  style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amberLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Pending Approval',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Track Order Button ────────────────────────────────────────────────────────
  Widget _buildTrackOrderButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x612563EB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
            (route) => false,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'Track My Order',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Back to Home Button ───────────────────────────────────────────────────────
  Widget _buildBackToHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        },
        child: Text(
          'Back to Home',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
    );
  }
}
