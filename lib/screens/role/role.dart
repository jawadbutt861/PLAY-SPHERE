import 'package:flutter/material.dart';
import '../../main.dart';

class Role extends StatefulWidget {
  const Role({super.key});

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: AppTheme.heroGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.03),
                            
                            // Animated Logo and Welcome Section
                            _buildHeroSection(theme),
                            
                            SizedBox(height: size.height * 0.05),

                            // Role Selection Cards
                            _buildRoleCard(
                              context,
                              title: "Player",
                              subtitle: "Find and book venues for your next match",
                              icon: Icons.sports_soccer_rounded,
                              gradient: AppTheme.primaryGradient,
                              onTap: () => Navigator.pushReplacementNamed(context, '/UserLogIn'),
                              features: [
                                "Browse available venues",
                                "Book sports facilities instantly",
                                "Join exciting tournaments",
                                "Track your booking history",
                              ],
                              delay: 200,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildRoleCard(
                              context,
                              title: "Manager",
                              subtitle: "List your venue and manage bookings",
                              icon: Icons.business_rounded,
                              gradient: AppTheme.secondaryGradient,
                              onTap: () => Navigator.pushReplacementNamed(context, '/ManagerLogIn'),
                              features: [
                                "List your sports venues",
                                "Manage bookings efficiently",
                                "Track revenue & analytics",
                                "Upload stunning venue photos",
                              ],
                              delay: 400,
                            ),
                            
                            SizedBox(height: size.height * 0.03),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final size = MediaQuery.of(context).size;
        return Transform.scale(
          scale: value,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            constraints: const BoxConstraints(
              minWidth: 200,
              maxWidth: 300,
              minHeight: 200,
              maxHeight: 300,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
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
    required int delay,
  }) {
    final theme = Theme.of(context);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: _RoleCardContent(
              title: title,
              subtitle: subtitle,
              icon: icon,
              gradient: gradient,
              onTap: onTap,
              features: features,
              theme: theme,
            ),
          ),
        );
      },
    );
  }
}

class _RoleCardContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final List<String> features;
  final ThemeData theme;

  const _RoleCardContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.features,
    required this.theme,
  });

  @override
  State<_RoleCardContent> createState() => _RoleCardContentState();
}

class _RoleCardContentState extends State<_RoleCardContent> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) {
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Gradient Accent Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(gradient: widget.gradient),
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
                      child: Column(
                        children: [
                          // Icon with gradient background
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            constraints: const BoxConstraints(
                              minWidth: 70,
                              maxWidth: 90,
                              minHeight: 70,
                              maxHeight: 90,
                            ),
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.gradient.colors.first.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: MediaQuery.of(context).size.width * 0.1,
                              color: Colors.white,
                            ),
                          ),
                          
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          
                          // Title
                          Text(
                            widget.title,
                            style: widget.theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: widget.theme.colorScheme.onSurface,
                              fontSize: MediaQuery.of(context).size.width * 0.065,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          
                          // Subtitle
                          Text(
                            widget.subtitle,
                            style: widget.theme.textTheme.bodyLarge?.copyWith(
                              color: widget.theme.colorScheme.onSurfaceVariant,
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 28),
                          
                          // Features List
                          ...widget.features.asMap().entries.map((entry) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 400 + (entry.key * 100)),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            gradient: widget.gradient,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: widget.theme.textTheme.bodyLarge?.copyWith(
                                              color: widget.theme.colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          
                          const SizedBox(height: 32),
                          
                          // Action Button
                          GradientButton(
                            text: "Continue as ${widget.title}",
                            icon: Icons.arrow_forward_rounded,
                            gradient: widget.gradient,
                            onPressed: widget.onTap,
                            width: double.infinity,
                            height: 72,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
