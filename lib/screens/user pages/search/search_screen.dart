import 'dart:async';
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../services/ground_service.dart';
import '../../../services/booking_service.dart';
import '../user home/favourite/booking_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _allGrounds = [];
  List<Map<String, dynamic>> _filtered = [];
  StreamSubscription? _sub;
  bool _loading = true;

  // Filter state
  String _selectedCategory = 'ALL';
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000;
  String _sortBy = 'name';
  DateTime? _availabilityDate;
  bool _filterPanelOpen = false;

  static const _categories = [
    'ALL', 'Cricket', 'Football', 'Tennis', 'Basketball', 'Hockey', 'Volleyball'
  ];

  @override
  void initState() {
    super.initState();
    _sub = GroundService.getGroundsByCategory('ALL').listen((grounds) {
      if (!mounted) return;
      double maxP = 0;
      for (final g in grounds) {
        final dp = (g['dayPrice'] as num?)?.toDouble() ?? 0;
        final np = (g['nightPrice'] as num?)?.toDouble() ?? 0;
        if (dp > maxP) maxP = dp;
        if (np > maxP) maxP = np;
      }
      if (maxP == 0) maxP = 10000;
      setState(() {
        _allGrounds = grounds;
        _loading = false;
        if (maxP > _maxPrice) {
          _maxPrice = maxP;
          _priceRange = RangeValues(0, maxP);
        }
      });
      _applyFilters();
    });
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchCtrl.text.trim().toLowerCase();
    List<Map<String, dynamic>> result = List.from(_allGrounds);

    if (query.isNotEmpty) {
      result = result.where((g) {
        final name = (g['name'] as String? ?? '').toLowerCase();
        final loc = (g['location'] as String? ?? '').toLowerCase();
        final cat = (g['category'] as String? ?? '').toLowerCase();
        return name.contains(query) || loc.contains(query) || cat.contains(query);
      }).toList();
    }

    if (_selectedCategory != 'ALL') {
      result = result.where((g) => g['category'] == _selectedCategory).toList();
    }

    result = result.where((g) {
      final dp = (g['dayPrice'] as num?)?.toDouble();
      if (dp == null) return true;
      return dp >= _priceRange.start && dp <= _priceRange.end;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        result.sort((a, b) {
          final ap = (a['dayPrice'] as num?)?.toDouble() ?? double.infinity;
          final bp = (b['dayPrice'] as num?)?.toDouble() ?? double.infinity;
          return ap.compareTo(bp);
        });
        break;
      case 'price_desc':
        result.sort((a, b) {
          final ap = (a['dayPrice'] as num?)?.toDouble() ?? 0;
          final bp = (b['dayPrice'] as num?)?.toDouble() ?? 0;
          return bp.compareTo(ap);
        });
        break;
      default:
        result.sort((a, b) =>
            (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? ''));
    }

    setState(() => _filtered = result);

    if (_availabilityDate != null) {
      _applyAvailabilityFilter(result);
    }
  }

  Future<void> _applyAvailabilityFilter(List<Map<String, dynamic>> base) async {
    if (_availabilityDate == null) return;
    final dateKey = _availabilityDate!.toIso8601String().split('T')[0];
    final available = <Map<String, dynamic>>[];
    for (final g in base) {
      final gid = g['id'] as String? ?? '';
      if (gid.isEmpty) { available.add(g); continue; }
      final booked = await BookingService.getBookedSlots(gid, dateKey);
      final allSlots = _getSlotsCount(g['category'] as String? ?? '');
      if (booked.length < allSlots) available.add(g);
    }
    if (mounted) setState(() => _filtered = available);
  }

  int _getSlotsCount(String cat) => cat == 'Cricket' ? 3 : 15;

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'ALL';
      _priceRange = RangeValues(0, _maxPrice);
      _sortBy = 'name';
      _availabilityDate = null;
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedCategory != 'ALL' ||
      _priceRange.start > 0 ||
      _priceRange.end < _maxPrice ||
      _sortBy != 'name' ||
      _availabilityDate != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by name, location, sport...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppTheme.primaryColor),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () =>
                      setState(() => _filterPanelOpen = !_filterPanelOpen),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: _filterPanelOpen || _hasActiveFilters
                          ? AppTheme.primaryGradient
                          : null,
                      color: _filterPanelOpen || _hasActiveFilters
                          ? null
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.tune_rounded,
                            color: _filterPanelOpen || _hasActiveFilters
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                            size: 22),
                        if (_hasActiveFilters)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _filterPanelOpen
                ? _FilterPanel(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    priceRange: _priceRange,
                    maxPrice: _maxPrice,
                    sortBy: _sortBy,
                    availabilityDate: _availabilityDate,
                    hasActiveFilters: _hasActiveFilters,
                    onCategoryChanged: (c) {
                      setState(() => _selectedCategory = c);
                      _applyFilters();
                    },
                    onPriceChanged: (r) {
                      setState(() => _priceRange = r);
                      _applyFilters();
                    },
                    onSortChanged: (s) {
                      setState(() => _sortBy = s);
                      _applyFilters();
                    },
                    onDateChanged: (d) {
                      setState(() => _availabilityDate = d);
                      _applyFilters();
                    },
                    onClear: _clearFilters,
                  )
                : const SizedBox.shrink(),
          ),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} venue${_filtered.length == 1 ? '' : 's'} found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_availabilityDate != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.check_circle_outline,
                            size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                            'Available ${_availabilityDate!.day}/${_availabilityDate!.month}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _EmptyState(
                        hasFilters: _hasActiveFilters ||
                            _searchCtrl.text.isNotEmpty)
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) =>
                            _VenueCard(ground: _filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Panel ──────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final RangeValues priceRange;
  final double maxPrice;
  final String sortBy;
  final DateTime? availabilityDate;
  final bool hasActiveFilters;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onClear;

  const _FilterPanel({
    required this.categories,
    required this.selectedCategory,
    required this.priceRange,
    required this.maxPrice,
    required this.sortBy,
    required this.availabilityDate,
    required this.hasActiveFilters,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onSortChanged,
    required this.onDateChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text('Filters',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('Clear all'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Category chips
          Text('Sport', style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: categories.map((cat) {
              final selected = cat == selectedCategory;
              return GestureDetector(
                onTap: () => onCategoryChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: selected ? AppTheme.primaryGradient : null,
                    color: selected ? null : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Text(cat,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : colorScheme.onSurface)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Price range
          Row(
            children: [
              Text('Price Range (Day)',
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                'PKR ${priceRange.start.toInt()} – ${priceRange.end.toInt()}',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: maxPrice,
            divisions: 20,
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            onChanged: onPriceChanged,
          ),
          const SizedBox(height: 10),

          // Sort by
          Text('Sort By',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              {'value': 'name', 'label': 'Name A–Z'},
              {'value': 'price_asc', 'label': 'Price: Low–High'},
              {'value': 'price_desc', 'label': 'Price: High–Low'},
            ].map((item) {
              final selected = sortBy == item['value'];
              return GestureDetector(
                onTap: () => onSortChanged(item['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: selected ? AppTheme.primaryGradient : null,
                    color: selected ? null : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Text(item['label']!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : colorScheme.onSurface)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Availability date
          Text('Availability',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: availabilityDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    onDateChanged(picked);
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(
                    availabilityDate != null
                        ? '${availabilityDate!.day}/${availabilityDate!.month}/${availabilityDate!.year}'
                        : 'Pick a date',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: availabilityDate != null
                        ? AppTheme.primaryColor
                        : null,
                    side: BorderSide(
                        color: availabilityDate != null
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              if (availabilityDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => onDateChanged(null),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Venue Card ────────────────────────────────────────────
class _VenueCard extends StatelessWidget {
  final Map<String, dynamic> ground;
  const _VenueCard({required this.ground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageUrls = (ground['imageUrls'] as List?)?.cast<String>() ?? [];
    final dayPrice = ground['dayPrice'];
    final nightPrice = ground['nightPrice'];

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      color: colorScheme.surface,
      elevation: 3,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imageUrls.isNotEmpty
                      ? Image.network(imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.sports,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant)))
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.sports,
                              size: 48, color: colorScheme.onSurfaceVariant)),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(ground['category'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ground['name'] ?? '',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if ((ground['location'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(ground['location'],
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (dayPrice != null)
                      _PriceChip(
                          icon: Icons.wb_sunny_rounded,
                          label: 'PKR $dayPrice',
                          color: const Color(0xFFFF9500)),
                    if (dayPrice != null && nightPrice != null)
                      const SizedBox(width: 6),
                    if (nightPrice != null)
                      _PriceChip(
                          icon: Icons.nights_stay_rounded,
                          label: 'PKR $nightPrice',
                          color: const Color(0xFF1565C0)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          BookingHelper.showBookingDialog(context, ground),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Book Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Price Chip ────────────────────────────────────────────
class _PriceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PriceChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Empty State ───────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.sports_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No venues match your filters' : 'No venues available',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            Text('Try adjusting your search or filters',
                style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7))),
          ],
        ],
      ),
    );
  }
}
