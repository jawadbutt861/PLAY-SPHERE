import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/booking_service.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _allBookings = [];
  bool _loading = true;
  StreamSubscription? _sub;
  late TabController _tabController;

  // Filter: 'week' | 'month' | 'year'
  String _period = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_uid != null) {
      _sub = BookingService.getManagerBookings(_uid).listen((b) {
        if (mounted) setState(() { _allBookings = b; _loading = false; });
      }, onError: (_) { if (mounted) setState(() => _loading = false); });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────

  List<Map<String, dynamic>> get _completed =>
      _allBookings.where((b) => b['status'] == 'completed').toList();

  int get _totalRevenue => _completed.fold(0, (s, b) => s + ((b['price'] as num?)?.toInt() ?? 0));

  int get _totalBookings => _allBookings.where((b) => b['status'] != 'cancelled').length;

  int get _cancelledCount => _allBookings.where((b) => b['status'] == 'cancelled').length;

  double get _occupancyRate {
    if (_totalBookings + _cancelledCount == 0) return 0;
    return _totalBookings / (_totalBookings + _cancelledCount) * 100;
  }

  /// Revenue grouped by period label
  Map<String, int> _revenueByPeriod() {
    final now = DateTime.now();
    final map = <String, int>{};

    if (_period == 'week') {
      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final key = DateFormat('EEE').format(d); // Mon, Tue...
        map[key] = 0;
      }
      for (final b in _completed) {
        final date = _parseDate(b['date'] as String? ?? '');
        if (date == null) continue;
        if (now.difference(date).inDays > 6) continue;
        final key = DateFormat('EEE').format(date);
        map[key] = (map[key] ?? 0) + ((b['price'] as num?)?.toInt() ?? 0);
      }
    } else if (_period == 'month') {
      // Last 4 weeks
      for (int i = 3; i >= 0; i--) {
        final key = 'W${4 - i}';
        map[key] = 0;
      }
      for (final b in _completed) {
        final date = _parseDate(b['date'] as String? ?? '');
        if (date == null) continue;
        final diff = now.difference(date).inDays;
        if (diff > 27) continue;
        final weekNum = 4 - (diff ~/ 7);
        if (weekNum < 1 || weekNum > 4) continue;
        final key = 'W$weekNum';
        map[key] = (map[key] ?? 0) + ((b['price'] as num?)?.toInt() ?? 0);
      }
    } else {
      // Last 12 months
      for (int i = 11; i >= 0; i--) {
        final m = DateTime(now.year, now.month - i, 1);
        final key = DateFormat('MMM').format(m);
        map[key] = 0;
      }
      for (final b in _completed) {
        final date = _parseDate(b['date'] as String? ?? '');
        if (date == null) continue;
        final monthDiff = (now.year - date.year) * 12 + now.month - date.month;
        if (monthDiff > 11 || monthDiff < 0) continue;
        final key = DateFormat('MMM').format(date);
        map[key] = (map[key] ?? 0) + ((b['price'] as num?)?.toInt() ?? 0);
      }
    }
    return map;
  }

  /// Bookings per hour slot (peak hours heatmap)
  Map<String, int> _peakHours() {
    final map = <String, int>{};
    final slots = [
      '9am', '10am', '11am', '12pm', '1pm', '2pm',
      '3pm', '4pm', '5pm', '6pm', '7pm', '8pm', '9pm', '10pm', '11pm',
    ];
    for (final s in slots) { map[s] = 0; }

    for (final b in _allBookings.where((b) => b['status'] != 'cancelled')) {
      final slot = b['slot'] as String? ?? '';
      final hour = _extractStartHour(slot);
      if (hour != null) {
        final key = _hourLabel(hour);
        map[key] = (map[key] ?? 0) + 1;
      }
    }
    return map;
  }

  /// Category breakdown
  Map<String, int> _categoryBreakdown() {
    final map = <String, int>{};
    for (final b in _allBookings.where((b) => b['status'] != 'cancelled')) {
      final cat = b['groundCategory'] as String? ?? 'Other';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  DateTime? _parseDate(String s) {
    try {
      final parts = s.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) { return null; }
  }

  int? _extractStartHour(String slot) {
    try {
      final lower = slot.toLowerCase();
      if (lower.startsWith('9am to')) return 9;
      if (lower.startsWith('2pm to')) return 14;
      final dashIdx = lower.indexOf('-');
      if (dashIdx == -1) return null;
      final start = lower.substring(0, dashIdx).trim();
      if (start.endsWith('am')) {
        return int.parse(start.replaceAll('am', ''));
      } else if (start.endsWith('pm')) {
        final h = int.parse(start.replaceAll('pm', ''));
        return h == 12 ? 12 : h + 12;
      }
    } catch (_) {}
    return null;
  }

  String _hourLabel(int hour) {
    if (hour == 0) return '12am';
    if (hour < 12) return '${hour}am';
    if (hour == 12) return '12pm';
    return '${hour - 12}pm';
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: AppBar(
            title: const Text('Analytics',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Revenue'),
                Tab(icon: Icon(Icons.access_time_rounded), text: 'Peak Hours'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRevenueTab(theme, colorScheme),
                _buildPeakHoursTab(theme, colorScheme),
              ],
            ),
    );
  }

  Widget _buildRevenueTab(ThemeData theme, ColorScheme colorScheme) {
    final revenueData = _revenueByPeriod();
    final maxRevenue = revenueData.values.isEmpty
        ? 1
        : revenueData.values.reduce((a, b) => a > b ? a : b);
    final catData = _categoryBreakdown();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(children: [
            Expanded(child: _summaryCard('Total Revenue',
                'Rs ${NumberFormat('#,###').format(_totalRevenue)}',
                Icons.payments_rounded, AppTheme.successColor)),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard('Total Bookings',
                '$_totalBookings',
                Icons.event_available_rounded, AppTheme.primaryColor)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _summaryCard('Cancelled',
                '$_cancelledCount',
                Icons.cancel_rounded, AppTheme.errorColor)),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard('Occupancy',
                '${_occupancyRate.toStringAsFixed(1)}%',
                Icons.donut_large_rounded, AppTheme.accentColor)),
          ]),
          const SizedBox(height: 24),

          // Period filter
          Row(
            children: [
              Text('Revenue', style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              _periodChip('week', 'Week'),
              const SizedBox(width: 8),
              _periodChip('month', 'Month'),
              const SizedBox(width: 8),
              _periodChip('year', 'Year'),
            ],
          ),
          const SizedBox(height: 16),

          // Bar chart
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: revenueData.values.every((v) => v == 0)
                ? Center(child: Text('No revenue data',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)))
                : BarChart(
                    BarChartData(
                      maxY: maxRevenue.toDouble() * 1.2,
                      barGroups: revenueData.entries.toList().asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value.toDouble(),
                              gradient: AppTheme.primaryGradient,
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (v, _) => Text(
                              v == 0 ? '' : 'Rs${(v / 1000).toStringAsFixed(0)}k',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final keys = revenueData.keys.toList();
                              final idx = v.toInt();
                              if (idx < 0 || idx >= keys.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(keys[idx],
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: colorScheme.onSurfaceVariant)),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Category pie chart
          if (catData.isNotEmpty) ...[
            Text('Bookings by Sport',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(catData),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: catData.entries.map((e) {
                        final color = _sportColor(e.key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.key,
                                style: const TextStyle(fontSize: 12))),
                            Text('${e.value}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeakHoursTab(ThemeData theme, ColorScheme colorScheme) {
    final peakData = _peakHours();
    final maxVal = peakData.values.isEmpty
        ? 1
        : peakData.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Peak Booking Hours',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Which hours get the most bookings',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 16),

          // Heatmap-style horizontal bars
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: peakData.entries.map((e) {
                final ratio = maxVal == 0 ? 0.0 : e.value / maxVal;
                final isPeak = e.value == maxVal && maxVal > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    SizedBox(
                      width: 44,
                      child: Text(e.key,
                          style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: isPeak
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: colorScheme.outline.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio.clamp(0.0, 1.0),
                            child: Container(
                              height: 22,
                              decoration: BoxDecoration(
                                gradient: isPeak
                                    ? AppTheme.secondaryGradient
                                    : AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text('${e.value}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPeak
                                  ? AppTheme.secondaryColor
                                  : colorScheme.onSurface)),
                    ),
                    if (isPeak)
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppTheme.secondaryColor, size: 16),
                  ]),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Best performing ground
          _buildTopGroundCard(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTopGroundCard(ThemeData theme, ColorScheme colorScheme) {
    final groundMap = <String, int>{};
    for (final b in _completed) {
      final name = b['groundName'] as String? ?? 'Unknown';
      groundMap[name] = (groundMap[name] ?? 0) + ((b['price'] as num?)?.toInt() ?? 0);
    }
    if (groundMap.isEmpty) return const SizedBox();

    final sorted = groundMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Top Performing Ground',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text(top.key,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text('Rs ${NumberFormat('#,###').format(top.value)} revenue',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant)),
      ]),
    );
  }

  Widget _periodChip(String value, String label) {
    final selected = _period == value;
    return GestureDetector(
      onTap: () => setState(() => _period = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> data) {
    final total = data.values.fold(0, (s, v) => s + v);
    return data.entries.map((e) {
      final pct = total == 0 ? 0.0 : e.value / total * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: _sportColor(e.key),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _sportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket': return const Color(0xFF10B981);
      case 'football': return const Color(0xFFEF4444);
      case 'tennis': return const Color(0xFFF59E0B);
      case 'basketball': return const Color(0xFFFF7043);
      case 'hockey': return const Color(0xFF8B5CF6);
      case 'volleyball': return const Color(0xFF06B6D4);
      default: return AppTheme.primaryColor;
    }
  }
}
