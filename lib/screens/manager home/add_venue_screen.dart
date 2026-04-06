import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../services/cloudinary_service.dart';
import '../../services/ground_service.dart';
import '../../services/user_service.dart';
import '../map_location_picker.dart';
import 'package:latlong2/latlong.dart';

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});
  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String? _selectedCategory;
  List<XFile> _selectedImages = [];
  LatLng? _selectedLatLng;
  bool _isLoading = false;

  static const List<String> _categories = [
    'Cricket', 'Football', 'Tennis', 'Basketball', 'Hockey', 'Volleyball',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _selectedImages = picked.take(5).toList());
    }
  }

  Future<void> _openMap() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(builder: (_) => const MapLocationPicker()),
    );
    if (result != null) {
      setState(() {
        _locationCtrl.text = result.address;
        _selectedLatLng = result.latLng;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _snack('Please select a sport category', AppTheme.warningColor);
      return;
    }
    if (_selectedImages.isEmpty) {
      _snack('Upload at least 1 venue image', AppTheme.warningColor);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _snack('Not logged in', AppTheme.errorColor);
        return;
      }

      // Upload images to Cloudinary
      List<String> imageUrls = [];
      try {
        imageUrls = await CloudinaryService.uploadMultipleImages(
          _selectedImages.map((x) => File(x.path)).toList(),
          folder: 'venues',
        );
      } catch (_) {}

      // Create ground in Firestore
      await GroundService.createGround(
        managerId: user.uid,
        managerName: user.displayName ?? '',
        managerEmail: user.email ?? '',
        venueName: _nameCtrl.text.trim(),
        venueLocation: _locationCtrl.text.trim(),
        category: _selectedCategory!,
        imageUrls: imageUrls,
        latitude: _selectedLatLng?.latitude,
        longitude: _selectedLatLng?.longitude,
      );

      // Update manager's user doc with latest venue info
      await UserService.saveManager(
        uid: user.uid,
        fullName: user.displayName ?? '',
        email: user.email ?? '',
        mobile: '',
        cnic: '',
        venueName: _nameCtrl.text.trim(),
        venueLocation: _locationCtrl.text.trim(),
        category: _selectedCategory!,
        imageUrls: imageUrls,
      );

      if (mounted) {
        _snack('Venue added successfully!', AppTheme.successColor);
        Navigator.pop(context);
      }
    } catch (e) {
      _snack('Something went wrong. Try again.', AppTheme.errorColor);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(
        title: 'Add New Venue',
        gradient: AppTheme.secondaryGradient,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Name
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Venue Name',
                  hintText: 'Enter venue name',
                  prefixIcon: Icon(Icons.business_outlined,
                      color: AppTheme.secondaryColor),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter venue name' : null,
              ),
              const SizedBox(height: 16),

              // Location — map picker
              GestureDetector(
                onTap: _openMap,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _locationCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'Tap to pick on map',
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          color: AppTheme.secondaryColor),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.secondaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Map',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Pick a location' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Sport Category',
                  hintText: 'Select sport type',
                  prefixIcon: Icon(Icons.sports_outlined,
                      color: AppTheme.secondaryColor),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 20),

              // Image Upload
              Text('Venue Images (max 5)',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryColor)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(children: [
                  if (_selectedImages.isEmpty)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Column(children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 44,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 6),
                        Text('Tap to upload images',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ]),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedImages.map((img) => Stack(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: FileImage(File(img.path)),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                      _selectedImages.remove(img)),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      if (_selectedImages.length < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppTheme.secondaryColor, width: 2),
                            ),
                            child: const Icon(Icons.add_a_photo_rounded,
                                color: AppTheme.secondaryColor, size: 26),
                          ),
                        ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // Submit button
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              AppTheme.secondaryColor)))
                  : GradientButton(
                      text: 'Create Venue',
                      icon: Icons.add_business_rounded,
                      gradient: AppTheme.secondaryGradient,
                      width: double.infinity,
                      height: 56,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      onPressed: _submit,
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
