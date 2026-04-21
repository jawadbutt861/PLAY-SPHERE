import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';

class ManagerProfile extends StatefulWidget {
  const ManagerProfile({super.key});

  @override
  State<ManagerProfile> createState() => _ManagerProfileState();
}

class _ManagerProfileState extends State<ManagerProfile> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _imageUrl;
  String _userName = 'Manager';
  String _userEmail = '';
  bool _isUploadingImage = false;
  bool _isVerified = false;
  // Payment info
  Map<String, String> _paymentInfo = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    User? user = _authService.currentUser;
    
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'Manager';
        _userEmail = user.email ?? '';
      });
      
      // Load Cloudinary image URL from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? imageUrl = prefs.getString('imageUrl_${user.uid}');
      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() { _imageUrl = imageUrl; });
      }

      // Check verification status from Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            _isVerified = doc.data()?['isVerified'] == true;
            final pi = doc.data()?['paymentInfo'];
            if (pi is Map) {
              _paymentInfo = Map<String, String>.from(
                  pi.map((k, v) => MapEntry(k.toString(), v.toString())));
            }
          });
        }
      } catch (_) {}
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
          _isUploadingImage = true;
        });

        // Upload to Cloudinary
        final url = await CloudinaryService.uploadImage(
          File(pickedFile.path),
          folder: 'profiles',
        );

        if (url != null) {
          User? user = _authService.currentUser;
          if (user != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('imageUrl_${user.uid}', url);
            setState(() {
              _imageUrl = url;
              _isUploadingImage = false;
            });
          }
          _showSnackBar('Profile picture updated!', AppTheme.successColor, Icons.check_circle_outline);
        } else {
          setState(() => _isUploadingImage = false);
          _showSnackBar('Failed to upload image', AppTheme.errorColor, Icons.error_outline);
        }
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      _showSnackBar('Failed to pick image', AppTheme.errorColor, Icons.error_outline);
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

                            if (context.mounted) {
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

  void _showPaymentInfoDialog() {
    final bankCtrl = TextEditingController(text: _paymentInfo['bank'] ?? '');
    final accountCtrl = TextEditingController(text: _paymentInfo['account'] ?? '');
    final nameCtrl = TextEditingController(text: _paymentInfo['accountName'] ?? '');
    final instructionsCtrl = TextEditingController(text: _paymentInfo['instructions'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.account_balance_wallet_rounded, color: AppTheme.secondaryColor),
          SizedBox(width: 10),
          Text('Payment Info'),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'This info will be shown to users when you confirm their booking.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bankCtrl,
              decoration: const InputDecoration(
                labelText: 'Bank / Service Name',
                hintText: 'e.g. JazzCash, HBL, Easypaisa',
                prefixIcon: Icon(Icons.account_balance_rounded,
                    color: AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: accountCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Account / Phone Number',
                hintText: 'e.g. 03001234567',
                prefixIcon: Icon(Icons.numbers_rounded,
                    color: AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                hintText: 'e.g. Ahmed Khan',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instructionsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Instructions (optional)',
                hintText: 'e.g. Send screenshot after payment',
                prefixIcon: Icon(Icons.info_outline_rounded,
                    color: AppTheme.secondaryColor),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          GradientButton(
            text: 'Save',
            gradient: AppTheme.secondaryGradient,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            onPressed: () async {
              Navigator.pop(ctx);
              final uid = _authService.currentUser?.uid;
              if (uid != null) {
                final info = {
                  'bank': bankCtrl.text.trim(),
                  'account': accountCtrl.text.trim(),
                  'accountName': nameCtrl.text.trim(),
                  'instructions': instructionsCtrl.text.trim(),
                };
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({'paymentInfo': info});
                if (mounted) setState(() { _paymentInfo = info; });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          GradientButton(
            text: 'Logout',
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog
              await _authService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    parentContext, '/', (route) => false);
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

  void _showDeleteAccountDialog() {
    final TextEditingController passwordController = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [
              Icon(Icons.delete_forever_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete Account'),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will permanently delete your account and all associated data. This action cannot be undone.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.red),
                  ),
                  obscureText: true,
                  enabled: !isDeleting,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () {
                  passwordController.dispose();
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              ),
              isDeleting
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (passwordController.text.isEmpty) {
                          _showSnackBar('Please enter your password',
                              AppTheme.errorColor, Icons.error_outline);
                          return;
                        }
                        setDialogState(() => isDeleting = true);
                        try {
                          final user = _authService.currentUser;
                          if (user != null && user.email != null) {
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: passwordController.text,
                            );
                            await user.reauthenticateWithCredential(credential);
                            // Delete Firestore data
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .delete();
                            await user.delete();
                            if (context.mounted) {
                              passwordController.dispose();
                              Navigator.of(context).pop();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/', (route) => false);
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => isDeleting = false);
                          String msg = 'Failed to delete account';
                          if (e.code == 'wrong-password') {
                            msg = 'Incorrect password';
                          }
                          _showSnackBar(msg, AppTheme.errorColor, Icons.error_outline);
                        } catch (_) {
                          setDialogState(() => isDeleting = false);
                          _showSnackBar('An error occurred',
                              AppTheme.errorColor, Icons.error_outline);
                        }
                      },
                      child: const Text('Delete'),
                    ),
            ],
          );
        },
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
                            backgroundImage: _imageUrl != null
                                ? NetworkImage(_imageUrl!) as ImageProvider
                                : _image != null
                                    ? FileImage(_image!)
                                    : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                            backgroundColor: Colors.white,
                            child: _isUploadingImage
                                ? const CircularProgressIndicator(color: Colors.white)
                                : null,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Verified',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Payment Info',
                      subtitle: _paymentInfo['bank']?.isNotEmpty == true
                          ? '${_paymentInfo['bank']} • ${_paymentInfo['account']}'
                          : 'Set your payment details for bookings',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      onTap: _showPaymentInfoDialog,
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
                  ModernCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildProfileOption(
                      context,
                      icon: Icons.delete_forever_rounded,
                      title: 'Delete Account',
                      subtitle: 'Permanently remove your account',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
                      ),
                      onTap: _showDeleteAccountDialog,
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
