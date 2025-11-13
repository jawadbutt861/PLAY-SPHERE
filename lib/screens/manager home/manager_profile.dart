import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

class ManagerProfile extends StatefulWidget {
  const ManagerProfile({super.key});

  @override
  State<ManagerProfile> createState() => _ManagerProfileState();
}

class _ManagerProfileState extends State<ManagerProfile> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _userName = 'Manager';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Load user data from Firebase Auth
    User? user = _authService.currentUser;
    
    if (user != null) {
      setState(() {
        // Load name and email from Firebase Auth
        _userName = user.displayName ?? 'Manager';
        _userEmail = user.email ?? '';
      });
      
      // Load profile image from SharedPreferences (stored per user)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? imagePath = prefs.getString('imagePath_${user.uid}');
      if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
        setState(() {
          _image = File(imagePath);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        
        // Save image path to SharedPreferences
        User? user = _authService.currentUser;
        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('imagePath_${user.uid}', pickedFile.path);
          
          _showSnackBar(
            'Profile picture updated!',
            AppTheme.successColor,
            Icons.check_circle_outline,
          );
        }
      }
    } catch (e) {
      _showSnackBar(
        'Failed to pick image',
        AppTheme.errorColor,
        Icons.error_outline,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool isChanging = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.lock_rounded, color: AppTheme.secondaryColor),
                SizedBox(width: 12),
                Text('Change Password'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.secondaryColor),
                  ),
                  obscureText: true,
                  enabled: !isChanging,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.lock_reset, color: AppTheme.secondaryColor),
                    helperText: 'Minimum 8 characters',
                  ),
                  obscureText: true,
                  enabled: !isChanging,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.check_circle_outline, color: AppTheme.secondaryColor),
                  ),
                  obscureText: true,
                  enabled: !isChanging,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isChanging ? null : () {
                  oldPasswordController.dispose();
                  newPasswordController.dispose();
                  confirmPasswordController.dispose();
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              ),
              isChanging
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : GradientButton(
                      text: 'Change',
                      onPressed: () async {
                        // Validate inputs
                        if (oldPasswordController.text.isEmpty) {
                          _showSnackBar('Please enter current password', AppTheme.errorColor, Icons.error_outline);
                          return;
                        }

                        if (newPasswordController.text.length < 8) {
                          _showSnackBar('New password must be at least 8 characters', AppTheme.errorColor, Icons.error_outline);
                          return;
                        }

                        if (newPasswordController.text != confirmPasswordController.text) {
                          _showSnackBar('Passwords do not match!', AppTheme.errorColor, Icons.error_outline);
                          return;
                        }

                        setDialogState(() => isChanging = true);

                        try {
                          // Re-authenticate user with current password
                          User? user = _authService.currentUser;
                          if (user != null && user.email != null) {
                            AuthCredential credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: oldPasswordController.text,
                            );

                            await user.reauthenticateWithCredential(credential);
                            await user.updatePassword(newPasswordController.text);

                            if (mounted) {
                              oldPasswordController.dispose();
                              newPasswordController.dispose();
                              confirmPasswordController.dispose();
                              Navigator.of(context).pop();
                              _showSnackBar('Password changed successfully!', AppTheme.successColor, Icons.check_circle_outline);
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => isChanging = false);
                          String message = 'Failed to change password';
                          if (e.code == 'wrong-password') {
                            message = 'Current password is incorrect';
                          } else if (e.code == 'weak-password') {
                            message = 'New password is too weak';
                          } else if (e.code == 'requires-recent-login') {
                            message = 'Please sign in again to change password';
                          }
                          _showSnackBar(message, AppTheme.errorColor, Icons.error_outline);
                        } catch (e) {
                          setDialogState(() => isChanging = false);
                          _showSnackBar('An error occurred', AppTheme.errorColor, Icons.error_outline);
                        }
                      },
                      gradient: AppTheme.secondaryGradient,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          GradientButton(
            text: 'Logout',
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Sign out from Firebase
              await _authService.signOut();

              if (mounted) {
                // Close loading dialog
                Navigator.pop(context);
                
                // Navigate to role selection and clear stack
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                
                // Show success message
                _showSnackBar(
                  'Logged out successfully',
                  AppTheme.successColor,
                  Icons.check_circle_outline,
                );
              }
            },
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(
        title: 'Manager Profile',
        gradient: AppTheme.secondaryGradient,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Gradient Background
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _image != null 
                                ? FileImage(_image!) 
                                : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // Profile Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ModernCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildProfileOption(
                      context,
                      icon: Icons.business_rounded,
                      title: 'My Venues',
                      subtitle: 'Manage your venues',
                      gradient: AppTheme.secondaryGradient,
                      onTap: () {
                        // Navigate to venues
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Venues feature coming soon')),
                        );
                      },
                    ),
                  ),

                  ModernCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildProfileOption(
                      context,
                      icon: Icons.lock_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      gradient: AppTheme.accentGradient,
                      onTap: _showChangePasswordDialog,
                    ),
                  ),
                  ModernCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildProfileOption(
                      context,
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      onTap: _showLogoutDialog,
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
