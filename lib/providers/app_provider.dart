import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ground_service.dart';
import '../services/booking_service.dart';

/// Central state provider — grounds, bookings, filters
class AppProvider extends ChangeNotifier {
  // ─── Grounds ─────────────────────────────────────────────
  List<Map<String, dynamic>> _allGrounds = [];
  List<Map<String, dynamic>> get allGrounds => _filteredGrounds;

  StreamSubscription? _groundsSub;

  // ─── Filters ─────────────────────────────────────────────
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  double _maxPrice = 10000;
  double _minRating = 0;
  String _sortBy = 'popular'; // popular | price_asc | price_desc | rating

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  double get maxPrice => _maxPrice;
  double get minRating => _minRating;
  String get sortBy => _sortBy;

  // ─── User Bookings ────────────────────────────────────────
  List<Map<String, dynamic>> _userBookings = [];
  List<Map<String, dynamic>> get userBookings => _userBookings;
  StreamSubscription? _bookingsSub;

  bool _loading = true;
  bool get loading => _loading;

  void init(String? uid) {
    _groundsSub?.cancel();
    _bookingsSub?.cancel();

    _groundsSub = GroundService.getGroundsByCategory('ALL').listen((grounds) {
      _allGrounds = grounds;
      _loading = false;
      notifyListeners();
    });

    if (uid != null) {
      _bookingsSub = BookingService.getUserBookings(uid).listen((bookings) {
        _userBookings = bookings;
        notifyListeners();
      });
    }
  }

  // ─── Filter Methods ───────────────────────────────────────

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setMaxPrice(double p) {
    _maxPrice = p;
    notifyListeners();
  }

  void setMinRating(double r) {
    _minRating = r;
    notifyListeners();
  }

  void setSortBy(String s) {
    _sortBy = s;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'ALL';
    _maxPrice = 10000;
    _minRating = 0;
    _sortBy = 'popular';
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != 'ALL' ||
      _maxPrice < 10000 ||
      _minRating > 0 ||
      _sortBy != 'popular';

  List<Map<String, dynamic>> get _filteredGrounds {
    var list = List<Map<String, dynamic>>.from(_allGrounds);

    // Category filter
    if (_selectedCategory != 'ALL') {
      list = list
          .where((g) => g['category'] == _selectedCategory)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((g) {
        final name = (g['name'] as String? ?? '').toLowerCase();
        final loc = (g['location'] as String? ?? '').toLowerCase();
        return name.contains(q) || loc.contains(q);
      }).toList();
    }

    // Price filter
    list = list.where((g) {
      final day = (g['dayPrice'] as num?)?.toDouble() ?? 0;
      final night = (g['nightPrice'] as num?)?.toDouble() ?? 0;
      final price = day > 0 ? day : night;
      return price == 0 || price <= _maxPrice;
    }).toList();

    // Rating filter
    if (_minRating > 0) {
      list = list.where((g) {
        final r = (g['avgRating'] as num?)?.toDouble() ?? 0;
        return r >= _minRating;
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) {
          final pa = (a['dayPrice'] as num?)?.toDouble() ?? 0;
          final pb = (b['dayPrice'] as num?)?.toDouble() ?? 0;
          return pa.compareTo(pb);
        });
        break;
      case 'price_desc':
        list.sort((a, b) {
          final pa = (a['dayPrice'] as num?)?.toDouble() ?? 0;
          final pb = (b['dayPrice'] as num?)?.toDouble() ?? 0;
          return pb.compareTo(pa);
        });
        break;
      case 'rating':
        list.sort((a, b) {
          final ra = (a['avgRating'] as num?)?.toDouble() ?? 0;
          final rb = (b['avgRating'] as num?)?.toDouble() ?? 0;
          return rb.compareTo(ra);
        });
        break;
      default: // popular
        list.sort((a, b) {
          final ba = (a['bookingCount'] as num?)?.toInt() ?? 0;
          final bb = (b['bookingCount'] as num?)?.toInt() ?? 0;
          return bb.compareTo(ba);
        });
    }

    return list;
  }

  @override
  void dispose() {
    _groundsSub?.cancel();
    _bookingsSub?.cancel();
    super.dispose();
  }
}
