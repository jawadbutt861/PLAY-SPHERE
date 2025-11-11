import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';

class ManagerSignup extends StatefulWidget {
  const ManagerSignup({super.key});

  @override
  State<ManagerSignup> createState() => _ManagerSignupState();
}

class _ManagerSignupState extends State<ManagerSignup> {
  final formKey = GlobalKey<FormState>();
  bool showPass = true;

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cnic = TextEditingController();
  final TextEditingController mobileNo = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController venueName = TextEditingController();
  final TextEditingController venueLocation = TextEditingController();

  final ImagePicker picker = ImagePicker();
  List<XFile> selectedImages = [];

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images.take(5).toList(); // limit to 5
        });
      }
    } catch (e) {
      // Handle error picking images
      debugPrint("Error picking images: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.secondaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Welcome Section
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                              size: 40,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "PlaySphere",
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Manager Registration",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Signup Form Card
                    ModernCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Create Manager Account",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          TextFormField(
                            controller: fullName,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: AppTheme.secondaryColor,
                              ),
                              hintText: 'Enter your full name',
                              labelText: 'Full Name',
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppTheme.secondaryColor,
                              ),
                              hintText: 'Enter your email address',
                              labelText: 'Email',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter email';
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: cnic,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.contact_mail_outlined,
                                color: AppTheme.secondaryColor,
                              ),
                              hintText: 'Enter your CNIC',
                              labelText: 'CNIC',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter CNIC';
                              if (v.length != 13) return 'CNIC must be 13 digits';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: mobileNo,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppTheme.secondaryColor,
                              ),
                              hintText: 'e.g., 03124567890',
                              labelText: 'Mobile Number',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter mobile number';
                              if (v.length != 11) return 'Mobile number must be 11 digits';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: venueName,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.business_outlined,
                                color: AppTheme.secondaryColor,
                              ),
                              hintText: 'Enter venue name',
                              labelText: 'Venue Name',
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter venue name' : null,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: venueLocation,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.secondaryColor,
                              ),
                              hintText: 'Enter venue location',
                              labelText: 'Venue Location',
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter venue location' : null,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: password,
                            obscureText: showPass,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
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
                              hintText: 'Enter your password',
                              labelText: 'Password',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter password';
                              if (v.length < 8) return 'Password must be at least 8 characters';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),

                          // Image Upload Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upload Venue Images (max 5)",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
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
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 48,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Tap to upload venue images",
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ...selectedImages.map((img) => Container(
                                          width: 80,
                                          height: 80,
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
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppTheme.secondaryColor,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.add_a_photo_rounded,
                                                color: AppTheme.secondaryColor,
                                                size: 32,
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
                          
                          const SizedBox(height: 32),
                          
                          GradientButton(
                            text: "Create Account",
                            icon: Icons.admin_panel_settings_rounded,
                            gradient: AppTheme.secondaryGradient,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (selectedImages.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.warning, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Please upload at least 1 venue image'),
                                        ],
                                      ),
                                      backgroundColor: AppTheme.warningColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pushReplacementNamed(context, '/ManagerLogIn');
                              }
                            },
                            width: double.infinity,
                            height: 56,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/ManagerLogIn');
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.w600,
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
              ),
            ),
          ),
        ),
      ),
    );
  }


}
