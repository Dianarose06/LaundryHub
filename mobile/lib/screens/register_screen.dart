import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/laundryhub_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleInitialController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeControllers = List.generate(6, (index) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _codeSent = false;
  bool _emailVerified = false;
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _emojiRegex = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
    unicode: true,
  );

  // Timer management
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;
  String _lastVerificationEmail = '';

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _verificationCode {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: LaundryHubColors.errorStrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.sendVerificationCode(
      _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _codeSent = true;
        _lastVerificationEmail = _emailController.text.trim().toLowerCase();
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Code sent to your email'),
          backgroundColor: LaundryHubColors.successDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Auto-focus first code field
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _codeFocusNodes[0].requestFocus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to send code'),
          backgroundColor: LaundryHubColors.errorStrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _verifyCode() async {
    final code = _verificationCode;

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 6 digits'),
          backgroundColor: LaundryHubColors.errorStrong,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.checkVerificationCode(
      _emailController.text.trim(),
      code,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _emailVerified = true;
        _lastVerificationEmail = _emailController.text.trim().toLowerCase();
      });
      _timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Email verified successfully!'),
            ],
          ),
          backgroundColor: LaundryHubColors.successDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Invalid code'),
          backgroundColor: LaundryHubColors.errorStrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please verify your email first'),
          backgroundColor: LaundryHubColors.errorStrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      middleInitial: _middleInitialController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful! You can now login.'),
          backgroundColor: LaundryHubColors.successDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registration failed'),
          backgroundColor: LaundryHubColors.errorStrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaundryHubColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top branding ──
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LaundryHubColors.primary,
                      LaundryHubColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 28, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LoginScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 168,
                            height: 168,
                            child: _buildBrandLogo(),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create Your Account',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form Container ──
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: LaundryHubColors.primarySoftBorder.withValues(
                          alpha: 0.5,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Get Started!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: LaundryHubColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fill in the details below to create your account',
                          style: TextStyle(
                            fontSize: 14,
                            color: LaundryHubColors.textSubtle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Name fields
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 50,
                          maxLines: 1,
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(_emojiRegex),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 50,
                                maxLines: 1,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(_emojiRegex),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 84,
                              child: TextFormField(
                                controller: _middleInitialController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                maxLength: 1,
                                maxLines: 1,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'MI',
                                  hintText: 'Opt',
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(_emojiRegex),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z]'),
                                  ),
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                onChanged: (value) {
                                  final upper = value.toUpperCase();
                                  if (upper != value) {
                                    _middleInitialController.value =
                                        _middleInitialController.value.copyWith(
                                          text: upper,
                                          selection: TextSelection.collapsed(
                                            offset: upper.length,
                                          ),
                                        );
                                  }
                                },
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return null;
                                  }
                                  if (!RegExp(
                                    r'^[A-Za-z]$',
                                  ).hasMatch(trimmed)) {
                                    return '1 letter';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email Address with Send Code button
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_emailVerified,
                          maxLength: 100,
                          maxLines: 1,
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(_emojiRegex),
                          ],
                          onChanged: (value) {
                            final normalized = value.trim().toLowerCase();
                            if (normalized == _lastVerificationEmail) {
                              return;
                            }

                            if (_emailVerified || _codeSent) {
                              setState(() {
                                _emailVerified = false;
                                _codeSent = false;
                                _canResend = false;
                                _remainingSeconds = 60;
                              });
                              _timer?.cancel();
                              for (final c in _codeControllers) {
                                c.clear();
                              }
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            suffixIcon: _emailVerified
                                ? const Icon(
                                    Icons.check_circle,
                                    color: LaundryHubColors.success,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: _emailVerified
                                ? LaundryHubColors.successPale
                                : Colors.white,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!_emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        if (!_emailVerified)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  _isLoading ? null : _sendVerificationCode,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              LaundryHubColors.primary,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      _codeSent ? 'Resend Code' : 'Send Code',
                                    ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Verification Code Input (shows after code is sent)
                        if (_codeSent && !_emailVerified) ...[
                          const Text(
                            'Enter the 6-digit code sent to your email',
                            style: TextStyle(
                              fontSize: 13,
                              color: LaundryHubColors.textSubtle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 45,
                                child: TextField(
                                  controller: _codeControllers[index],
                                  focusNode: _codeFocusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 1,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: LaundryHubColors.surfaceNeutral,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _codeFocusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _codeFocusNodes[index - 1].requestFocus();
                                    }

                                    // Auto-verify when all digits entered
                                    if (index == 5 && value.isNotEmpty) {
                                      _verifyCode();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!_canResend)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 16,
                                      color: LaundryHubColors.textSubtle,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Resend in $_remainingSeconds s',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: LaundryHubColors.textSubtle,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                TextButton(
                                  onPressed: _sendVerificationCode,
                                  child: const Text('Resend Code'),
                                ),
                              TextButton(
                                onPressed: _isLoading ? null : _verifyCode,
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Phone Number (Optional)
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          maxLines: 1,
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(_emojiRegex),
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Phone Number (optional)',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _PasswordField(
                          controller: _passwordController,
                          labelText: 'Password',
                          maxLength: 64,
                          helperText: 'Min. 8 characters, 1 uppercase, 1 number',
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(_emojiRegex),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (!RegExp(
                              r'^(?=.*[A-Z])(?=.*\d).{8,}$',
                            ).hasMatch(value)) {
                              return 'Password must be at least 8 characters with 1 uppercase and 1 number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _PasswordField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          maxLength: 64,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(_emojiRegex),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LaundryHubColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Login Link ──
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: LaundryHubColors.textSubtle),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LoginScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: LaundryHubColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.labelText,
    required this.validator,
    this.helperText,
    this.inputFormatters,
    this.maxLength,
  });

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      maxLength: widget.maxLength,
      maxLines: 1,
      style: const TextStyle(overflow: TextOverflow.ellipsis),
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
      ),
      validator: widget.validator,
    );
  }
}
