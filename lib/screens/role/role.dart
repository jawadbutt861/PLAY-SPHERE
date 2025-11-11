import 'package:flutter/material.dart';
import '../../main.dart';

class Role extends StatefulWidget {

  const Role({super.key,});

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Welcome Section
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.sports_soccer_rounded,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "PlaySphere",
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Choose Your Role",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select how you want to use PlaySphere",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // Role Selection Cards
                  Column(
                    children: [
                      // Player Role Card
                      _buildRoleCard(
                        context,
                        title: "Player",
                        subtitle: "Find and book venues for your next match",
                        icon: Icons.sports_rounded,
                        gradient: AppTheme.primaryGradient,
                        onTap: () => Navigator.pushReplacementNamed(context, '/UserLogIn'),
                        features: [
                          "Browse available venues",
                          "Book sports facilities",
                          "Join tournaments",
                          "Track booking history",
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Manager Role Card
                      _buildRoleCard(
                        context,
                        title: "Manager",
                        subtitle: "List your venue and manage bookings",
                        icon: Icons.admin_panel_settings_rounded,
                        gradient: AppTheme.secondaryGradient,
                        onTap: () => Navigator.pushReplacementNamed(context, '/ManagerLogIn'),
                        features: [
                          "List your sports venues",
                          "Manage bookings",
                          "Track revenue",
                          "Upload venue photos",
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required List<String> features,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ModernCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Icon with gradient background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Features List
              Column(
                children: features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button
              GradientButton(
                text: "Continue as $title",
                icon: Icons.arrow_forward_rounded,
                gradient: gradient,
                onPressed: onTap,
                width: double.infinity,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
