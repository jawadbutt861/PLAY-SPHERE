import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../services/ground_service.dart';
import 'favourite/booking_helper.dart';

// ── Auto-scrolling ground cards per category ──────────────
class TopGroundsRow extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> grounds; // sorted by booking count

  const TopGroundsRow({super.key, required this.category, required this.grounds});

  @override
  State<TopGroundsRow> createState() => _TopGroundsRowState();
}

class _TopGroundsRowState extends State<TopGroundsRow> {
  final PageController _ctrl = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (widget.grounds.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_ctrl.hasClients) return;
        final next = (_page + 1) % widget.grounds.length;
        _ctrl.animateToPage(next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut);
      });
    }
    _ctrl.addListener(() {
      final p = _ctrl.page?.round() ?? 0;
      if (p != _page && mounted) setState(() => _page = p);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.grounds.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text('No venues yet',
              style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.grounds.length,
            itemBuilder: (_, i) => _groundCard(widget.grounds[i], colorScheme),
          ),
        ),
        if (widget.grounds.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.grounds.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _page == i ? 20 : 6,
                decoration: BoxDecoration(
                  color: _page == i
                      ? AppTheme.primaryColor
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _groundCard(Map<String, dynamic> g, ColorScheme colorScheme) {
    final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
    final bookingCount = g['bookingCount'] as int? ?? 0;
    final rating = (g['avgRating'] as num?)?.toDouble() ?? 0;
    final reviewCount = (g['reviewCount'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            imageUrls.isNotEmpty
                ? Image.network(imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.sports,
                            size: 48, color: colorScheme.onSurfaceVariant)))
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.sports,
                        size: 48, color: colorScheme.onSurfaceVariant)),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            // Ground info
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g['name'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((g['location'] ?? '').isNotEmpty)
                          Row(children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(g['location'],
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                      ],
                    ),
                  ),
                  // Badges — rating + booking count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Rating badge
                      if (rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${rating.toStringAsFixed(1)} ($reviewCount)',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                      if (rating > 0) const SizedBox(height: 4),
                      // Booking count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.bookmark_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('$bookingCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Screen ────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _db = FirebaseFirestore.instance;
  // category -> list of grounds sorted by booking count
  Map<String, List<Map<String, dynamic>>> _topGrounds = {};
  bool _loading = true;
  StreamSubscription? _groundsSub;

  static const _categories = [
    'Cricket', 'Football', 'Tennis', 'Basketball', 'Hockey', 'Volleyball'
  ];

  @override
  void initState() {
    super.initState();
    _groundsSub = GroundService.getGroundsByCategory('ALL').listen((grounds) {
      if (mounted) _loadTopGrounds(grounds);
    });
  }

  @override
  void dispose() {
    _groundsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadTopGrounds(List<Map<String, dynamic>> grounds) async {
    // Count bookings per ground
    final Map<String, int> bookingCounts = {};
    try {
      final snap = await _db
          .collection('bookings')
          .where('status', whereIn: ['confirmed', 'completed'])
          .get();
      for (final doc in snap.docs) {
        final gid = doc.data()['groundId'] as String? ?? '';
        if (gid.isNotEmpty) bookingCounts[gid] = (bookingCounts[gid] ?? 0) + 1;
      }
    } catch (_) {}

    // Group by category, attach count, sort — sirf top 1
    final Map<String, List<Map<String, dynamic>>> result = {};
    for (final cat in _categories) {
      final catGrounds = grounds
          .where((g) => g['category'] == cat)
          .map((g) => {
                ...g,
                'bookingCount': bookingCounts[g['id'] as String? ?? ''] ?? 0,
              })
          .toList();
      catGrounds.sort((a, b) =>
          (b['bookingCount'] as int).compareTo(a['bookingCount'] as int));
      result[cat] = catGrounds.take(1).toList(); // only top 1
    }

    if (mounted) setState(() { _topGrounds = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Greeting
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.waving_hand_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13)),
                      Text(
                        FirebaseAuth.instance.currentUser?.displayName ??
                            FirebaseAuth.instance.currentUser?.email ??
                            'Player',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('EEE, d MMM').format(DateTime.now()),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12),
                ),
              ]),
            ),
          ),

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
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text("Book Your Perfect",
                            style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text("Sports Venue",
                            style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                            "Find and book the best sports venues in your area",
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9))),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: "Book Venue",
                          gradient: const LinearGradient(
                              colors: [Colors.white, Colors.white]),
                          textStyle: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/Categories'),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _quickCard(context,
                        icon: Icons.favorite_rounded,
                        title: "Favourites",
                        subtitle: "Saved venues",
                        gradient: AppTheme.accentGradient,
                        onTap: () => Navigator.pushNamed(context, '/Favourite')),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _quickCard(context,
                        icon: Icons.history_rounded,
                        title: "History",
                        subtitle: "Past bookings",
                        gradient: const LinearGradient(colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFFA855F7)
                        ]),
                        onTap: () =>
                            Navigator.pushNamed(context, '/BookingHistory')),
                  ),
                ],
              ),
            ),
          ),

          // Top Grounds per category
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            ..._categories.map((cat) {
              final grounds = _topGrounds[cat] ?? [];
              if (grounds.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              final g = grounds.first;
              final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
              final colorScheme = Theme.of(context).colorScheme;

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Row(children: [
                        Container(
                          width: 4, height: 24,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Top $cat Venue',
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface)),
                      ]),
                    ),
                    // Single top ground card
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrls.isNotEmpty
                                ? Image.network(imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        color: colorScheme.surfaceContainerHighest,
                                        child: Icon(Icons.sports,
                                            size: 48,
                                            color: colorScheme.onSurfaceVariant)))
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(Icons.sports,
                                        size: 48,
                                        color: colorScheme.onSurfaceVariant)),
                            // Gradient overlay
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                            ),
                            // Book Now button
                            Positioned(
                              bottom: 14, left: 14, right: 14,
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(g['name'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      if ((g['location'] ?? '').isNotEmpty)
                                        Row(children: [
                                          const Icon(Icons.location_on_rounded,
                                              size: 13, color: Colors.white70),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(g['location'],
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ]),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => BookingHelper.showBookingDialog(context, g),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3)),
                                      ],
                                    ),
                                    child: const Text('Book Now',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _quickCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Gradient gradient,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 106,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const Spacer(),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
