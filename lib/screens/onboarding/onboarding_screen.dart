import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.sports_soccer_rounded,
      gradient: AppTheme.primaryGradient,
      title: 'Book Any Sport Venue',
      subtitle:
          'Cricket, Football, Tennis, Basketball and more — find and book the perfect venue in seconds.',
    ),
    _OnboardingPage(
      icon: Icons.calendar_today_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Real-Time Availability',
      subtitle:
          'See live slot availability, pick your time, and confirm your booking instantly — no calls needed.',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      gradient: AppTheme.accentGradient,
      title: 'Join Tournaments',
      subtitle:
          'Register for local sports tournaments, track brackets, and compete with players near you.',
    ),
    _OnboardingPage(
      icon: Icons.location_on_rounded,
      gradient: AppTheme.secondaryGradient,
      title: 'Find Venues Near You',
      subtitle:
          'Browse venues on the map, check prices, and get directions — all from one place.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Pages
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _PageContent(page: _pages[i], size: size),
            ),

            // Skip button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    32, 24, 32, MediaQuery.of(context).padding.bottom + 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot indicators
                    Row(
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next / Get Started button
                    GestureDetector(
                      onTap: _next,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLast ? 28 : 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                color: AppTheme.primaryVariant,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: AppTheme.primaryVariant,
                              size: 18,
                            ),
                          ],
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
    );
  }
}

// ── Single page content ───────────────────────────────────
class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  final Size size;
  const _PageContent({required this.page, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Icon circle
              Container(
                width: size.width * 0.45,
                height: size.width * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(page.icon, size: size.width * 0.22, color: Colors.white),
              ),
              const Spacer(flex: 1),
              // Title
              Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Subtitle
              Text(
                page.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────
class _OnboardingPage {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}
