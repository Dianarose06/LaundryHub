import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/order_service.dart';
import '../config/api_config.dart';
import 'booking_confirmed_screen.dart';

// â”€â”€ Design tokens (mirrors HomeScreen / _C) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _K {
  static const primary     = Color(0xFF2563EB);
  static const primaryPale = Color(0xFFEFF6FF);
  static const navy        = Color(0xFF0F172A);
  static const slate       = Color(0xFF334155);
  static const muted       = Color(0xFF94A3B8);
  static const border      = Color(0xFFE2E8F0);
  static const surface     = Color(0xFFF8FAFC);
  static const amber       = Color(0xFFF59E0B);
  static const amberLight  = Color(0xFFFFFBEB);
}

class OrderScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const OrderScreen({super.key, this.onBack});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // â”€â”€ UI state (new multi-step flow) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int _currentStep = 0;
  late final PageController _pageController;
  String _deliveryType = 'pickup';
  double _estimatedKg = 3.0;
  bool _loadingServices = true;

  static const _serviceEmojis = <String, String>{
    'wash-dry-fold':       '🧺',
    'wash–dry–fold':       '🧺',
    'dry clean':           '✨',
    'dry cleaning':        '✨',
    'beddings':            '🛏',
    'beddings & linens':   '🛏',
    'express wash':        '⚡',
    'soft wash':           '🌸',
  };

  String _emojiFor(String name) =>
      _serviceEmojis[name.toLowerCase()] ?? '🧺';

  // â”€â”€ Existing business-logic state (unchanged) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _weightController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  int? _selectedServiceId;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  bool _isLoading = false;

  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiPath}/services'),
        headers: {'Accept': 'application/json'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = body['data'] as List<dynamic>;
        setState(() {
          _services = list.map((e) {
            final m = e as Map<String, dynamic>;
            final name = m['name'] as String;
            final rawPrice = m['price_per_kg'];
            final priceVal = rawPrice is num
                ? rawPrice.toDouble()
                : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;
            final priceStr = '₱${priceVal % 1 == 0 ? priceVal.toInt() : priceVal}/kg';
            return <String, dynamic>{
              'id': (m['id'] as num).toInt(),
              'name': name,
              'emoji': _emojiFor(name),
              'price': priceStr,
              'pricePerKg': priceVal,
              'description': m['description'] as String? ?? '',
            };
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

  @override
  void dispose() {
    _pageController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _pickupDate = date);
    }
  }

  Future<void> _selectPickupTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _pickupTime = time);
    }
  }

  Future<void> _selectDeliveryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now(),
      firstDate: _pickupDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _deliveryDate = date);
    }
  }

  Future<void> _selectDeliveryTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _deliveryTime = time);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a service'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await OrderService.createOrder(
      serviceId: _selectedServiceId!,
      weightKg: double.parse(_weightController.text.trim()),
      pickupAddress: _addressController.text.trim(),
      pickupDate: _pickupDate,
      pickupTime: _pickupTime,
      deliveryDate: _deliveryDate,
      deliveryTime: _deliveryTime,
      notes: _instructionsController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final orderData = result['data'] as Map<String, dynamic>;
      final orderId = '#LH-${orderData['id'].toString().padLeft(4, '0')}';
      final serviceName = orderData['service']?['name'] ?? 'Service';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmedScreen(
            orderId: orderId,
            serviceName: serviceName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to place order'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // â”€â”€ Step navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _goNext() {
    if (_currentStep == 0) {
      if (_selectedServiceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Please select a service'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        return;
      }
    } else if (_currentStep == 1) {
      if (_pickupDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Please select a date'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        return;
      }
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Please enter your address'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        return;
      }
      // sync weight controller from estimator
      _weightController.text = _estimatedKg.toStringAsFixed(1);
    }
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goPrev() {
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _handleConfirm() async {
    _weightController.text = _estimatedKg.toStringAsFixed(1);
    await _submitOrder();
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.surface,
      body: Column(
        children: [
          _buildAppBar(),
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ App bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildAppBar() {
    const stepLabels = ['1 / 3', '2 / 3', '3 / 3'];
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _K.border)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: _currentStep == 0
                    ? (widget.onBack ?? () => Navigator.pop(context))
                    : _goPrev,
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: _K.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _K.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: _K.navy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('New Booking',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _K.navy)),
              ),
              Text(stepLabels[_currentStep],
                style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _K.muted)),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Step indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                color: isActive ? _K.primary : _K.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  // â”€â”€ Step 1: Service selection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose a Service',
            style: GoogleFonts.outfit(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: _K.navy, letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text('What do you need washed today?',
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.muted)),
          const SizedBox(height: 24),
          if (_loadingServices)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ))
          else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.1,
              crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: _services.length,
            itemBuilder: (_, i) {
              final svc = _services[i];
              final isSelected = _selectedServiceId == svc['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedServiceId = svc['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? _K.primaryPale : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? _K.primary : _K.border,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: _K.primaryPale,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(child: _serviceEmoji(svc)),
                            ),
                            const SizedBox(height: 10),
                            Text(svc['name'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: _K.navy)),
                            const SizedBox(height: 2),
                            Text(svc['price'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 12, color: _K.muted)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 0, right: 0,
                          child: Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                              color: _K.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.check,
                              size: 13, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _nextButton('Continue →', _goNext),
        ],
      ),
    );
  }

  Widget _serviceEmoji(Map<String, dynamic> svc) {
    return Text(svc['emoji'] as String? ?? '🧺', style: const TextStyle(fontSize: 26));
  }

  // â”€â”€ Step 2: Schedule â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick a Schedule',
            style: GoogleFonts.outfit(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: _K.navy, letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text('Choose pickup/drop-off and your preferred time',
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.muted)),
          const SizedBox(height: 24),

          // Delivery type selector
          Row(
            children: [
              _deliveryTypeTile('pickup', Icons.two_wheeler_rounded, 'Pickup'),
              const SizedBox(width: 12),
              _deliveryTypeTile('dropoff', Icons.directions_walk_rounded, 'Drop-off'),
            ],
          ),
          const SizedBox(height: 20),

          // Date picker
          _schedulePickerRow(
            icon: Icons.calendar_today_outlined,
            value: _pickupDate != null ? _formatDate(_pickupDate!) : null,
            placeholder: _deliveryType == 'pickup' ? 'Select pickup date' : 'Select drop-off date',
            onTap: _selectPickupDate,
          ),
          const SizedBox(height: 12),

          // Time picker
          _schedulePickerRow(
            icon: Icons.access_time_outlined,
            value: _pickupTime != null ? _formatTime(_pickupTime!) : null,
            placeholder: _deliveryType == 'pickup' ? 'Select pickup time' : 'Select drop-off time',
            onTap: _selectPickupTime,
          ),
          const SizedBox(height: 20),

          // Delivery date/time section
          Text('Delivery Schedule',
            style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: _K.navy)),
          const SizedBox(height: 10),
          _schedulePickerRow(
            icon: Icons.event_outlined,
            value: _deliveryDate != null ? _formatDate(_deliveryDate!) : null,
            placeholder: 'Select delivery date',
            onTap: _selectDeliveryDate,
          ),
          const SizedBox(height: 12),
          _schedulePickerRow(
            icon: Icons.schedule_outlined,
            value: _deliveryTime != null ? _formatTime(_deliveryTime!) : null,
            placeholder: 'Select delivery time',
            onTap: _selectDeliveryTime,
          ),
          const SizedBox(height: 20),

          // Weight estimator
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _K.border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Weight',
                        style: GoogleFonts.dmSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: _K.navy)),
                    ],
                  ),
                ),
                _weightBtn(Icons.remove, () {
                  if (_estimatedKg > 0.5) setState(() => _estimatedKg -= 0.5);
                }),
                const SizedBox(width: 12),
                Text('${_estimatedKg.toStringAsFixed(1)} kg',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _K.primary)),
                const SizedBox(width: 12),
                _weightBtn(Icons.add, () {
                  setState(() => _estimatedKg += 0.5);
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Address field (required by API)
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.navy),
            decoration: InputDecoration(
              hintText: 'Enter your pickup / drop-off address',
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: _K.muted),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Icon(Icons.location_on_outlined, size: 20, color: _K.muted),
              ),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _K.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _K.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _K.primary, width: 1.5),
              ),
            ),
            validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your address' : null,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _backButton(),
              const SizedBox(width: 12),
              Expanded(child: _nextButton('Continue →', _goNext)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deliveryTypeTile(String type, IconData icon, String label) {
    final isSelected = _deliveryType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _deliveryType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _K.primaryPale : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _K.primary : _K.border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: isSelected ? _K.primary : _K.slate),
              const SizedBox(height: 6),
              Text(label, style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: isSelected ? _K.primary : _K.slate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _schedulePickerRow({
    required IconData icon,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _K.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _K.primaryPale,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: _K.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? placeholder,
                style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: value != null ? _K.navy : _K.muted),
              ),
            ),
            const Icon(Icons.chevron_right, color: _K.muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _weightBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: _K.primaryPale, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: _K.primary),
    ),
  );

  // â”€â”€ Step 3: Summary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStep3() {
    if (_services.isEmpty || _selectedServiceId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final selectedSvc = _services.firstWhere(
      (s) => s['id'] == _selectedServiceId,
      orElse: () => _services.first,
    );
    final pricePerKg = (selectedSvc['pricePerKg'] as num?)?.toDouble() ?? 0.0;
    final estimatedTotal = pricePerKg * _estimatedKg;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Summary',
            style: GoogleFonts.outfit(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: _K.navy, letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text('Review your details before confirming',
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.muted)),
          const SizedBox(height: 24),

          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _K.border, width: 1.5),
              boxShadow: [BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.05),
                blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                _summaryRow('SERVICE', selectedSvc['name']),
                _summaryDivider(),
                _summaryRow('TYPE',
                  _deliveryType == 'pickup' ? 'Pickup' : 'Drop-off'),
                _summaryDivider(),
                _summaryRow(_deliveryType == 'pickup' ? 'PICKUP DATE' : 'DROP-OFF DATE',
                  _pickupDate != null ? _formatDate(_pickupDate!) : 'Not set'),
                _summaryDivider(),
                _summaryRow(_deliveryType == 'pickup' ? 'PICKUP TIME' : 'DROP-OFF TIME',
                  _pickupTime != null ? _formatTime(_pickupTime!) : 'Not set'),
                _summaryDivider(),
                _summaryRow('DELIVERY DATE',
                  _deliveryDate != null ? _formatDate(_deliveryDate!) : 'Not set'),
                _summaryDivider(),
                _summaryRow('DELIVERY TIME',
                  _deliveryTime != null ? _formatTime(_deliveryTime!) : 'Not set'),
                _summaryDivider(),
                _summaryRow('WEIGHT', '${_estimatedKg.toStringAsFixed(1)} kg'),
                _summaryDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL ESTIMATE',
                      style: GoogleFonts.dmSans(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: _K.muted,
                        letterSpacing: 0.5)),
                    Text('₱ ${estimatedTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: _K.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _K.amberLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _K.amber, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _K.amber, size: 18),
                const SizedBox(width: 10),
                Text('Cash on pickup / drop-off only',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: _K.amber)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _backButton(),
              const SizedBox(width: 12),
              Expanded(child: _confirmButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: _K.muted, letterSpacing: 0.5)),
        Text(value, style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w700, color: _K.navy)),
      ],
    ),
  );

  Widget _summaryDivider() => const Divider(height: 20, color: _K.border);

  // â”€â”€ Shared buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _nextButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(child: Text(label,
          style: GoogleFonts.dmSans(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: _goPrev,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _K.border, width: 1.5),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
          color: _K.navy, size: 18),
      ),
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleConfirm,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? const LinearGradient(colors: [Color(0xFF90CAF9), Color(0xFF90CAF9)])
              : const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading ? [] : [BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
              : Text('Confirm Booking',
                  style: GoogleFonts.dmSans(
                    color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
