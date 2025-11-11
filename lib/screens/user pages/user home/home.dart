import 'dart:async';
import 'package:flutter/material.dart';
import '../../../main.dart';

class AutoScrollingImageRow extends StatefulWidget {
  final String category;
  final List<String> imageAssets;

  const AutoScrollingImageRow({
    super.key,
    required this.category,
    required this.imageAssets,
  });

  @override
  State<AutoScrollingImageRow> createState() => _AutoScrollingImageRowState();
}

class _AutoScrollingImageRowState extends State<AutoScrollingImageRow> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= widget.imageAssets.length) {
          nextPage = 0; // Loop back to start
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageAssets.length,
            itemBuilder: (context, index) {
              return _buildStyledImage(widget.imageAssets[index], colorScheme);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageAssets.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              height: 6.0,
              width: _currentPage == index ? 20.0 : 6.0,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? AppTheme.primaryColor 
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledImage(String asset, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            Image.asset(
              asset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Define categories and their image assets (5 images each)
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Top Cricket Grounds',
      'images': [
        'assets/images/c1.jpeg',
        'assets/images/c1.jpeg',
        'assets/images/c1.jpeg',
        'assets/images/c1.jpeg',
        
      ],
    },
    {
      'name': 'Top Football Grounds',
      'images': [
        'assets/images/f1.jpg',
        'assets/images/f1.jpg',
        'assets/images/f1.jpg',
        'assets/images/f1.jpg',
        
      ],
    },
    {
      'name': 'Top Tennis Courts',
      'images': [
        'assets/images/t1.jpeg',
        'assets/images/t1.jpeg',
        'assets/images/t1.jpeg',
        'assets/images/t1.jpeg',
        
      ],
    },
    {
      'name': 'Top Basketball Courts',
      'images': [
        'assets/images/b1.webp',
        'assets/images/b1.webp',
        'assets/images/b1.webp',
        'assets/images/b1.webp',
        
      ],
    },
    {
      'name': 'Top Hockey Grounds',
      'images': [
        'assets/images/h1.webp',
        'assets/images/h1.webp',
        'assets/images/h1.webp',
        'assets/images/h1.webp',
        'assets/images/h1.webp',
      ],
    },
    {
      'name': 'Top Volleyball Courts',
      'images': [
        'assets/images/v1.jpg',
        'assets/images/v1.jpg',
        'assets/images/v1.jpg',
        'assets/images/v1.jpg',
        
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/bg2.jpg'),
                          fit: BoxFit.cover,
                          opacity: 0.3,
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          "Book Your Perfect",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Sports Venue",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Find and book the best sports venues in your area",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: "Book Venue",
                          icon: Icons.sports_soccer_rounded,
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.white],
                          ),
                          textStyle: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/Categories');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.favorite_rounded,
                      title: "Favourites",
                      subtitle: "Saved venues",
                      gradient: AppTheme.accentGradient,
                      onTap: () => Navigator.pushNamed(context, '/Favourite'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.history_rounded,
                      title: "History",
                      subtitle: "Past bookings",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.pushNamed(context, '/BookingHistory'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Categories Section
          ...categories.map((category) => SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category['name'],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                AutoScrollingImageRow(
                  category: category['name'],
                  imageAssets: List<String>.from(category['images']),
                ),
              ],
            ),
          )),
          
          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 120), // Extra space for bottom nav
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
