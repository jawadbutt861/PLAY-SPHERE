import 'dart:async';
import 'package:f_y_p/screens/user%20pages/booking/booking.dart';
import 'package:f_y_p/screens/user%20pages/tournament/tournament.dart';
import 'package:f_y_p/screens/user%20pages/user%20home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/notification_service.dart';
import '../../providers/app_provider.dart';
import '../../services/reminder_service.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> with TickerProviderStateMixin {
  int index = 0;
  int _unreadCount = 0;
  StreamSubscription? _notifSub;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late AnimationController _animationController;
  late AnimationController _navAnimationController;

  List<Widget> userpages = [
    const Home(),
    const Booked(),
    const Tournament()
  ];

  List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: "Home",
      title: "PlaySphere",
    ),
    NavigationItem(
      icon: Icons.calendar_month_rounded,
      activeIcon: Icons.calendar_month,
      label: "Bookings",
      title: "My Bookings",
    ),
    NavigationItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      label: "Tournaments",
      title: "Tournaments",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();

    if (_uid != null) {
      _notifSub = NotificationService.getUserUnreadCount(_uid).listen((c) {
        if (mounted) setState(() => _unreadCount = c);
      });
      // Provider init karo
      context.read<AppProvider>().init(_uid);
      ReminderService.startChecking(_uid);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navAnimationController.dispose();
    _notifSub?.cancel();
    ReminderService.stopChecking();
    super.dispose();
  }

  void _onTabTapped(int newIndex) {
    if (newIndex != index) {
      _animationController.reset();
      _navAnimationController.forward();
      setState(() {
        index = newIndex;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 50),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.pushNamed(context, '/Profile');
                        },
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Title Section
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          height: 110,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Notifications Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.pushNamed(context, '/Search');
                        },
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Notifications Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.pushNamed(context, '/Notifications');
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            if (_unreadCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                      minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '$_unreadCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(index),
            child: userpages[index],
          ),
        ),
        bottomNavigationBar: _buildModernBottomNav(context),
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navigationItems.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              final isSelected = index == itemIndex;
              
              return Expanded(
                child: _buildNavItem(itemIndex, item, isSelected, colorScheme),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int itemIndex, NavigationItem item, bool isSelected, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _onTabTapped(itemIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String title;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.title,
  });
}