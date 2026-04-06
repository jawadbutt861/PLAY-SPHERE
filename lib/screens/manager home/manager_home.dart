import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/ground_service.dart';
import '../../services/booking_service.dart';
import '../../services/notification_service.dart';
import 'manager_profile.dart';
import 'manager_notifications.dart';
import 'manager_my_venues.dart';
import 'add_venue_screen.dart';
import 'manager_book_for_customer.dart';

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────
class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});
  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _todayBookings = [];
  List<Map<String, dynamic>> _myGrounds = [];
  StreamSubscription? _bookingSub;
  StreamSubscription? _groundSub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _bookingSub = BookingService.getTodayBookings(_uid).listen((b) {
        if (mounted) setState(() => _todayBookings = b);
      });
      _groundSub = GroundService.getManagerGrounds(_uid).listen((g) {
        if (mounted) setState(() => _myGrounds = g);
      });
    }
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    _groundSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final managerName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Manager';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
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
                        Text(managerName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text(DateFormat('EEE, d MMM').format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions — 2x2 equal grid
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _actionCard(
                      context,
                      'My Venues',
                      'Manage grounds',
                      Icons.stadium_rounded,
                      AppTheme.primaryGradient,
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ManagerMyVenues())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionCard(
                      context,
                      'Regular Bookings',
                      'View regular bookings',
                      Icons.event_rounded,
                      const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF9500)]),
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ManagerAllBookings())),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _actionCard(
                      context,
                      'Add New Venue',
                      'Register a new ground',
                      Icons.add_location_alt_rounded,
                      AppTheme.secondaryGradient,
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AddVenueScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionCard(
                      context,
                      'Tournament Bookings',
                      'View by tournament',
                      Icons.emoji_events_rounded,
                      const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)]),
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ManagerTournamentBookings())),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Book for Customer — full width
            _actionCard(
              context,
              'Book for Customer',
              'Walk-in or phone booking',
              Icons.person_add_rounded,
              const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerBookForCustomer())),
            ),
            const SizedBox(height: 24),

            // Today's Bookings
            Text("Today's Bookings",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _todayBookings.isEmpty
                ? _emptyBox(context, "No bookings today",
                    "Bookings for today will appear here")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _todayBookings.length,
                    itemBuilder: (_, i) =>
                        _bookingTile(context, _todayBookings[i]),
                  ),
            const SizedBox(height: 24),

            // Quick Stats — page ke end mein
            Row(
              children: [
                Expanded(
                    child: _statCard('${_myGrounds.length}', 'My Venues',
                        Icons.stadium_rounded, AppTheme.primaryColor)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                        '${_todayBookings.length}',
                        "Today's Bookings",
                        Icons.event_available_rounded,
                        AppTheme.successColor)),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _actionCard(BuildContext context, String title, String sub,
      IconData icon, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(sub,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _bookingTile(BuildContext context, Map<String, dynamic> b) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.sports_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b['groundName'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${b['slot']} • ${b['userName'] ?? b['userEmail'] ?? ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: (b['status'] == 'completed'
                      ? AppTheme.primaryColor
                      : AppTheme.successColor)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Text(
              b['status'] == 'completed' ? 'Completed' : 'Confirmed',
              style: TextStyle(
                  color: b['status'] == 'completed'
                      ? AppTheme.primaryColor
                      : AppTheme.successColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _emptyBox(BuildContext context, String title, String sub) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(Icons.event_busy_rounded,
            size: 44, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(sub,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// ALL BOOKINGS
// ─────────────────────────────────────────────
class ManagerAllBookings extends StatefulWidget {
  const ManagerAllBookings({super.key});
  @override
  State<ManagerAllBookings> createState() => _ManagerAllBookingsState();
}

class _ManagerAllBookingsState extends State<ManagerAllBookings> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = BookingService.getManagerBookings(_uid).listen((b) {
        if (mounted) setState(() { _bookings = b; _loading = false; });
      }, onError: (_) { if (mounted) setState(() => _loading = false); });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(
          title: 'Regular Bookings', gradient: AppTheme.secondaryGradient),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_rounded,
                          size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('No bookings yet',
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.where((b) => b['isTournament'] != true).length,
                  itemBuilder: (_, i) {
                    final regularBookings = _bookings.where((b) => b['isTournament'] != true).toList();
                    final b = regularBookings[i];
                    final imageUrls =
                        (b['imageUrls'] as List?)?.cast<String>() ?? [];
                    return ModernCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(20)),
                          child: SizedBox(
                            width: 80,
                            height: 90,
                            child: imageUrls.isNotEmpty
                                ? Image.network(imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imgPlaceholder(colorScheme))
                                : _imgPlaceholder(colorScheme),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b['groundName'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  _row(Icons.person_outline,
                                      b['userName'] ?? b['userEmail'] ?? '', theme),
                                  _row(Icons.calendar_today_outlined,
                                      b['date'] ?? '', theme),
                                  _row(Icons.access_time_outlined,
                                      b['slot'] ?? '', theme),
                                  _row(Icons.payment_outlined,
                                      b['payment'] ?? '', theme),
                                ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppTheme.successColor
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              b['status'] ?? 'confirmed',
                              style: const TextStyle(
                                  color: AppTheme.successColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
    );
  }

  Widget _imgPlaceholder(ColorScheme c) => Container(
      color: c.surfaceContainerHighest,
      child: Icon(Icons.sports, color: c.onSurfaceVariant, size: 32));

  Widget _row(IconData icon, String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Expanded(
              child: Text(text,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}

// ─────────────────────────────────────────────
// TOURNAMENT BOOKINGS (grouped + collapsible)
// ─────────────────────────────────────────────
class ManagerTournamentBookings extends StatefulWidget {
  const ManagerTournamentBookings({super.key});
  @override
  State<ManagerTournamentBookings> createState() => _ManagerTournamentBookingsState();
}

class _ManagerTournamentBookingsState extends State<ManagerTournamentBookings> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  StreamSubscription? _sub;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = BookingService.getManagerBookings(_uid).listen((b) {
        if (mounted) setState(() {
          _bookings = b.where((x) => x['isTournament'] == true).toList();
          _loading = false;
        });
      }, onError: (_) { if (mounted) setState(() => _loading = false); });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  /// Group bookings by tournamentId
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final b in _bookings) {
      final tid = b['tournamentId'] as String? ?? 'Unknown';
      map.putIfAbsent(tid, () => []).add(b);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(
          title: 'Tournament Bookings',
          gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)])),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : grouped.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('No tournament bookings',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: grouped.entries.map((entry) {
                    final tid = entry.key;
                    final tBookings = entry.value;
                    final tName = tBookings.first['tournamentName'] as String? ?? tid;
                    final isExpanded = _expanded.contains(tid);
                    final allCancelled = tBookings.every((b) => b['status'] == 'cancelled');

                    return ModernCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Header — tap to expand/collapse
                          InkWell(
                            borderRadius: isExpanded
                                ? const BorderRadius.vertical(top: Radius.circular(20))
                                : BorderRadius.circular(20),
                            onTap: () => setState(() {
                              if (isExpanded) _expanded.remove(tid);
                              else _expanded.add(tid);
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: allCancelled
                                    ? const LinearGradient(colors: [
                                        Color(0xFF9E9E9E), Color(0xFF757575)])
                                    : const LinearGradient(colors: [
                                        Color(0xFF8B5CF6), Color(0xFFA855F7)]),
                                borderRadius: isExpanded
                                    ? const BorderRadius.vertical(
                                        top: Radius.circular(20))
                                    : BorderRadius.circular(20),
                              ),
                              child: Row(children: [
                                const Icon(Icons.emoji_events_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(
                                          '${tBookings.length} slot${tBookings.length == 1 ? '' : 's'}',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                                if (allCancelled)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Cancelled',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                const SizedBox(width: 8),
                                Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white),
                              ]),
                            ),
                          ),
                          // Expanded booking rows
                          if (isExpanded)
                            ...tBookings.map((b) => _bookingRow(b, theme, colorScheme)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  Widget _bookingRow(Map<String, dynamic> b, ThemeData theme, ColorScheme colorScheme) {
    final imageUrls = (b['imageUrls'] as List?)?.cast<String>() ?? [];
    final isCancelled = b['status'] == 'cancelled';
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4))),
      ),
      child: Row(children: [
        ClipRRect(
          child: SizedBox(
            width: 70,
            height: 80,
            child: imageUrls.isNotEmpty
                ? Image.network(imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder(colorScheme))
                : _imgPlaceholder(colorScheme),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b['groundName'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              _infoRow(Icons.person_outline,
                  b['userName'] ?? b['userEmail'] ?? '', theme),
              _infoRow(Icons.calendar_today_outlined, b['date'] ?? '', theme),
              _infoRow(Icons.access_time_outlined, b['slot'] ?? '', theme),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: isCancelled
                    ? AppTheme.errorColor.withValues(alpha: 0.15)
                    : AppTheme.successColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              isCancelled ? 'Cancelled' : (b['status'] ?? 'confirmed'),
              style: TextStyle(
                  color: isCancelled
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _imgPlaceholder(ColorScheme c) => Container(
      color: c.surfaceContainerHighest,
      child: Icon(Icons.sports, color: c.onSurfaceVariant, size: 28));

  Widget _infoRow(IconData icon, String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Row(children: [
          Icon(icon, size: 11, color: AppTheme.primaryColor),
          const SizedBox(width: 3),
          Expanded(
              child: Text(text,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}

// ─────────────────────────────────────────────
// ANALYTICS
// ─────────────────────────────────────────────
class ManagerAnalytics extends StatefulWidget {
  const ManagerAnalytics({super.key});
  @override
  State<ManagerAnalytics> createState() => _ManagerAnalyticsState();
}

class _ManagerAnalyticsState extends State<ManagerAnalytics> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  String _period = 'Weekly';
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _myGrounds = [];
  StreamSubscription? _sub;
  StreamSubscription? _groundSub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = BookingService.getManagerBookings(_uid).listen(
          (b) { if (mounted) setState(() => _allBookings = b); });
      _groundSub = GroundService.getManagerGrounds(_uid).listen(
          (g) { if (mounted) setState(() => _myGrounds = g); });
    }
  }

  @override
  void dispose() { _sub?.cancel(); _groundSub?.cancel(); super.dispose(); }

  int get _total => _allBookings.length;
  int get _confirmed => _allBookings
      .where((b) => b['status'] == 'confirmed' || b['status'] == 'completed').length;
  int get _cancelled => _allBookings.where((b) => b['status'] == 'cancelled').length;
  int get _completed => _allBookings.where((b) => b['status'] == 'completed').length;

  int _priceOf(Map<String, dynamic> b) {
    final stored = b['price'];
    if (stored != null) return (stored as num).toInt();
    final gid = b['groundId'] as String? ?? '';
    final slot = b['slot'] as String? ?? '';
    final g = _myGrounds.firstWhere((x) => x['id'] == gid, orElse: () => {});
    if (g.isEmpty) return 0;
    final s = slot.toLowerCase();
    int h = 9;
    if (s.startsWith('2pm')) h = 14;
    else if (!s.startsWith('full') && !s.startsWith('9am')) {
      final p = s.split(RegExp(r'[-\s]')).first.trim();
      if (p.endsWith('am')) h = int.tryParse(p.replaceAll('am', '')) ?? 9;
      else if (p.endsWith('pm')) { final x = int.tryParse(p.replaceAll('pm', '')) ?? 12; h = x == 12 ? 12 : x + 12; }
    }
    final isDay = h >= 6 && h < 18;
    return isDay ? (g['dayPrice'] as num?)?.toInt() ?? 0 : (g['nightPrice'] as num?)?.toInt() ?? 0;
  }

  int get _revenue => _allBookings
      .where((b) => b['status'] == 'confirmed' || b['status'] == 'completed')
      .fold(0, (s, b) => s + _priceOf(b));

  List<double> _bookingValues() {
    final now = DateTime.now();
    if (_period == 'Weekly') {
      return List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        final ds = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
        return _allBookings.where((b) => b['date'] == ds).length.toDouble();
      });
    } else if (_period == 'Monthly') {
      return List.generate(now.month, (i) {
        final m = i + 1;
        return _allBookings.where((b) {
          final d = b['date'] as String? ?? '';
          return d.length >= 7 && int.tryParse(d.substring(5, 7)) == m
              && int.tryParse(d.substring(0, 4)) == now.year;
        }).length.toDouble();
      });
    } else {
      return List.generate(5, (i) {
        final yr = now.year - 4 + i;
        return _allBookings.where((b) {
          final d = b['date'] as String? ?? '';
          return d.length >= 4 && int.tryParse(d.substring(0, 4)) == yr;
        }).length.toDouble();
      });
    }
  }

  List<double> _revenueValues() {
    final now = DateTime.now();
    final confirmed = _allBookings
        .where((b) => b['status'] == 'confirmed' || b['status'] == 'completed').toList();
    if (_period == 'Weekly') {
      return List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        final ds = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
        return confirmed.where((b) => b['date'] == ds).fold(0.0, (s, b) => s + _priceOf(b));
      });
    } else if (_period == 'Monthly') {
      return List.generate(now.month, (i) {
        final m = i + 1;
        return confirmed.where((b) {
          final d = b['date'] as String? ?? '';
          return d.length >= 7 && int.tryParse(d.substring(5, 7)) == m
              && int.tryParse(d.substring(0, 4)) == now.year;
        }).fold(0.0, (s, b) => s + _priceOf(b));
      });
    } else {
      return List.generate(5, (i) {
        final yr = now.year - 4 + i;
        return confirmed.where((b) {
          final d = b['date'] as String? ?? '';
          return d.length >= 4 && int.tryParse(d.substring(0, 4)) == yr;
        }).fold(0.0, (s, b) => s + _priceOf(b));
      });
    }
  }

  Map<String, int> get _paymentBreakdown {
    final map = <String, int>{};
    for (final b in _allBookings) {
      if (b['status'] == 'cancelled') continue;
      final p = b['payment'] as String? ?? 'Other';
      map[p] = (map[p] ?? 0) + 1;
    }
    return map;
  }

  String _xLabel(int i) {
    final now = DateTime.now();
    if (_period == 'Weekly') return DateFormat('E').format(now.subtract(Duration(days: 6 - i)));
    if (_period == 'Monthly') return DateFormat('MMM').format(DateTime(now.year, i + 1));
    return '${now.year - 4 + i}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookingVals = _bookingValues();
    final revenueVals = _revenueValues();
    final payBreakdown = _paymentBreakdown;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats
          Row(children: [
            Expanded(child: _statCard('$_total', 'Total', Icons.calendar_month_rounded, AppTheme.primaryGradient)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('$_confirmed', 'Confirmed', Icons.check_circle_rounded, AppTheme.accentGradient)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _statCard('$_cancelled', 'Cancelled', Icons.cancel_rounded, AppTheme.secondaryGradient)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('$_completed', 'Completed', Icons.done_all_rounded,
                const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]))),
          ]),
          const SizedBox(height: 10),
          _statCard('PKR $_revenue', 'Total Revenue', Icons.attach_money_rounded,
              const LinearGradient(colors: [Color(0xFF34C759), Color(0xFF00D9FF)])),
          const SizedBox(height: 24),

          // Booking Trends
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Booking Trends', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            _periodSelector(),
          ]),
          const SizedBox(height: 12),
          _chartCard(_buildBarChart(bookingVals, AppTheme.primaryGradient)),
          const SizedBox(height: 20),

          // Revenue Trends
          Text('Revenue Trends (PKR)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _chartCard(_buildBarChart(revenueVals,
              const LinearGradient(colors: [Color(0xFF34C759), Color(0xFF00D9FF)]))),
          const SizedBox(height: 20),

          // Payment Methods
          if (payBreakdown.isNotEmpty) ...[
            Text('Payment Methods', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _paymentPieCard(payBreakdown, colorScheme),
          ],
        ]),
      ),
    );
  }

  Widget _periodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _periodBtn('Weekly'), _periodBtn('Monthly'), _periodBtn('Yearly'),
      ]),
    );
  }

  Widget _periodBtn(String p) {
    final sel = _period == p;
    return GestureDetector(
      onTap: () => setState(() => _period = p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            gradient: sel ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(8)),
        child: Text(p, style: TextStyle(
            fontSize: 11,
            fontWeight: sel ? FontWeight.bold : FontWeight.w500,
            color: sel ? Colors.white : AppTheme.textSecondary)),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Gradient gradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 8, offset: const Offset(0, 4))]),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FittedBox(fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
          Text(label, style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }

  Widget _chartCard(Widget chart) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20)),
      child: chart,
    );
  }

  Widget _buildBarChart(List<double> values, Gradient gradient) {
    if (values.isEmpty) return const Center(child: Text('No data'));
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final barW = _period == 'Yearly' ? 28.0 : _period == 'Monthly' ? 14.0 : 22.0;
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY < 1 ? 5 : maxY * 1.3,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (g, _, rod, __) => BarTooltipItem(
            rod.toY >= 1000
                ? 'PKR ${(rod.toY / 1000).toStringAsFixed(1)}k'
                : rod.toY.toInt().toString(),
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 28,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_xLabel(v.toInt()),
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 38,
          getTitlesWidget: (v, _) => Text(
            v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toInt().toString(),
            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
        )),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.textSecondary.withValues(alpha: 0.1), strokeWidth: 1)),
      barGroups: List.generate(values.length, (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: values[i], gradient: gradient, width: barW,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        )],
      )),
    ));
  }

  Widget _paymentPieCard(Map<String, int> data, ColorScheme colorScheme) {
    const colors = [Color(0xFF1A659E), Color(0xFF26A69A), Color(0xFFFF9500), Color(0xFF8B5CF6)];
    final entries = data.entries.toList();
    final total = entries.fold(0, (s, e) => s + e.value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        SizedBox(
          width: 140, height: 140,
          child: PieChart(PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 36,
            sections: List.generate(entries.length, (i) {
              final pct = total > 0 ? entries[i].value / total * 100 : 0.0;
              return PieChartSectionData(
                value: entries[i].value.toDouble(),
                color: colors[i % colors.length],
                radius: 44,
                title: '${pct.toStringAsFixed(0)}%',
                titleStyle: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }),
          )),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 12, height: 12,
                  decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text(entries[i].key,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Text('${entries[i].value}', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold,
                  color: colors[i % colors.length])),
            ]),
          )),
        )),
      ]),
    );
  }
}
// ─────────────────────────────────────────────
class Managerhome extends StatefulWidget {
  const Managerhome({super.key});
  @override
  State<Managerhome> createState() => _ManagerhomeState();
}

class _ManagerhomeState extends State<Managerhome> {
  int _index = 0;
  int _unreadCount = 0;
  StreamSubscription? _notifSub;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final List<String> _titles = ['Dashboard', 'Analytics'];
  final List<Widget> _pages = [
    const ManagerDashboard(),
    const ManagerAnalytics(),
  ];

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _notifSub = NotificationService.getUnreadCount(_uid).listen((count) {
        if (mounted) setState(() => _unreadCount = count);
      });
    }
  }

  @override
  void dispose() { _notifSub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: ModernAppBar(
          title: _titles[_index],
          gradient: AppTheme.secondaryGradient,
          leading: IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManagerProfile())),
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ManagerNotifications())),
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text('$_unreadCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        body: _pages[_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (v) => setState(() => _index = v),
          backgroundColor: AppTheme.secondaryColor,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
          ],
        ),
      ),
    );
  }
}
