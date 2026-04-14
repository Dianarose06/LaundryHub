import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/image_upload_service.dart';
import '../models/profile_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  CustomerProfile? _profile;
  ProfileCompletionStatus? _completionStatus;
  bool _isLoading = true;
  bool _isUploadingProfilePicture = false;
  late ProfileService _profileService;

  // ✅ Cache buster — changes every time a new image is uploaded
  String _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(Dio());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getProfile();
      final completionStatus = await _profileService.getCompletionStatus();
      if (mounted) {
        setState(() {
          _profile = profile;
          _completionStatus = completionStatus;
          _user = {
            'name': profile.name,
            'email': profile.email,
            'phone': profile.phone,
            'email_verified_at': profile.emailVerifiedAt,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditProfile() {
    Navigator.of(context).pushNamed('/edit-profile', arguments: _profile).then((
      _,
    ) {
      _loadProfile();
    });
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSubmitting = false;
    bool hideCurrent = true;
    bool hideNew = true;
    bool hideConfirm = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final current = currentPasswordController.text.trim();
              final next = newPasswordController.text.trim();
              final confirm = confirmPasswordController.text.trim();

              if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all password fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (next.length < 8) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'New password must be at least 8 characters.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (next != confirm) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'New password and confirmation do not match.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setDialogState(() => isSubmitting = true);

              try {
                await _profileService.changePassword(
                  currentPassword: current,
                  newPassword: next,
                  confirmPassword: confirm,
                );

                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                setDialogState(() => isSubmitting = false);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: hideCurrent,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setDialogState(() => hideCurrent = !hideCurrent),
                        icon: Icon(
                          hideCurrent ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: hideNew,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setDialogState(() => hideNew = !hideNew),
                        icon: Icon(
                          hideNew ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: hideConfirm,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_person_outlined),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setDialogState(() => hideConfirm = !hideConfirm),
                        icon: Icon(
                          hideConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _showEmailVerificationDialog() async {
    final email = _user?['email']?.toString();
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not available for verification.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final codeController = TextEditingController();
    bool isSendingCode = false;
    bool isVerifyingCode = false;
    bool codeSent = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !(isSendingCode || isVerifyingCode),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> sendCode() async {
              if (isSendingCode || isVerifyingCode) return;

              setDialogState(() => isSendingCode = true);

              try {
                final result = await AuthService.resendVerification(
                  email: email,
                );

                if (!mounted) return;

                setDialogState(() {
                  isSendingCode = false;
                  codeSent = result['success'] == true;
                });

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message']?.toString() ??
                          'Verification code sent to your email.',
                    ),
                    backgroundColor: result['success'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              } catch (_) {
                if (!mounted) return;

                setDialogState(() => isSendingCode = false);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to send verification email.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            Future<void> verifyCode() async {
              final code = codeController.text.trim();

              if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 6-digit code.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setDialogState(() => isVerifyingCode = true);

              try {
                final result = await AuthService.verifyCode(email, code);

                if (!mounted) return;

                setDialogState(() => isVerifyingCode = false);

                if (result['success'] == true) {
                  Navigator.of(dialogContext).pop();
                  await _loadProfile();

                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message']?.toString() ??
                            'Email verified successfully.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message']?.toString() ??
                            'Invalid verification code.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (_) {
                if (!mounted) return;

                setDialogState(() => isVerifyingCode = false);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification failed. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Verify Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send a verification code to:\n$email',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter 6-digit code',
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (codeSent)
                    const Text(
                      'Code sent. Check your email inbox.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSendingCode || isVerifyingCode
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSendingCode || isVerifyingCode ? null : sendCode,
                  child: isSendingCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(codeSent ? 'Resend Code' : 'Send Code'),
                ),
                ElevatedButton(
                  onPressed: isSendingCode || isVerifyingCode
                      ? null
                      : verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                  child: isVerifyingCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
  }

  Future<void> _showProfilePictureOptionsDialog() async {
    if (_isUploadingProfilePicture) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Profile Picture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          if (_profile?.profilePictureUrl != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProfilePicture();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadProfilePicture();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
            ),
            child: const Text(
              'Change',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    if (_isUploadingProfilePicture) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (image == null) return;

      if (!mounted) return;
      setState(() => _isUploadingProfilePicture = true);

      final validationError = await ImageUploadService.validateImage(image);
      if (validationError != null) {
        if (!mounted) return;
        setState(() => _isUploadingProfilePicture = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError), backgroundColor: Colors.red),
        );
        return;
      }

      List<int> uploadBytes;
      try {
        uploadBytes = await ImageUploadService.compressImage(image);
      } catch (_) {
        uploadBytes = await image.readAsBytes();
      }

      final originalSize = await image.length();
      final compressedSize = uploadBytes.length;
      final sizeReduction = ((1 - compressedSize / originalSize) * 100)
          .toStringAsFixed(1);

      debugPrint(
        'Profile image compressed: '
        '${ImageUploadService.getFileSizeString(originalSize)} -> '
        '${ImageUploadService.getFileSizeString(compressedSize)} '
        '($sizeReduction% reduction)',
      );

      final imageUrl = await _profileService.uploadProfilePicture(
        image,
        uploadBytes: uploadBytes,
      );

      if (!mounted) return;

      // ✅ Clear Flutter's image cache for the old URL
      if (_profile?.profilePictureUrl != null) {
        await NetworkImage(_profile!.profilePictureUrl!).evict();
      }

      // ✅ Update cache buster to force Image.network to reload
      setState(() {
        _profile = _profile?.copyWith(profilePictureUrl: imageUrl);
        _isUploadingProfilePicture = false;
        _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Reload profile to get fresh data from server
      await _loadProfile();

      // ✅ Update cache buster again after reload
      if (mounted) {
        setState(() {
          _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingProfilePicture = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProfilePicture() async {
    if (_isUploadingProfilePicture) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Profile Picture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete your profile picture? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (!mounted) return;
      setState(() => _isUploadingProfilePicture = true);

      await _profileService.deleteProfilePicture();

      if (!mounted) return;

      // ✅ Clear Flutter's image cache
      if (_profile?.profilePictureUrl != null) {
        await NetworkImage(_profile!.profilePictureUrl!).evict();
      }

      // ✅ Update state and reload profile
      setState(() {
        _profile = _profile?.copyWith(profilePictureUrl: null);
        _isUploadingProfilePicture = false;
        _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Reload profile to get fresh data
      await _loadProfile();

      if (mounted) {
        setState(() {
          _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingProfilePicture = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete profile picture: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleNotificationsQuick(bool enabled) async {
    final previous = _profile?.notificationsEnabled ?? true;

    setState(() {
      _profile = _profile?.copyWith(notificationsEnabled: enabled);
    });

    try {
      final updatedProfile = await _profileService.updateProfile(
        notificationsEnabled: enabled,
      );

      if (!mounted) return;
      setState(() {
        _profile = updatedProfile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Notifications enabled successfully.'
                : 'Notifications disabled successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile = _profile?.copyWith(notificationsEnabled: previous);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateOfBirth(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Not provided';

    try {
      final date = DateTime.parse(rawDate);
      final monthNames = <String>[
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
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return 'Not provided';
    return '${gender[0].toUpperCase()}${gender.substring(1)}';
  }

  Widget _buildInitialCircle() {
    return Center(
      child: Text(
        ((_user?['name']?.toString() ?? 'U'))[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1565C0),
        ),
      ),
    );
  }

  // ✅ Builds image URL with cache buster appended
  String? _getImageUrlWithCacheBuster(String? url) {
    if (url == null || url.isEmpty) return null;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$_imageCacheBuster';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1565C0)),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Top Header with Profile ──
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 20, 24, 40),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _showEditProfile,
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                ),
                                tooltip: 'Edit Profile',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isUploadingProfilePicture
                                    ? const Center(
                                        child: SizedBox(
                                          width: 26,
                                          height: 26,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Color(0xFF1565C0),
                                          ),
                                        ),
                                      )
                                    : ClipOval(
                                        child:
                                            _profile?.profilePictureUrl != null
                                            // ✅ Use cache-busted URL
                                            ? Image.network(
                                                _getImageUrlWithCacheBuster(
                                                  _profile!.profilePictureUrl,
                                                )!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                // ✅ Disable Flutter's cache
                                                cacheWidth: null,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      debugPrint(
                                                        '🖼️ IMAGE ERROR: $error',
                                                      );
                                                      return _buildInitialCircle();
                                                    },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value:
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                              )
                                            : _buildInitialCircle(),
                                      ),
                              ),
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isUploadingProfilePicture
                                        ? null
                                        : _showProfilePictureOptionsDialog,
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF1565C0),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 18,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user?['name']?.toString() ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?['email']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Profile Completion Status ──
                    if (_completionStatus != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Profile Completion',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D1B4B),
                                    ),
                                  ),
                                  Text(
                                    '${_completionStatus!.completedPercentage}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value:
                                      _completionStatus!.completedPercentage /
                                      100,
                                  minHeight: 8,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.blue.shade400,
                                  ),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_completionStatus!.completedFields} of ${_completionStatus!.totalFields} fields completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B4B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            label: 'Full Name',
                            value: _user?['name']?.toString() ?? 'N/A',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: _user?['email']?.toString() ?? 'N/A',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.phone_outlined,
                            label: 'Phone Number',
                            value:
                                _user?['phone']?.toString() ?? 'Not provided',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.verified_outlined,
                            label: 'Email Status',
                            value: (_user?['email_verified_at'] != null)
                                ? 'Verified'
                                : 'Not Verified',
                            valueColor: (_user?['email_verified_at'] != null)
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.stars_outlined,
                            label: 'Loyalty Points',
                            value: '${_profile?.loyaltyPoints ?? 0} pts',
                            valueColor: const Color(0xFF1565C0),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.cake_outlined,
                            label: 'Date of Birth',
                            value: _formatDateOfBirth(_profile?.dateOfBirth),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.wc_outlined,
                            label: 'Gender',
                            value: _formatGender(_profile?.gender),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.language_outlined,
                            label: 'Preferred Language',
                            value: (_profile?.preferredLanguage ?? 'en')
                                .toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.notifications_active_outlined,
                            label: 'Notifications',
                            value: (_profile?.notificationsEnabled ?? true)
                                ? 'Enabled'
                                : 'Disabled',
                            valueColor: (_profile?.notificationsEnabled ?? true)
                                ? Colors.green
                                : Colors.orange,
                          ),
                          if (_profile?.bio != null &&
                              _profile!.bio!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.info_outline,
                              label: 'Bio',
                              value: _profile!.bio ?? 'N/A',
                            ),
                          ],
                          if (_profile?.address != null &&
                              _profile!.address!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value:
                                  '${_profile!.address}, ${_profile!.city ?? ''}, ${_profile!.country ?? ''}',
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Account Actions ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B4B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionCard(
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            color: const Color(0xFF1565C0),
                            onTap: _showEditProfile,
                          ),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            subtitle: 'Update your account password',
                            color: const Color(0xFF1E88E5),
                            onTap: _showChangePasswordDialog,
                          ),
                          if (_user?['email_verified_at'] == null) ...[
                            const SizedBox(height: 12),
                            _buildActionCard(
                              icon: Icons.mark_email_unread_outlined,
                              title: 'Verify Email',
                              subtitle: 'Send code and verify your email now',
                              color: const Color(0xFFFB8C00),
                              onTap: _showEmailVerificationDialog,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildNotificationToggleCard(),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            subtitle: 'Sign out of your account',
                            color: Colors.red,
                            onTap: _confirmLogout,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      'LaundryHub v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF0D1B4B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggleCard() {
    final enabled = _profile?.notificationsEnabled ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF42A5F5),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B4B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? 'Order and account alerts are enabled'
                      : 'Notifications are currently disabled',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: const Color(0xFF1565C0),
            onChanged: _toggleNotificationsQuick,
          ),
        ],
      ),
    );
  }
}
