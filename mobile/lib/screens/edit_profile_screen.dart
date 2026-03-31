import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';
import '../services/image_upload_service.dart';
import '../models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final CustomerProfile? profile;

  const EditProfileScreen({Key? key, this.profile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late ProfileService _profileService;
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _middleInitialController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;
  late TextEditingController _dateOfBirthController;

  String? _selectedGender;
  String? _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _isSaving = false;
  bool _isUploadingPicture = false;

  // ✅ FIX: Local state for profile picture URL
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(Dio());
    _initializeControllers();
  }

  void _initializeControllers() {
    final parsedName = _parseNameParts(widget.profile?.name ?? '');
    _lastNameController = TextEditingController(text: parsedName['lastName']);
    _firstNameController = TextEditingController(text: parsedName['firstName']);
    _middleInitialController = TextEditingController(
      text: parsedName['middleInitial'],
    );
    _phoneController = TextEditingController(text: widget.profile?.phone ?? '');
    _bioController = TextEditingController(text: widget.profile?.bio ?? '');
    _addressController = TextEditingController(
      text: widget.profile?.address ?? '',
    );
    _cityController = TextEditingController(text: widget.profile?.city ?? '');
    _zipCodeController = TextEditingController(
      text: widget.profile?.zipCode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.profile?.country ?? '',
    );
    _dateOfBirthController = TextEditingController(
      text: widget.profile?.dateOfBirth ?? '',
    );
    _selectedGender = widget.profile?.gender;
    _selectedLanguage = widget.profile?.preferredLanguage ?? 'en';
    _notificationsEnabled = widget.profile?.notificationsEnabled ?? true;

    // ✅ FIX: Initialize local picture URL from passed-in profile
    _profilePictureUrl = widget.profile?.profilePictureUrl;
  }

  Map<String, String> _parseNameParts(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return {'lastName': '', 'firstName': '', 'middleInitial': ''};
    }

    if (trimmed.contains(',')) {
      final commaIndex = trimmed.indexOf(',');
      final lastName = trimmed.substring(0, commaIndex).trim();
      final rightSide = trimmed.substring(commaIndex + 1).trim();
      final tokens = rightSide
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .toList();

      String firstName = '';
      String middleInitial = '';

      if (tokens.isNotEmpty) {
        final lastToken = tokens.last.replaceAll('.', '');
        if (tokens.length > 1 && RegExp(r'^[A-Za-z]$').hasMatch(lastToken)) {
          middleInitial = lastToken.toUpperCase();
          firstName = tokens.sublist(0, tokens.length - 1).join(' ');
        } else {
          firstName = tokens.join(' ');
        }
      }

      return {
        'lastName': lastName,
        'firstName': firstName,
        'middleInitial': middleInitial,
      };
    }

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return {'lastName': '', 'firstName': parts.first, 'middleInitial': ''};
    }

    return {
      'lastName': parts.last,
      'firstName': parts.sublist(0, parts.length - 1).join(' '),
      'middleInitial': '',
    };
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.profile?.dateOfBirth != null
          ? DateTime.parse(widget.profile!.dateOfBirth!)
          : DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      _dateOfBirthController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate);
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_isUploadingPicture) return;

    bool isDialogShown = false;
    try {
      if (mounted) {
        setState(() => _isUploadingPicture = true);
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) {
        if (mounted) {
          setState(() => _isUploadingPicture = false);
        }
        return;
      }

      // Validate image
      final validationError = await ImageUploadService.validateImage(image);
      if (validationError != null) {
        if (mounted) {
          setState(() => _isUploadingPicture = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show uploading dialog
      if (mounted) {
        isDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Compressing and uploading...'),
              ],
            ),
          ),
        );
      }

      // Compress image
      List<int> uploadBytes;
      try {
        uploadBytes = await ImageUploadService.compressImage(image);
      } catch (_) {
        // Fallback to original file if compression fails
        uploadBytes = await image.readAsBytes();
      }

      // Log size reduction
      final originalSize = await image.length();
      final compressedSize = uploadBytes.length;
      final sizeReduction = ((1 - compressedSize / originalSize) * 100)
          .toStringAsFixed(1);

      debugPrint(
        'Image compressed: ${ImageUploadService.getFileSizeString(originalSize)} -> '
        '${ImageUploadService.getFileSizeString(compressedSize)} ($sizeReduction% reduction)',
      );

      // ✅ FIX: Capture the returned image URL
      final imageUrl = await _profileService.uploadProfilePicture(
        image,
        uploadBytes: uploadBytes,
      );

      if (mounted) {
        if (isDialogShown && Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        // ✅ FIX: Update local state with the new URL so the avatar re-renders
        setState(() {
          _isUploadingPicture = false;
          _profilePictureUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (isDialogShown && Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        setState(() => _isUploadingPicture = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final middleInitial = _middleInitialController.text.trim().toUpperCase();

    if (lastName.isEmpty || firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Last name and first name are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (middleInitial.isNotEmpty &&
        !RegExp(r'^[A-Za-z]$').hasMatch(middleInitial)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Middle initial must be a single letter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _profileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        middleInitial: middleInitial.isEmpty ? null : middleInitial,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        zipCode: _zipCodeController.text.isEmpty
            ? null
            : _zipCodeController.text,
        country: _countryController.text.isEmpty
            ? null
            : _countryController.text,
        dateOfBirth: _dateOfBirthController.text.isEmpty
            ? null
            : _dateOfBirthController.text,
        gender: _selectedGender,
        preferredLanguage: _selectedLanguage,
        notificationsEnabled: _notificationsEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    // ✅ FIX: Use local _profilePictureUrl instead of widget.profile
                    backgroundImage: _profilePictureUrl != null
                        ? NetworkImage(_profilePictureUrl!)
                        : null,
                    child: _profilePictureUrl == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isUploadingPicture
                        ? null
                        : _uploadProfilePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _isUploadingPicture ? 'Uploading...' : 'Change Picture',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.badge_outlined,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _middleInitialController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: InputDecoration(
                      labelText: 'MI',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      counterText: '',
                    ),
                    onChanged: (value) {
                      final upper = value.toUpperCase();
                      if (value != upper) {
                        _middleInitialController.value =
                            _middleInitialController.value.copyWith(
                              text: upper,
                              selection: TextSelection.collapsed(
                                offset: upper.length,
                              ),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info,
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Gender',
              value: _selectedGender,
              items: const ['male', 'female', 'other'],
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 12),
            _buildDateField(
              controller: _dateOfBirthController,
              label: 'Date of Birth',
              onTap: _selectDate,
            ),
            const SizedBox(height: 24),

            // Address Information
            _buildSectionTitle('Address Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _cityController,
              label: 'City',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _zipCodeController,
              label: 'Zip Code',
              icon: Icons.mail,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _countryController,
              label: 'Country',
              icon: Icons.public,
            ),
            const SizedBox(height: 24),

            // Preferences
            _buildSectionTitle('Preferences'),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Preferred Language',
              value: _selectedLanguage,
              items: const ['en', 'es', 'fr', 'de'],
              displayItems: const ['English', 'Spanish', 'French', 'German'],
              onChanged: (value) {
                setState(() => _selectedLanguage = value);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
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
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        counterText: maxLength != null ? null : '',
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        enabled: false,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    List<String>? displayItems,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.arrow_drop_down),
      ),
      items: items.asMap().entries.map((entry) {
        return DropdownMenuItem(
          value: entry.value,
          child: Text(displayItems?[entry.key] ?? entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
