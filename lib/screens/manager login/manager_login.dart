import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

class ManagerLogin extends StatefulWidget {
  const ManagerLogin({super.key});

  @override
  State<ManagerLogin> createState() => _ManagerLoginState();
}

class _ManagerLoginState extends State<ManagerLogin> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController eMail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService _authService = AuthService();

  bool showPass = true;
  bool isLoading = false;

  @override
  void dispose() {
    eMail.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!formkey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final userCredential = await _authService.signInWithEmail(
      email: eMail.text,
      password: password.text,
      context: context,
    );

    if (userCredential == null) {
      setState(() => isLoading = false);
      return;
    }

    // Role check — manager account user login mein use nahi ho sakta
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    final role = doc.data()?['role'] as String? ?? '';

    if (role != 'manager') {
      await _authService.signOut();
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text('This account is registered as a Player. Please use Player login.')),
          ]),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
      return;
    }

    setState(() => isLoading = false);
    if (mounted) Navigator.pushReplacementNamed(context, "/ManagerHome");
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    final userCredential = await _authService.signInWithGoogle(
        context: context, role: 'manager');

    if (userCredential == null) {
      setState(() => isLoading = false);
      return;
    }

    // Role check
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    final role = doc.data()?['role'] as String? ?? '';

    if (role != 'manager') {
      await _authService.signOut();
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text('This account is registered as a Player. Please use Player login.')),
          ]),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
      return;
    }

    setState(() => isLoading = false);
    if (mounted) Navigator.pushReplacementNamed(context, "/ManagerHome");
  }

  Future<void> _handleForgotPassword() async {
    if (eMail.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please enter your email address first',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await _authService.sendPasswordResetEmail(
      email: eMail.text,
      context: context,
    );
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.02),
                          
                          // Logo and Welcome Section
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08,
                              vertical: size.height * 0.03,
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
                                  width: size.width * 0.18,
                                  height: size.width * 0.18,
                                  constraints: const BoxConstraints(
                                    minWidth: 60,
                                    maxWidth: 80,
                                    minHeight: 60,
                                    maxHeight: 80,
                                  ),
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
                                    size: size.width * 0.09,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  "PlaySphere",
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.07,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  "Manager Portal",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: size.width * 0.04,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.03),
                          
                          // Login Form Card
                          ModernCard(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.all(size.width * 0.06),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Manager Sign In",
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: size.width * 0.055,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 0.025),
                    
                                TextFormField(
                                  controller: eMail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppTheme.secondaryColor,
                                    ),
                                    hintText: 'Enter your email',
                                    labelText: 'Email',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter email";
                                    }
                                    if (!value.contains('@')) {
                                      return "Invalid email";
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: size.height * 0.02),
                                
                                TextFormField(
                                  controller: password,
                                  obscureText: showPass,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppTheme.secondaryColor,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showPass = !showPass;
                                        });
                                      },
                                      icon: Icon(
                                        showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    hintText: 'Enter your password',
                                    labelText: 'Password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter password";
                                    }
                                    if (value.length < 8) {
                                      return "Password must be 8+ characters";
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: size.height * 0.015),
                                
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: isLoading ? null : _handleForgotPassword,
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: AppTheme.secondaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: size.width * 0.035,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: size.height * 0.025),
                                
                                isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                                        ),
                                      )
                                    : GradientButton(
                                        text: "Sign In",
                                        icon: Icons.login_rounded,
                                        gradient: AppTheme.secondaryGradient,
                                        onPressed: _handleLogin,
                                        width: double.infinity,
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: size.width * 0.042,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                
                                SizedBox(height: size.height * 0.02),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey[300])),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: size.width * 0.033,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey[300])),
                                  ],
                                ),

                                SizedBox(height: size.height * 0.02),

                                // Google Sign-In Button
                                GradientButton(
                                  text: 'Continue with Google',
                                  icon: Icons.g_mobiledata,
                                  gradient: AppTheme.secondaryGradient,
                                  onPressed: isLoading ? null : _handleGoogleSignIn,
                                  width: double.infinity,
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.042,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: size.height * 0.02),

                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: size.width * 0.035,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/ManagerSignUp');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        "Sign Up",
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
