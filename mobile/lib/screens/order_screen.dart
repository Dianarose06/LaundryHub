import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/order_service.dart';
import '../services/service_service.dart';
import '../config/api_config.dart';
import 'booking_confirmed_screen.dart';

// â”€â”€ Design tokens (mirrors HomeScreen / _C) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _K {
  static const primary = Color(0xFF2563EB);
  static const primaryPale = Color(0xFFEFF6FF);
  static const navy = Color(0xFF0F172A);
  static const slate = Color(0xFF334155);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const surface = Color(0xFFF8FAFC);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFFFBEB);

  static const fallbackPickupFee = 30.0;
  static const fallbackDeliveryFee = 30.0;
  static const taclobanCity = 'Tacloban City, Leyte';
  static const pickupAppliesWhenFallback = 'delivery_type is pickup';
  static const deliveryAppliesWhenFallback = 'always';
  static const logisticsReasonFallback =
      'Delivery includes route planning, customer handoff coordination, and possible wait time.';
}

class OrderScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final http.Client? httpClient;

  const OrderScreen({super.key, this.onBack, this.httpClient});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  static const int _addOnsPerPage = 6;
  late final http.Client _httpClient;
  bool _ownsHttpClient = false;

  // â”€â”€ UI state (new multi-step flow) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int _currentStep = 0;
  late final PageController _pageController;
  String _deliveryType = 'pickup';
  double _estimatedKg = 3.0;
  bool _loadingServices = true;
  bool _loadingAddOns = true;
  bool _loadingBarangays = true;

  // Removed emoji map - using ServiceService.getServiceIcon() instead

  String _emojiFor(String name) => ''; // Placeholder - icons are used instead

  // â”€â”€ Existing business-logic state (unchanged) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _weightController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _customPriceController = TextEditingController();
  int? _selectedServiceId;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  bool _isLoading = false;

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _addOnServices = [];
  List<Map<String, dynamic>> _barangays = [];
  final Set<int> _selectedAddOnIds = <int>{};
  final Map<int, Map<String, dynamic>> _selectedAddOnDetails =
      <int, Map<String, dynamic>>{};
  int _addOnsPage = 1;
  int _addOnsTotal = 0;
  int _addOnsLastPage = 1;
  bool _addOnsHasMorePages = false;
  bool _isFetchingAddOnPage = false;
  String? _addOnPageErrorMessage;
  int? _failedAddOnPage;
  int? _selectedBarangayId;
  String _barangaysBasePoint = 'Barangay 47';
  bool _deliveryCanBeHigher = true;
  String _pickupAppliesWhen = _K.pickupAppliesWhenFallback;
  String _deliveryAppliesWhen = _K.deliveryAppliesWhenFallback;
  String _logisticsReason = _K.logisticsReasonFallback;

  @override
  void initState() {
    super.initState();
    _ownsHttpClient = widget.httpClient == null;
    _httpClient = widget.httpClient ?? http.Client();
    _pageController = PageController();
    _fetchServices();
    _fetchAddOnServices();
    _fetchBarangays();
  }

  Future<void> _fetchServices() async {
    try {
      final response = await _httpClient.get(
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
            final priceStr = '₱${priceVal.round()}/8kg';
            return <String, dynamic>{
              'id': (m['id'] as num).toInt(),
              'name': name,
              'emoji': _emojiFor(name),
              'price': priceStr,
              'pricePerKg': priceVal,
              'description': (m['description']?.toString() ?? ''),
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

  Future<void> _fetchAddOnServices({
    int? serviceId,
    int? page,
    bool preserveCurrentList = false,
  }) async {
    final requestedServiceId = serviceId ?? _selectedServiceId;
    final requestedPage = page ?? _addOnsPage;
    final query = <String, String>{
      'page': requestedPage.toString(),
      'per_page': _addOnsPerPage.toString(),
    };

    if (requestedServiceId != null) {
      query['service_id'] = requestedServiceId.toString();
    }

    final uri = Uri.parse('${ApiConfig.apiPath}/add-on-services').replace(
      queryParameters: query,
    );

    try {
      final response = await _httpClient.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = body['data'] as List<dynamic>;
        final meta = body['meta'] as Map<String, dynamic>?;

        int parseInt(dynamic value, int fallback) {
          if (value is num) {
            return value.toInt();
          }

          return int.tryParse(value?.toString() ?? '') ?? fallback;
        }

        final currentPage = parseInt(meta?['current_page'], requestedPage);
        final perPage = parseInt(meta?['per_page'], _addOnsPerPage);
        final total = parseInt(meta?['total'], list.length);
        final lastPage = parseInt(
          meta?['last_page'],
          total == 0 ? 1 : (total / perPage).ceil(),
        );
        final hasMorePages = meta?['has_more_pages'] is bool
            ? meta!['has_more_pages'] as bool
            : currentPage < lastPage;

        setState(() {
          _addOnServices = list.map((e) {
            final m = e as Map<String, dynamic>;
            final rawFee = m['fee'];
            final feeVal = rawFee is num
                ? rawFee.toDouble()
                : double.tryParse(rawFee?.toString() ?? '0') ?? 0.0;

            return <String, dynamic>{
              'id': (m['id'] as num).toInt(),
              'name': m['name']?.toString() ?? 'Add-on',
              'description': m['description']?.toString() ?? '',
              'fee': feeVal,
            };
          }).toList();

          _addOnsPage = currentPage.clamp(1, lastPage);
          _addOnsTotal = total;
          _addOnsLastPage = lastPage < 1 ? 1 : lastPage;
          _addOnsHasMorePages = hasMorePages;

          for (final addOn in _addOnServices) {
            final addOnId = (addOn['id'] as num).toInt();
            if (_selectedAddOnIds.contains(addOnId)) {
              _selectedAddOnDetails[addOnId] = addOn;
            }
          }
          _selectedAddOnDetails.removeWhere(
            (id, _) => !_selectedAddOnIds.contains(id),
          );

          _loadingAddOns = false;
          _isFetchingAddOnPage = false;
          _addOnPageErrorMessage = null;
          _failedAddOnPage = null;
        });
      } else {
        setState(() {
          _loadingAddOns = false;
          _isFetchingAddOnPage = false;
          _addOnPageErrorMessage = preserveCurrentList
              ? 'Could not load this add-on page.'
              : null;
          _failedAddOnPage = preserveCurrentList ? requestedPage : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingAddOns = false;
          _isFetchingAddOnPage = false;
          _addOnPageErrorMessage = preserveCurrentList
              ? 'Could not load this add-on page.'
              : null;
          _failedAddOnPage = preserveCurrentList ? requestedPage : null;
        });
      }
    }
  }

  Future<void> _fetchBarangays() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${ApiConfig.apiPath}/barangays'),
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = body['data'] as List<dynamic>;
        final meta = body['meta'] as Map<String, dynamic>?;
        final explanation =
            meta?['logistics_fee_explanation'] as Map<String, dynamic>?;

        setState(() {
          _barangays = list.map((entry) {
            final map = entry as Map<String, dynamic>;
            final name = map['name']?.toString() ?? 'Barangay';
            final displayName = map['display_name']?.toString().trim();

            return <String, dynamic>{
              'id': (map['id'] as num).toInt(),
              'name': name,
              'display_name': (displayName != null && displayName.isNotEmpty)
                  ? displayName
                  : name,
              'old_name': map['old_name']?.toString(),
              'city': map['city']?.toString() ?? _K.taclobanCity,
              'zone': (map['zone'] as num?)?.toInt() ?? 0,
              'pickup_fee':
                  (map['pickup_fee'] as num?)?.toDouble() ??
                  _K.fallbackPickupFee,
              'delivery_fee':
                  (map['delivery_fee'] as num?)?.toDouble() ??
                  _K.fallbackDeliveryFee,
            };
          }).toList();

          if (_selectedBarangayId != null &&
              !_barangays.any((b) => b['id'] == _selectedBarangayId)) {
            _selectedBarangayId = null;
          }

          _barangaysBasePoint =
              meta?['base_barangay']?.toString() ?? 'Barangay 47';

          final deliveryCanBeHigher = explanation?['delivery_can_be_higher'];
          _deliveryCanBeHigher = deliveryCanBeHigher is bool
              ? deliveryCanBeHigher
              : true;

          final pickupAppliesWhen = explanation?['pickup_applies_when']
              ?.toString()
              .trim();
          _pickupAppliesWhen =
              (pickupAppliesWhen != null && pickupAppliesWhen.isNotEmpty)
              ? pickupAppliesWhen
              : _K.pickupAppliesWhenFallback;

          final deliveryAppliesWhen = explanation?['delivery_applies_when']
              ?.toString()
              .trim();
          _deliveryAppliesWhen =
              (deliveryAppliesWhen != null && deliveryAppliesWhen.isNotEmpty)
              ? deliveryAppliesWhen
              : _K.deliveryAppliesWhenFallback;

          final logisticsReason = explanation?['reason']?.toString().trim();
          _logisticsReason =
              (logisticsReason != null && logisticsReason.isNotEmpty)
              ? logisticsReason
              : _K.logisticsReasonFallback;

          _loadingBarangays = false;
        });
      } else {
        setState(() => _loadingBarangays = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingBarangays = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    _instructionsController.dispose();
    _customPriceController.dispose();
    if (_ownsHttpClient) {
      _httpClient.close();
    }
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
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

  Map<String, dynamic>? get _selectedService {
    if (_selectedServiceId == null) {
      return null;
    }

    for (final service in _services) {
      if (service['id'] == _selectedServiceId) {
        return service;
      }
    }

    return null;
  }

  Map<String, dynamic>? get _selectedBarangay {
    if (_selectedBarangayId == null) {
      return null;
    }

    for (final barangay in _barangays) {
      if (barangay['id'] == _selectedBarangayId) {
        return barangay;
      }
    }

    return null;
  }

  String get _selectedBarangayName {
    final display = _selectedBarangay?['display_name']?.toString().trim();
    if (display != null && display.isNotEmpty) {
      return display;
    }

    return (_selectedBarangay?['name'] as String? ?? '').trim();
  }

  String get _fullPickupAddress {
    final streetAddress = _addressController.text.trim();
    if (_selectedBarangayName.isEmpty) {
      return streetAddress;
    }

    if (streetAddress.isEmpty) {
      return '$_selectedBarangayName, ${_K.taclobanCity}';
    }

    return '$streetAddress, $_selectedBarangayName, ${_K.taclobanCity}';
  }

  String get _feeZoneLabel {
    final zone = (_selectedBarangay?['zone'] as num?)?.toInt();
    if (zone == null || zone == 0) {
      return 'Default';
    }

    return 'Zone $zone';
  }

  double get _basePickupFee {
    return (_selectedBarangay?['pickup_fee'] as num?)?.toDouble() ??
        _K.fallbackPickupFee;
  }

  double get _baseDeliveryFee {
    return (_selectedBarangay?['delivery_fee'] as num?)?.toDouble() ??
        _K.fallbackDeliveryFee;
  }

  String get _selectedServiceName {
    return (_selectedService?['name'] as String? ?? '').trim();
  }

  String get _pickupFeeRuleLabel {
    final normalized = _pickupAppliesWhen.trim().toLowerCase();
    if (normalized == 'delivery_type is pickup') {
      return 'applies only when you choose Pickup';
    }

    return _pickupAppliesWhen;
  }

  String get _deliveryFeeRuleLabel {
    final normalized = _deliveryAppliesWhen.trim().toLowerCase();
    if (normalized == 'always') {
      return 'always applied';
    }

    return _deliveryAppliesWhen;
  }

  String get _logisticsReasonText {
    final reason = _logisticsReason.trim();
    return reason.isEmpty ? _K.logisticsReasonFallback : reason;
  }

  String get _logisticsExplanationTitle {
    return _deliveryCanBeHigher
        ? 'Why delivery may cost more'
        : 'Logistics fee details';
  }

  String get _addOnSectionTitle {
    if (_selectedServiceName.isEmpty) {
      return 'Add-on Services';
    }

    return 'Add-ons for $_selectedServiceName';
  }

  String get _addOnEmptyMessage {
    if (_selectedServiceName.isEmpty) {
      return 'No add-on services available right now.';
    }

    return 'No add-on services available for $_selectedServiceName right now.';
  }

  int get _addOnPageCount {
    return _addOnsLastPage;
  }

  int get _addOnVisibleStartIndex {
    if (_addOnServices.isEmpty || _addOnsTotal == 0) {
      return 0;
    }

    return ((_addOnsPage - 1) * _addOnsPerPage) + 1;
  }

  int get _addOnVisibleEndIndex {
    if (_addOnServices.isEmpty || _addOnsTotal == 0) {
      return 0;
    }

    return _addOnVisibleStartIndex + _addOnServices.length - 1;
  }

  bool get _canGoToPreviousAddOnPage =>
      !_loadingAddOns && !_isFetchingAddOnPage && _addOnsPage > 1;

  bool get _canGoToNextAddOnPage =>
      !_loadingAddOns &&
      !_isFetchingAddOnPage &&
      (_addOnsHasMorePages || _addOnsPage < _addOnPageCount);

  void _goToPreviousAddOnPage() {
    if (!_canGoToPreviousAddOnPage) {
      return;
    }

    final targetPage = _addOnsPage - 1;
    setState(() {
      _isFetchingAddOnPage = true;
      _addOnPageErrorMessage = null;
      _failedAddOnPage = null;
    });
    _fetchAddOnServices(
      serviceId: _selectedServiceId,
      page: targetPage,
      preserveCurrentList: true,
    );
  }

  void _goToNextAddOnPage() {
    if (!_canGoToNextAddOnPage) {
      return;
    }

    final targetPage = _addOnsPage + 1;
    setState(() {
      _isFetchingAddOnPage = true;
      _addOnPageErrorMessage = null;
      _failedAddOnPage = null;
    });
    _fetchAddOnServices(
      serviceId: _selectedServiceId,
      page: targetPage,
      preserveCurrentList: true,
    );
  }

  void _retryAddOnPageLoad() {
    final targetPage = _failedAddOnPage;
    if (targetPage == null) {
      return;
    }

    setState(() {
      _isFetchingAddOnPage = true;
      _addOnPageErrorMessage = null;
    });

    _fetchAddOnServices(
      serviceId: _selectedServiceId,
      page: targetPage,
      preserveCurrentList: true,
    );
  }

  void _handleServiceSelected(int serviceId) {
    if (_selectedServiceId == serviceId) {
      return;
    }

    setState(() {
      _selectedServiceId = serviceId;
      _selectedAddOnIds.clear();
      _selectedAddOnDetails.clear();
      _addOnServices = [];
      _addOnsPage = 1;
      _addOnsTotal = 0;
      _addOnsLastPage = 1;
      _addOnsHasMorePages = false;
      _isFetchingAddOnPage = false;
      _addOnPageErrorMessage = null;
      _failedAddOnPage = null;
      _loadingAddOns = true;
    });

    _fetchAddOnServices(serviceId: serviceId, page: 1);
  }

  void _toggleAddOn(Map<String, dynamic> addOn) {
    final addOnId = (addOn['id'] as num).toInt();

    setState(() {
      if (_selectedAddOnIds.contains(addOnId)) {
        _selectedAddOnIds.remove(addOnId);
        _selectedAddOnDetails.remove(addOnId);
      } else {
        _selectedAddOnIds.add(addOnId);
        _selectedAddOnDetails[addOnId] = Map<String, dynamic>.from(addOn);
      }
    });
  }

  List<Map<String, dynamic>> get _selectedAddOns {
    final selected = _selectedAddOnDetails.entries
        .where((entry) => _selectedAddOnIds.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    selected.sort((a, b) {
      final aName = (a['name'] as String? ?? '').toLowerCase();
      final bName = (b['name'] as String? ?? '').toLowerCase();
      return aName.compareTo(bName);
    });

    return selected;
  }

  double get _addOnTotal {
    return _selectedAddOns.fold<double>(
      0,
      (sum, addOn) => sum + ((addOn['fee'] as num?)?.toDouble() ?? 0.0),
    );
  }

  String get _specialHandlingNotes => _instructionsController.text.trim();

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a service'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await OrderService.createOrder(
      serviceId: _selectedServiceId!,
      weightKg: double.parse(_weightController.text.trim()),
      pickupAddress: _fullPickupAddress,
      pickupBarangayId: _selectedBarangayId,
      pickupCity: _K.taclobanCity,
      pickupDate: _pickupDate,
      pickupTime: _pickupTime,
      deliveryDate: _deliveryDate,
      deliveryTime: _deliveryTime,
      notes: _specialHandlingNotes,
      deliveryType: _deliveryType == 'dropoff' ? 'delivery' : 'pickup',
      addOnIds: _selectedAddOnIds.toList(),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // â”€â”€ Step navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _goNext() {
    if (_currentStep == 0) {
      if (_selectedServiceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a service'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      if (_addOnServices.isEmpty && !_loadingAddOns) {
        setState(() {
          _loadingAddOns = true;
          _isFetchingAddOnPage = false;
          _addOnPageErrorMessage = null;
          _failedAddOnPage = null;
        });
        _fetchAddOnServices(serviceId: _selectedServiceId, page: 1);
      }
    } else if (_currentStep == 1) {
      if (_pickupDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a date'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      if (_loadingBarangays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please wait while we load Tacloban barangays'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      if (_selectedBarangayId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your barangay'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter house, street, or landmark'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      // sync weight controller from estimator
      _weightController.text = _estimatedKg.toStringAsFixed(1);
    }
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goPrev() {
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _K.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _K.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: _K.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'New Booking',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _K.navy,
                  ),
                ),
              ),
              Text(
                stepLabels[_currentStep],
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _K.muted,
                ),
              ),
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
          Text(
            'Choose a Service',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _K.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'What do you need washed today?',
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.muted),
          ),
          const SizedBox(height: 24),
          if (_loadingServices)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 280,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _services.length,
              itemBuilder: (_, i) {
                final svc = _services[i];
                final isSelected = _selectedServiceId == svc['id'];
                final description = (svc['description'] as String? ?? '')
                    .trim();
                return GestureDetector(
                  onTap: () =>
                      _handleServiceSelected((svc['id'] as num).toInt()),
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
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _K.primaryPale,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(child: _buildServiceIcon(svc)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                svc['name'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _K.navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                svc['price'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: _K.muted,
                                ),
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    height: 1.25,
                                    color: _K.slate,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: _K.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 13,
                                color: Colors.white,
                              ),
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

  Widget _buildServiceIcon(Map<String, dynamic> svc) {
    final name = svc['name'] as String? ?? '';
    final icon = ServiceService.getServiceIcon(name);
    return Icon(icon, size: 26, color: _K.primary);
  }

  // â”€â”€ Step 2: Schedule â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a Schedule',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _K.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose pickup/drop-off and your preferred time',
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.muted),
          ),
          const SizedBox(height: 24),

          // Delivery type selector
          Row(
            children: [
              _deliveryTypeTile('pickup', Icons.two_wheeler_rounded, 'Pickup'),
              const SizedBox(width: 12),
              _deliveryTypeTile(
                'dropoff',
                Icons.directions_walk_rounded,
                'Drop-off',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date picker
          _schedulePickerRow(
            icon: Icons.calendar_today_outlined,
            value: _pickupDate != null ? _formatDate(_pickupDate!) : null,
            placeholder: _deliveryType == 'pickup'
                ? 'Select pickup date'
                : 'Select drop-off date',
            onTap: _selectPickupDate,
          ),
          const SizedBox(height: 12),

          // Time picker
          _schedulePickerRow(
            icon: Icons.access_time_outlined,
            value: _pickupTime != null ? _formatTime(_pickupTime!) : null,
            placeholder: _deliveryType == 'pickup'
                ? 'Select pickup time'
                : 'Select drop-off time',
            onTap: _selectPickupTime,
          ),
          const SizedBox(height: 20),

          // Delivery date/time section
          Text(
            'Delivery Schedule',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _K.navy,
            ),
          ),
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
                      Text(
                        'Estimated Weight',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _K.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                _weightBtn(Icons.remove, () {
                  if (_estimatedKg > 0.5) setState(() => _estimatedKg -= 0.5);
                }),
                const SizedBox(width: 12),
                Text(
                  '${_estimatedKg.toStringAsFixed(1)} kg',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _K.primary,
                  ),
                ),
                const SizedBox(width: 12),
                _weightBtn(Icons.add, () {
                  setState(() => _estimatedKg += 0.5);
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            _addOnSectionTitle,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _K.navy,
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingAddOns && _addOnServices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_addOnServices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _K.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _addOnEmptyMessage,
                      style: GoogleFonts.dmSans(fontSize: 12, color: _K.muted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _addOnsPage = 1;
                        _addOnsTotal = 0;
                        _addOnsLastPage = 1;
                        _addOnsHasMorePages = false;
                        _loadingAddOns = true;
                        _isFetchingAddOnPage = false;
                        _addOnPageErrorMessage = null;
                        _failedAddOnPage = null;
                      });
                      _fetchAddOnServices(
                        serviceId: _selectedServiceId,
                        page: 1,
                      );
                    },
                    child: Text(
                      'Retry',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _K.primary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _addOnServices
                  .map(
                    (addOn) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildAddOnCard(addOn),
                    ),
                  )
                  .toList(),
            ),

          if (_addOnPageCount > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    'Showing $_addOnVisibleStartIndex-$_addOnVisibleEndIndex of $_addOnsTotal',
                    style: GoogleFonts.dmSans(fontSize: 11, color: _K.muted),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _canGoToPreviousAddOnPage
                        ? _goToPreviousAddOnPage
                        : null,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$_addOnsPage/$_addOnPageCount',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _K.slate,
                    ),
                  ),
                  TextButton(
                    onPressed: _canGoToNextAddOnPage
                        ? _goToNextAddOnPage
                        : null,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_isFetchingAddOnPage)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),

          if (_addOnPageErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _failedAddOnPage != null
                          ? '${_addOnPageErrorMessage!} (Page $_failedAddOnPage)'
                          : _addOnPageErrorMessage!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isFetchingAddOnPage ? null : _retryAddOnPageLoad,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_selectedAddOns.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Add-on subtotal: ₱ ${_addOnTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _K.primary,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          Text(
            'Address Details',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _K.navy,
            ),
          ),
          const SizedBox(height: 8),

          // Service Area Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We currently serve select areas in Tacloban City only. Please select your barangay below.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            initialValue: _K.taclobanCity,
            readOnly: true,
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.navy),
            decoration: InputDecoration(
              labelText: 'City (Fixed Service Area)',
              labelStyle: GoogleFonts.dmSans(fontSize: 12, color: _K.muted),
              prefixIcon: const Icon(
                Icons.location_city_outlined,
                size: 20,
                color: _K.muted,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
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
                borderSide: const BorderSide(color: _K.border, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_loadingBarangays)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _K.border, width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Loading Tacloban barangays...',
                    style: GoogleFonts.dmSans(fontSize: 12, color: _K.muted),
                  ),
                ],
              ),
            )
          else if (_barangays.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _K.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'No Tacloban barangays available right now.',
                      style: GoogleFonts.dmSans(fontSize: 12, color: _K.muted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() => _loadingBarangays = true);
                      _fetchBarangays();
                    },
                    child: Text(
                      'Retry',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _K.primary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _selectedBarangayId,
                  menuMaxHeight: 320,
                  decoration: InputDecoration(
                    hintText: 'Select barangay (e.g., Barangay 59)',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: _K.muted,
                    ),
                    prefixIcon: const Icon(
                      Icons.map_outlined,
                      size: 20,
                      color: _K.muted,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
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
                  items: _barangays.map((barangay) {
                    final zone = (barangay['zone'] as num?)?.toInt() ?? 0;
                    final zoneLabel = zone > 0 ? 'Zone $zone' : 'Zone';
                    final displayName =
                        (barangay['display_name'] as String? ?? '').trim();
                    final name = (barangay['name'] as String? ?? '').trim();
                    final label = displayName.isNotEmpty ? displayName : name;

                    return DropdownMenuItem<int>(
                      value: barangay['id'] as int,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(fontSize: 13, color: _K.navy),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBarangayId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select your barangay' : null,
                ),
              ],
            ),
          if (_selectedBarangayId != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _K.primaryPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _K.primary, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee Preview ($_feeZoneLabel)',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _K.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _deliveryType == 'pickup'
                        ? 'Pickup Fee: ₱ ${_basePickupFee.toStringAsFixed(2)}'
                        : 'Pickup Fee: ₱ 0.00 (Drop-off selected)',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _K.slate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Delivery Fee: ₱ ${_baseDeliveryFee.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _K.slate,
                    ),
                  ),

                  const SizedBox(height: 8),
                  _buildLogisticsExplanationCard(compact: true),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          TextFormField(
            controller: _addressController,
            onChanged: (_) => setState(() {}),
            maxLines: 2,
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.navy),
            decoration: InputDecoration(
              labelText: 'House No. / Street / Landmark',
              labelStyle: GoogleFonts.dmSans(fontSize: 12, color: _K.muted),
              hintText:
                  'e.g., House 123, Green Street, near Alpha Gym',
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: _K.muted),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Icon(Icons.home_outlined, size: 20, color: _K.muted),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
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
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter house, street, or landmark'
                : null,
          ),
          if (_selectedBarangayId != null ||
              _addressController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _K.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Address Preview (No GPS)',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _K.slate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fullPickupAddress.isEmpty
                        ? 'Complete your street and barangay details to build the full pickup address.'
                        : _fullPickupAddress,
                    style: GoogleFonts.dmSans(fontSize: 12, color: _K.navy),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _K.amberLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _K.amber, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: _K.amber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payment Method: Cash on Delivery (COD) only',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _K.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _instructionsController,
            maxLines: 3,
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.navy),
            decoration: InputDecoration(
              hintText: 'Special handling requests (optional)',
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: _K.muted),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 38),
                child: Icon(Icons.note_alt_outlined, size: 20, color: _K.muted),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
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
              color: isSelected ? _K.primary : _K.border,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: isSelected ? _K.primary : _K.slate),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _K.primary : _K.slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOnCard(Map<String, dynamic> addOn) {
    final addOnId = (addOn['id'] as num).toInt();
    final isSelected = _selectedAddOnIds.contains(addOnId);
    final fee = (addOn['fee'] as num?)?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: () => _toggleAddOn(addOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _K.primaryPale : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _K.primary : _K.border,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? _K.primary : _K.muted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addOn['name'] as String? ?? 'Add-on',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _K.navy,
                    ),
                  ),
                  if ((addOn['description'] as String? ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        addOn['description'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: _K.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₱ ${fee.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _K.primary,
              ),
            ),
          ],
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
              width: 36,
              height: 36,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: value != null ? _K.navy : _K.muted,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _K.muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsExplanationCard({bool compact = false}) {
    final titleStyle = GoogleFonts.dmSans(
      fontSize: compact ? 11 : 12,
      fontWeight: FontWeight.w700,
      color: _K.navy,
    );
    final bodyStyle = GoogleFonts.dmSans(
      fontSize: compact ? 11 : 12,
      color: _K.slate,
      height: 1.35,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _K.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: _K.slate, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_logisticsExplanationTitle, style: titleStyle),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_logisticsReasonText, style: bodyStyle),
          const SizedBox(height: 6),
          Text('Pickup fee: $_pickupFeeRuleLabel', style: bodyStyle),
          const SizedBox(height: 2),
          Text('Delivery fee: $_deliveryFeeRuleLabel', style: bodyStyle),
        ],
      ),
    );
  }

  Widget _weightBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _K.primaryPale,
        borderRadius: BorderRadius.circular(8),
      ),
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
    final baseEstimate = (pricePerKg / 8) * _estimatedKg;
    final selectedAddOns = _selectedAddOns;
    final addOnTotal = _addOnTotal;
    final pickupFee = _deliveryType == 'pickup' ? _basePickupFee : 0.0;
    final deliveryFee = _baseDeliveryFee;
    final estimatedTotal = baseEstimate + addOnTotal + pickupFee + deliveryFee;
    final streetAddress = _addressController.text.trim();
    final displayStreetAddress = streetAddress.isEmpty
        ? 'Not set'
        : streetAddress;
    final displayBarangay = _selectedBarangayName.isEmpty
        ? 'Not selected'
        : _selectedBarangayName;
    final displayPickupAddress = _fullPickupAddress.isEmpty
        ? 'Not set'
        : _fullPickupAddress;
    final selectedServiceName = (selectedSvc['name'] as String? ?? '')
        .trim()
        .toUpperCase();
    final addOnLabel = selectedServiceName.isEmpty
        ? 'ADD-ON'
        : '$selectedServiceName ADD-ON';
    final addOnTotalLabel = selectedServiceName.isEmpty
        ? 'ADD-ON TOTAL'
        : '$selectedServiceName ADD-ON TOTAL';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _K.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review your details before confirming',
            style: GoogleFonts.dmSans(fontSize: 13, color: _K.muted),
          ),
          const SizedBox(height: 24),

          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _K.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _summaryRow('SERVICE', selectedSvc['name']),
                _summaryDivider(),
                _summaryRow('PRICE', selectedSvc['price'] as String),
                _summaryDivider(),
                _summaryRow(
                  'TYPE',
                  _deliveryType == 'pickup' ? 'Pickup' : 'Drop-off',
                ),
                _summaryDivider(),
                _summaryRow(
                  _deliveryType == 'pickup' ? 'PICKUP DATE' : 'DROP-OFF DATE',
                  _pickupDate != null ? _formatDate(_pickupDate!) : 'Not set',
                ),
                _summaryDivider(),
                _summaryRow(
                  _deliveryType == 'pickup' ? 'PICKUP TIME' : 'DROP-OFF TIME',
                  _pickupTime != null ? _formatTime(_pickupTime!) : 'Not set',
                ),
                _summaryDivider(),
                _summaryRow(
                  'DELIVERY DATE',
                  _deliveryDate != null
                      ? _formatDate(_deliveryDate!)
                      : 'Not set',
                ),
                _summaryDivider(),
                _summaryRow(
                  'DELIVERY TIME',
                  _deliveryTime != null
                      ? _formatTime(_deliveryTime!)
                      : 'Not set',
                ),
                _summaryDivider(),
                _summaryRow('CITY', _K.taclobanCity),
                _summaryDivider(),
                _summaryRow('BARANGAY', displayBarangay),
                _summaryDivider(),
                _summaryRow('STREET / LANDMARK', displayStreetAddress),
                _summaryDivider(),
                _summaryRow('PICKUP ADDRESS', displayPickupAddress),
                _summaryDivider(),

                _summaryRow('WEIGHT', '${_estimatedKg.toStringAsFixed(1)} kg'),
                _summaryDivider(),
                _summaryRow(
                  'BASE ESTIMATE',
                  '₱ ${baseEstimate.toStringAsFixed(2)}',
                ),
                if (selectedAddOns.isNotEmpty) ...[
                  _summaryDivider(),
                  ...selectedAddOns.map((addOn) {
                    final fee = (addOn['fee'] as num?)?.toDouble() ?? 0.0;
                    return _summaryRow(
                      addOnLabel,
                      '${addOn['name']} (+₱ ${fee.toStringAsFixed(2)})',
                    );
                  }),
                  _summaryDivider(),
                  _summaryRow(
                    addOnTotalLabel,
                    '₱ ${addOnTotal.toStringAsFixed(2)}',
                  ),
                ],
                _summaryDivider(),
                _summaryRow(
                  'PICKUP FEE',
                  _deliveryType == 'pickup'
                      ? '₱ ${pickupFee.toStringAsFixed(2)}'
                      : '₱ 0.00 (Drop-off selected)',
                ),
                _summaryDivider(),
                _summaryRow(
                  'DELIVERY FEE',
                  '₱ ${deliveryFee.toStringAsFixed(2)}',
                ),
                if (_specialHandlingNotes.isNotEmpty) ...[
                  _summaryDivider(),
                  _summaryRow('SPECIAL HANDLING', _specialHandlingNotes),
                ],
                _summaryDivider(),
                _summaryRow('PAYMENT METHOD', 'Cash on Delivery (COD)'),
                _summaryDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PAYMENT',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _K.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₱ ${estimatedTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _K.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildLogisticsExplanationCard(),
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
                Text(
                  'Cash on Delivery (COD) only',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _K.amber,
                  ),
                ),
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
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _K.muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _K.navy,
            ),
          ),
        ),
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
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: _goPrev,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _K.border, width: 1.5),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _K.navy,
          size: 18,
        ),
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
              ? const LinearGradient(
                  colors: [Color(0xFF90CAF9), Color(0xFF90CAF9)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Confirm Booking',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
