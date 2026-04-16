import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/review_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  static const _categories = [
    'ALL', 'Cricket', 'Football', 'Tennis',
    'Basketball', 'Hockey', 'Volleyball'
  ];

  static const _sortOptions = [
    ('popular', 'Most Popular'),
    ('rating', 'Top Rated'),
    ('price_asc', 'Price: Low to High'),
    ('price_desc', 'Price: High to Low'),
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _searchCtrl.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<AppProvider>();
    final grounds = provider.allGrounds;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search Venues',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (provider.hasActiveFilters)
            TextButton(
              onPressed: () {
                provider.resetFilters();
                _searchCtrl.clear();
              },
              child: const Text('Reset',
                  style: TextStyle(color: AppTheme.primaryColor)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: provider.setSearch,
                    decoration: InputDecoration(
                      hintText: 'Search by name or location...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppTheme.primaryColor),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                provider.setSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showFilters = !_showFilters),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: provider.hasActiveFilters
                          ? AppTheme.primaryGradient
                          : null,
                      color: provider.hasActiveFilters
                          ? null
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: provider.hasActiveFilters
                          ? Colors.white
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter panel
          if (_showFilters) _buildFilterPanel(provider, colorScheme, theme),

          // Category chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = provider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => provider.setCategory(cat),
                    selectedColor:
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: selected
                          ? AppTheme.primaryColor
                          : colorScheme.onSurface,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${grounds.length} venues found',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results list
          Expanded(
            child: provider.loading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            AppTheme.primaryColor)))
                : grounds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64,
                                color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('No venues found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: grounds.length,
                        itemBuilder: (_, i) =>
                            _groundTile(grounds[i], theme, colorScheme),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(
      AppProvider provider, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort
          Text('Sort By', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _sortOptions.map((opt) {
              final selected = provider.sortBy == opt.$1;
              return ChoiceChip(
                label: Text(opt.$2),
                selected: selected,
                onSelected: (_) => provider.setSortBy(opt.$1),
                selectedColor:
                    AppTheme.primaryColor.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Max Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Price', style: theme.textTheme.titleSmall),
              Text('Rs. ${provider.maxPrice.toInt()}',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: provider.maxPrice,
            min: 500,
            max: 10000,
            divisions: 19,
            activeColor: AppTheme.primaryColor,
            onChanged: provider.setMaxPrice,
          ),

          // Min Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Min Rating', style: theme.textTheme.titleSmall),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < provider.minRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppTheme.accentColor,
                          size: 18,
                        )),
              ),
            ],
          ),
          Slider(
            value: provider.minRating,
            min: 0,
            max: 5,
            divisions: 5,
            activeColor: AppTheme.accentColor,
            onChanged: provider.setMinRating,
          ),
        ],
      ),
    );
  }

  Widget _groundTile(Map<String, dynamic> g, ThemeData theme,
      ColorScheme colorScheme) {
    final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
    final rating = (g['avgRating'] as num?)?.toDouble() ?? 0;
    final reviewCount = (g['reviewCount'] as num?)?.toInt() ?? 0;
    final dayPrice = (g['dayPrice'] as num?)?.toInt();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navigate to booking screen
          Navigator.pushNamed(context, '/Booking',
              arguments: g);
        },
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: imageUrls.isNotEmpty
                    ? Image.network(imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.sports)))
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.sports)),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g['name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(g['location'] ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Rating
                        Icon(Icons.star_rounded,
                            size: 14, color: AppTheme.accentColor),
                        const SizedBox(width: 2),
                        Text(
                          rating > 0
                              ? '${rating.toStringAsFixed(1)} ($reviewCount)'
                              : 'No reviews',
                          style: TextStyle(
                              fontSize: 11,
                              color: rating > 0
                                  ? AppTheme.accentColor
                                  : Colors.grey),
                        ),
                        const Spacer(),
                        // Price
                        if (dayPrice != null)
                          Text('Rs. $dayPrice',
                              style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Review button
                    GestureDetector(
                      onTap: () => ReviewBottomSheet.show(
                        context,
                        groundId: g['id'] ?? '',
                        groundName: g['name'] ?? '',
                        userId: uid,
                        userName: userName,
                      ),
                      child: const Row(children: [
                        Icon(Icons.rate_review_rounded,
                            size: 12, color: AppTheme.primaryColor),
                        SizedBox(width: 4),
                        Text('Write Review',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor)),
                      ]),
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
