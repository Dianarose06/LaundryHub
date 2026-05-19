import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_shell.dart';
import 'package:laundryhub/theme/laundryhub_theme.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String orderId;
  final String serviceName;

  const BookingConfirmedScreen({
    super.key,
    required this.orderId,
    required this.serviceName,
  });

  // Design system colors
  static const _primary = LaundryHubColors.primaryVivid;
  static const _primaryLight = LaundryHubColors.primaryVividLight;
  static const _navy = LaundryHubColors.textPrimary;
  static const _muted = LaundryHubColors.textSubtle;
  static const _border = LaundryHubColors.borderSoft;
  static const _surface = LaundryHubColors.surfaceSoft;
  static const _green = LaundryHubColors.success;
  static const _greenLight = LaundryHubColors.successSoft;
  static const _amber = LaundryHubColors.warning;
  static const _amberLight = LaundryHubColors.warningSoft;

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
      child: const Center(child: Text('✅', style: TextStyle(fontSize: 36))),
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
      style: GoogleFonts.dmSans(fontSize: 13, color: _muted, height: 1.5),
    );
  }

  // ── Order Summary Card ────────────────────────────────────────────────────────
  Widget _buildOrderSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
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
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.38),
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
