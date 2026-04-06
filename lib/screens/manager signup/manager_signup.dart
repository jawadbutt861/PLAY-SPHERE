import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/ground_service.dart';
import '../../services/user_service.dart';
import '../map_location_picker.dart';
import 'package:latlong2/latlong.dart';

class ManagerSignup extends StatefulWidget {
  const ManagerSignup({super.key});

  @override
  State<ManagerSignup> createState() => _ManagerSignupState();
}

class _ManagerSignupState extends State<ManagerSignup> {
  final formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  bool showPass = true;
  bool isLoading = false;

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cnic = TextEditingController();
  final TextEditingController mobileNo = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController venueName = TextEditingController();
  final TextEditingController venueLocation = TextEditingController();

  final ImagePicker picker = ImagePicker();
  List<XFile> selectedImages = [];
  String? selectedCategory;
  LatLng? _selectedLatLng;

  static const List<String> _categories = [
    'Cricket',
    'Football',
    'Tennis',
    'Basketball',
    'Hockey',
    'Volleyball',
  ];

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    cnic.dispose();
    mobileNo.dispose();
    password.dispose();
    venueName.dispose();
    venueLocation.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(builder: (_) => const MapLocationPicker()),
    );
    if (result != null) {
      setState(() {
        venueLocation.text = result.address;
        _selectedLatLng = result.latLng;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      _showSnack('Please select a sport category', AppTheme.warningColor);
      return;
    }

    if (selectedImages.isEmpty) {
      _showSnack('Upload at least 1 venue image', AppTheme.warningColor);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Firebase Auth signup
      final userCredential = await _authService.signUpWithEmail(
        email: email.text.trim(),
        password: password.text.trim(),
        context: context,
      );

      if (userCredential == null) {
        // signUpWithEmail already shows error snackbar
        setState(() => isLoading = false);
        return;
      }

      final uid = userCredential.user!.uid;

      // 2. Firebase Auth display name update
      await _authService.updateProfile(displayName: fullName.text.trim());

      // 3. Cloudinary image upload (optional — agar fail ho to empty list se continue karo)
      List<String> venueImageUrls = [];
      try {
        venueImageUrls = await CloudinaryService.uploadMultipleImages(
          selectedImages.map((x) => File(x.path)).toList(),
          folder: 'venues',
        );
      } catch (_) {
        // Image upload fail — continue without images
      }

      // 4. Firestore mein manager data save karo
      await UserService.saveManager(
        uid: uid,
        fullName: fullName.text.trim(),
        email: email.text.trim(),
        mobile: mobileNo.text.trim(),
        cnic: cnic.text.trim(),
        venueName: venueName.text.trim(),
        venueLocation: venueLocation.text.trim(),
        category: selectedCategory!,
        imageUrls: venueImageUrls,
        latitude: _selectedLatLng?.latitude,
        longitude: _selectedLatLng?.longitude,
      );

      // 5. Ground create karo Firestore mein
      await GroundService.createGround(
        managerId: uid,
        managerName: fullName.text.trim(),
        managerEmail: email.text.trim(),
        venueName: venueName.text.trim(),
        venueLocation: venueLocation.text.trim(),
        category: selectedCategory!,
        imageUrls: venueImageUrls,
        latitude: _selectedLatLng?.latitude,
        longitude: _selectedLatLng?.longitude,
      );

      if (mounted) {
        _showSnack('Manager account created successfully!', AppTheme.successColor);
        // Directly dashboard pe navigate karo
        Navigator.pushReplacementNamed(context, '/ManagerHome');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Something went wrong. Please try again.', AppTheme.errorColor);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images.take(5).toList(); // limit to 5
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: AppTheme.secondaryGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.01),
                      
                      // Logo and Welcome Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: size.height * 0.025,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: size.width * 0.16,
                              height: size.width * 0.16,
                              constraints: const BoxConstraints(
                                minWidth: 60,
                                maxWidth: 75,
                                minHeight: 60,
                                maxHeight: 75,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                size: size.width * 0.08,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            SizedBox(height: size.height * 0.015),
                            Text(
                              "PlaySphere",
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * 0.065,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size.height * 0.008),
                            Text(
                              "Manager Registration",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: size.width * 0.038,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.025),
                      
                      // Signup Form Card
                      ModernCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.all(size.width * 0.055),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Create Manager Account",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontSize: size.width * 0.05,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            SizedBox(height: size.height * 0.02),

                            TextFormField(
                              controller: fullName,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: AppTheme.secondaryColor,
                                ),
                                hintText: 'Enter full name',
                                labelText: 'Full Name',
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            TextFormField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppTheme.secondaryColor,
                                ),
                                hintText: 'Enter email',
                                labelText: 'Email',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter email';
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            TextFormField(
                              controller: cnic,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.contact_mail_outlined,
                                  color: AppTheme.secondaryColor,
                                ),
                                hintText: 'Enter CNIC',
                                labelText: 'CNIC',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter CNIC';
                                if (v.length != 13) return 'Must be 13 digits';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            TextFormField(
                              controller: mobileNo,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: AppTheme.secondaryColor,
                                ),
                                hintText: 'e.g., 03124567890',
                                labelText: 'Mobile',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter mobile';
                                if (v.length != 11) return 'Must be 11 digits';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            TextFormField(
                              controller: venueName,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.business_outlined,
                                  color: AppTheme.secondaryColor,
                                ),
                                hintText: 'Enter venue name',
                                labelText: 'Venue Name',
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Enter venue' : null,
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            // Location field — map picker
                            GestureDetector(
                              onTap: _openMapPicker,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: venueLocation,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.location_on_outlined,
                                      color: AppTheme.secondaryColor,
                                    ),
                                    suffixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.secondaryGradient,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Map',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Tap to pick on map',
                                    labelText: 'Location',
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Pick a location' : null,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.sports_outlined, color: AppTheme.secondaryColor),
                                labelText: 'Sport Category',
                                hintText: 'Select sport type',
                              ),
                              items: _categories.map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              )).toList(),
                              onChanged: (val) => setState(() => selectedCategory = val),
                              validator: (v) => v == null ? 'Select a category' : null,
                            ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            TextFormField(
                              controller: password,
                              obscureText: showPass,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppTheme.secondaryColor,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => showPass = !showPass),
                                  icon: Icon(
                                    showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                hintText: 'Enter password',
                                labelText: 'Password',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter password';
                                if (v.length < 8) return 'Min 8 characters';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: size.height * 0.022),

                            // Image Upload Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Upload Venue Images (max 5)",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryColor,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.012),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      if (selectedImages.isEmpty)
                                        GestureDetector(
                                          onTap: pickImages,
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 40,
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Tap to upload images",
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                  fontSize: size.width * 0.035,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ...selectedImages.map((img) => Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: FileImage(File(img.path)),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )),
                                          if (selectedImages.length < 5)
                                            GestureDetector(
                                              onTap: pickImages,
                                              child: Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppTheme.secondaryColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.add_a_photo_rounded,
                                                  color: AppTheme.secondaryColor,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: size.height * 0.022),
                            
                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                                    ),
                                  )
                                : GradientButton(
                                    text: "Create Account",
                                    icon: Icons.admin_panel_settings_rounded,
                                    gradient: AppTheme.secondaryGradient,
                                    onPressed: _handleSignup,
                                    width: double.infinity,
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.042,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            
                            SizedBox(height: size.height * 0.018),
                            
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/ManagerLogIn');
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: size.width * 0.035,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
