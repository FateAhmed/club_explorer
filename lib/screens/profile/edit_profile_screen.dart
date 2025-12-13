import 'dart:io';
import 'package:explorify/components/theme_button.dart';
import 'package:explorify/components/theme_field.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/utils/Validations.dart';
import 'package:explorify/utils/Loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: authController.userName);
    emailController = TextEditingController(text: authController.userEmail);
    phoneController = TextEditingController(
      text: authController.userData['phone']?.toString() ?? '',
    );
    addressController = TextEditingController(
      text: authController.userData['address']?.toString() ?? '',
    );

    // Load existing profile image if available
    final existingImage = authController.userProfileImage;
    if (existingImage.isNotEmpty && File(existingImage).existsSync()) {
      _selectedImage = File(existingImage);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary1.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary1,
                  ),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary1.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.primary1,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select an existing photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || authController.userProfileImage.isNotEmpty)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: AppColors.error,
                    ),
                  ),
                  title: const Text('Remove Photo'),
                  subtitle: const Text('Use initials instead'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                    authController.updateProfileImage('');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    LoadingDialog.show(context);

    // Save image path if selected
    if (_selectedImage != null) {
      await authController.updateProfileImage(_selectedImage!.path);
    }

    final success = await authController.updateProfile(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Get.back();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage.value),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitials() {
    final name = nameController.text.isNotEmpty ? nameController.text : authController.userName;
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: _selectedImage != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_selectedImage!),
                )
              : CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary1,
                  child: Text(
                    _getInitials(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary1,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimens.hPadding20,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppDimens.sizebox20,

                  // Avatar with camera icon
                  _buildAvatar(),

                  const SizedBox(height: 8),
                  Text(
                    'Tap to change photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textsecondary,
                    ),
                  ),

                  AppDimens.sizebox30,

                  // Full Name
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AppDimens.sizebox10,
                  CustomTextFormField(
                    title: 'Enter your full name',
                    controller: nameController,
                    focusNode: FocusNode(),
                    validator: (e) => validateName(e),
                  ),

                  AppDimens.sizebox20,

                  // Email (Read-only)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AppDimens.sizebox10,
                  CustomTextFormField(
                    title: 'Email address',
                    controller: emailController,
                    focusNode: FocusNode(),
                    readOnly: true,
                    validator: (e) => null,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Email cannot be changed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textsecondary,
                        ),
                      ),
                    ),
                  ),

                  AppDimens.sizebox20,

                  // Phone
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AppDimens.sizebox10,
                  CustomTextFormField(
                    title: 'Enter your phone number',
                    controller: phoneController,
                    focusNode: FocusNode(),
                    textInputType: TextInputType.phone,
                    validator: (e) => null,
                  ),

                  AppDimens.sizebox20,

                  // Address
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AppDimens.sizebox10,
                  CustomTextFormField(
                    title: 'Enter your address',
                    controller: addressController,
                    focusNode: FocusNode(),
                    validator: (e) => null,
                  ),

                  AppDimens.sizebox40,

                  // Save Button
                  Obx(() => ThemeButton(
                        text: authController.isLoading.value ? 'Saving...' : 'Save Changes',
                        onpress: authController.isLoading.value ? null : _saveProfile,
                      )),

                  AppDimens.sizebox20,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
