import 'package:f_y_p/screens/user%20pages/booking/booking.dart';
import 'package:f_y_p/screens/user%20pages/search/search_screen.dart';
import 'package:f_y_p/screens/user%20pages/tournament/tournament.dart';
import 'package:f_y_p/screens/user%20pages/user%20home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/connectivity_service.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> with TickerProviderStateMixin {
  int index = 0;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late AnimationController _animationController;
  late AnimationController _navAnimationController;

  final List<Widget> userpages = [
    const Home(),
    const SearchScreen(),
    const Booked(),
    const Tournament(),
  ];

  final List<NavigationItem> navigationItems = [
    NavigationItem(icon: Icons.home_rounded, activeIcon: Icons.home, label: "Home", title: "PlaySphere"),
    NavigationItem(icon: Icons.search_rounded, activeIcon: Icons.search, label: "Search", title: "Search"),
    NavigationItem(icon: Icons.calendar_month_rounded, activeIcon: Icons.calendar_month, label: "Bookings", title: "Bookings"),
    NavigationItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: "Tournaments", title: "Tournaments"),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _navAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int newIndex) {
    if (newIndex != index) {
      _animationController.reset();
      _navAnimationController.forward();
      setState(() => index = newIndex);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide auth-scoped providers here — only alive while user is logged in
    if (_uid == null) return const SizedBox.shrink();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingsProvider(uid: _uid)),
        ChangeNotifierProvider(create: (_) => NotificationsProvider(uid: _uid)),
      ],
      child: _UserMainScaffold(
        index: index,
        userpages: userpages,
        navigationItems: navigationItems,
        onTabTapped: _onTabTapped,
        animationController: _animationController,
      ),
    );
  }
}

// Separate scaffold widget so it can consume providers cleanly
class _UserMainScaffold extends StatelessWidget {
  final int index;
  final List<Widget> userpages;
  final List<NavigationItem> navigationItems;
  final ValueChanged<int> onTabTapped;
  final AnimationController animationController;

  const _UserMainScaffold({
    required this.index,
    required this.userpages,
    required this.navigationItems,
    required this.onTabTapped,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unreadCount = context.watch<NotificationsProvider>().unreadCount;

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) onTabTapped(0);
      },
      child: ConnectivityWrapper(
        child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBody: true,
        appBar: index == 0
            ? PreferredSize(
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
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pushNamed(context, '/Profile'),
                              icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                height: 110,
                                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pushNamed(context, '/Notifications'),
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
              )
            : index == 2
                ? ModernAppBar(
                    title: ' ',
                    leading: BackButton(
                      color: Colors.white,
                      onPressed: () => onTabTapped(0),
                    ),
                  )
                : ModernAppBar(title: navigationItems[index].title),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: Container(key: ValueKey(index), child: userpages[index]),
        ),
        bottomNavigationBar: _buildBottomNav(context, colorScheme),
      ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navigationItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabTapped(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : null,
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
                ),
              );
            }).toList(),
          ),
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
  const NavigationItem({required this.icon, required this.activeIcon, required this.label, required this.title});
}
