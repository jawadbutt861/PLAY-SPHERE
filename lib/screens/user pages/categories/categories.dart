import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlong2;
import "package:f_y_p/screens/user%20pages/user%20home/favourite/global_data.dart";
import '../../../main.dart';
import '../../../services/ground_service.dart';
import '../../../services/booking_service.dart';
import '../../booking_chat_screen.dart';





class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;
  Map<String, Map<String, List<String>>> bookedSlots = {};
  List<Map<String, dynamic>> _firestoreGrounds = [];
  bool _isLoadingGrounds = true;
  String? _fetchError;
  StreamSubscription? _groundsSub;

  // Favourites — Firestore backed
  final _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  Set<String> _favouriteIds = {};
  StreamSubscription? _favSub;

  @override
  void initState() {
    super.initState();
    _listenToGrounds();
    if (_uid != null) {
      _favSub = _db
          .collection('users')
          .doc(_uid)
          .collection('favourites')
          .snapshots()
          .listen((snap) {
        if (mounted) {
          setState(() {
            _favouriteIds = snap.docs.map((d) => d.id).toSet();
          });
        }
      });
    }
  }

  void _listenToGrounds() {
    _groundsSub = GroundService.getGroundsByCategory('ALL').listen(
      (grounds) {
        if (mounted) {
          setState(() {
            _firestoreGrounds = grounds;
            _isLoadingGrounds = false;
            _fetchError = null;
          });
        }
      },
      onError: (e) {
        debugPrint('Categories stream error: $e');
        if (mounted) {
          setState(() {
            _isLoadingGrounds = false;
            _fetchError = e.toString();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _groundsSub?.cancel();
    _favSub?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> categories = [
    {
      "name": "ALL", 
      "icon": Icons.star_outline_rounded,
      "gradient": AppTheme.primaryGradient,
    },
    {
      "name": "Cricket", 
      "icon": Icons.sports_cricket_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    },
    {
      "name": "Football", 
      "icon": Icons.sports_soccer_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
    },
    {
      "name": "Tennis", 
      "icon": Icons.sports_tennis_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
    },
    {
      "name": "Basketball", 
      "icon": Icons.sports_basketball_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFE64A19)]),
    },
    {
      "name": "Hockey", 
      "icon": Icons.sports_hockey_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)]),
    },
    {
      "name": "Volleyball", 
      "icon": Icons.sports_volleyball_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),
    },
  ];

  Future<void> _toggleFavourite(Map<String, dynamic> ground) async {
    if (_uid == null) return;
    final groundId = ground['id'] as String? ?? ground['name'] as String? ?? '';
    if (groundId.isEmpty) return;
    final ref = _db.collection('users').doc(_uid).collection('favourites').doc(groundId);
    if (_favouriteIds.contains(groundId)) {
      await ref.delete();
    } else {
      // Save ground data so favourite screen can display it offline
      await ref.set({
        'id': groundId,
        'name': ground['name'] ?? '',
        'category': ground['category'] ?? '',
        'location': ground['location'] ?? '',
        'imageUrls': ground['imageUrls'] ?? [],
        'managerId': ground['managerId'] ?? '',
        'latitude': ground['latitude'],
        'longitude': ground['longitude'],
        'dayPrice': ground['dayPrice'],
        'nightPrice': ground['nightPrice'],
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _openLocationOnMap(BuildContext context, Map<String, dynamic> ground) {
    final lat = ground['latitude'];
    final lng = ground['longitude'];
    final location = ground['location'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationBottomSheet(
        groundName: ground['name'] ?? '',
        location: location,
        latitude: lat is num ? lat.toDouble() : null,
        longitude: lng is num ? lng.toDouble() : null,
      ),
    );
  }

  Widget _buildFirestoreImage(Map<String, dynamic> ground) {
    final imageUrls = (ground['imageUrls'] as List?)?.cast<String>() ?? [];
    if (imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.sports, color: Colors.white54, size: 48),
      );
    }
    return Image.network(
      imageUrls.first,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white54, size: 48),
      ),
    );
  }

  List<String> getSlots(String category) {
    if (category == "Cricket") {
      return ["9am to 2pm", "2pm to 6pm", "Full-day"];
    } else {
      List<String> slots = [];
      for (int i = 9; i < 24; i++) { // 9am to 11pm
        String start = i <= 12 ? "${i}am" : "${i - 12}pm";
        int endHour = i + 1;
        String end = endHour <= 12 ? "${endHour}am" : "${endHour - 12}pm";
        if (endHour == 12) end = "12pm";
        if (endHour == 24) end = "12am";
        slots.add("$start-$end");
      }
      return slots;
    }
  }

  void _showBookingDialog(Map<String, dynamic> ground) {
    final outerContext = context;
    showDialog(
      context: context,
      builder: (_) => _BookingDialog(ground: ground, outerContext: outerContext),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String selectedCategory = categories[selectedIndex]['name'];

    // Sirf Firestore grounds show karo
    final firestoreFiltered = selectedCategory == 'ALL'
        ? _firestoreGrounds
        : _firestoreGrounds.where((g) => g['category'] == selectedCategory).toList();

    final List<Map<String, dynamic>> filteredSports = firestoreFiltered.map((g) {
      final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
      return {
        'name': g['name'] ?? '',
        'category': g['category'] ?? '',
        'location': g['location'] ?? '',
        'imageUrls': imageUrls,
        'isFirestore': true,
        'id': g['id'],
        'managerId': g['managerId'] ?? '',
        'latitude': g['latitude'],
        'longitude': g['longitude'],
        'dayPrice': g['dayPrice'],
        'nightPrice': g['nightPrice'],
      };
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ModernAppBar(
        title: "Book Your Venues",
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: GroundSearchDelegate(
                    sports: _firestoreGrounds.map((g) {
                      final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
                      return {
                        'name': g['name'] ?? '',
                        'category': g['category'] ?? '',
                        'imageUrls': imageUrls,
                        'isFirestore': true,
                        'id': g['id'],
                        'managerId': g['managerId'] ?? '',
                      };
                    }).toList(),
                  ),
                );
              },
              icon: const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Category Selector
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: isSelected ? category['gradient'] : null,
                              color: isSelected ? null : colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.1),
                                  blurRadius: isSelected ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              category['icon'],
                              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "${categories[selectedIndex]['name']} Venues",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${filteredSports.length} available",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Grid of Filtered Grounds
            if (_isLoadingGrounds)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_fetchError != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text('Failed to load venues', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _fetchError!,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoadingGrounds = true;
                            _fetchError = null;
                          });
                          _groundsSub?.cancel();
                          _listenToGrounds();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredSports.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.sports_outlined, size: 56, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        'No venues found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Register a ground as manager to see it here',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredSports.length,
              itemBuilder: (context, index) {
                final ground = filteredSports[index];
                final groundId = ground['id'] ?? ground['name'];
                final isFavourite = _favouriteIds.contains(groundId as String? ?? '');

                return ModernCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.zero,
                  color: colorScheme.surface,
                  elevation: 3,
                  child: Column(
                    children: [
                      // Image with overlays
                      SizedBox(
                        height: 160,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: _buildFirestoreImage(ground),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.35),
                                  ],
                                ),
                              ),
                            ),
                            // Favourite button
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavourite
                                        ? Colors.red
                                        : Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () => _toggleFavourite(ground),
                                ),
                              ),
                            ),
                            // Category badge
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ground['category'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Details
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + fav row
                            Text(
                              ground['name'] ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Location + price row
                            Row(
                              children: [
                                if ((ground['location'] ?? '').isNotEmpty) ...[
                                  GestureDetector(
                                    onTap: () =>
                                        _openLocationOnMap(context, ground),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.location_on_rounded,
                                              size: 12,
                                              color: AppTheme.primaryColor),
                                          SizedBox(width: 4),
                                          Text('View Location',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.primaryColor,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                // Price chips
                                if (ground['dayPrice'] != null)
                                  _PriceChip(
                                    icon: Icons.wb_sunny_rounded,
                                    label: 'PKR ${ground['dayPrice']}',
                                    color: const Color(0xFFFF9500),
                                  ),
                                if (ground['dayPrice'] != null &&
                                    ground['nightPrice'] != null)
                                  const SizedBox(width: 6),
                                if (ground['nightPrice'] != null)
                                  _PriceChip(
                                    icon: Icons.nights_stay_rounded,
                                    label: 'PKR ${ground['nightPrice']}',
                                    color: const Color(0xFF1565C0),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Book Now button
                            GradientButton(
                              text: 'Book Now',
                              icon: Icons.book_online_rounded,
                              width: double.infinity,
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              onPressed: () => _showBookingDialog(ground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
          ],
        ),
      ),
      
    );
  }
}

// ── Booking Dialog (Firestore-backed slot check) ──────────
class _BookingDialog extends StatefulWidget {
  final Map<String, dynamic> ground;
  final BuildContext outerContext;
  const _BookingDialog({required this.ground, required this.outerContext});
  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  DateTime? _date;
  String? _slot;
  List<String> _bookedSlots = [];
  bool _loadingSlots = false;
  bool _showSummary = false;

  List<String> _getSlots() {
    final cat = widget.ground['category'] ?? '';
    if (cat == 'Cricket') return ['9am to 2pm', '2pm to 6pm', 'Full-day'];
    final slots = <String>[];
    for (int i = 9; i < 24; i++) {
      final start = i <= 12 ? '${i}am' : '${i - 12}pm';
      int e = i + 1;
      String end = e <= 12 ? '${e}am' : '${e - 12}pm';
      if (e == 12) end = '12pm';
      if (e == 24) end = '12am';
      slots.add('$start-$end');
    }
    return slots;
  }

  Future<void> _fetchBooked(String dateKey) async {
    setState(() { _loadingSlots = true; _bookedSlots = []; });
    final gid = widget.ground['id'] as String? ?? '';
    if (gid.isNotEmpty) {
      final slots = await BookingService.getBookedSlots(gid, dateKey);
      if (mounted) setState(() => _bookedSlots = slots);
    }
    if (mounted) setState(() => _loadingSlots = false);
  }

  bool _isDisabled(String slot) {
    final cat = widget.ground['category'] ?? '';
    if (_bookedSlots.contains(slot)) return true;
    if (cat == 'Cricket') {
      if (slot == 'Full-day') {
        return _bookedSlots.contains('9am to 2pm') ||
            _bookedSlots.contains('2pm to 6pm') ||
            _slot == '9am to 2pm' || _slot == '2pm to 6pm';
      } else {
        return _bookedSlots.contains('Full-day') || _slot == 'Full-day';
      }
    }
    return false;
  }

  int? _calcPrice() {
    if (_slot == null) return null;
    final s = _slot!.toLowerCase();
    int h = 9;
    if (s.startsWith('2pm')) { h = 14; }
    else if (!s.startsWith('full')) {
      final p = s.split(RegExp(r'[-\s]')).first.trim();
      if (p.endsWith('am')) { h = int.tryParse(p.replaceAll('am', '')) ?? 9; }
      else if (p.endsWith('pm')) {
        final x = int.tryParse(p.replaceAll('pm', '')) ?? 12;
        h = x == 12 ? 12 : x + 12;
      }
    }
    final isDay = h >= 6 && h < 18;
    final g = widget.ground;
    if (isDay && g['dayPrice'] != null) return (g['dayPrice'] as num).toInt();
    if (!isDay && g['nightPrice'] != null) return (g['nightPrice'] as num).toInt();
    return null;
  }

  void _placeOrder() async {
    final dk = _date!.toIso8601String().split('T')[0];
    final user = FirebaseAuth.instance.currentUser;
    final g = widget.ground;
    final bookingId = await BookingService.createBooking(
      groundId: g['id'] ?? '',
      groundName: g['name'] ?? '',
      groundCategory: g['category'] ?? '',
      managerId: g['managerId'] ?? '',
      userId: user?.uid ?? '',
      userEmail: user?.email ?? '',
      userName: user?.displayName ?? user?.email ?? '',
      date: dk,
      slot: _slot!,
      payment: 'Pay at Venue',
      imageUrls: (g['imageUrls'] as List?)?.cast<String>() ?? [],
      price: _calcPrice(),
    );
    if (!mounted) return;
    Navigator.pop(context);
    if (bookingId != null) {
      Navigator.push(
        widget.outerContext,
        MaterialPageRoute(
          builder: (_) => BookingChatScreen(
            bookingId: bookingId,
            booking: {
              'groundName': g['name'] ?? '',
              'groundCategory': g['category'] ?? '',
              'date': dk,
              'slot': _slot!,
              'payment': 'Pay at Venue',
              'price': _calcPrice(),
              'status': 'pending',
            },
            isManager: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dk = _date?.toIso8601String().split('T')[0];
    final price = _calcPrice();
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.sports_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _showSummary ? 'Order Summary' : 'Book ${widget.ground['name'] ?? 'Venue'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: _showSummary
              ? _buildSummary(dk!, price, colorScheme)
              : _buildSelectionForm(dk, colorScheme),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (_showSummary) {
                    setState(() => _showSummary = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(_showSummary ? 'Back' : 'Cancel',
                    style: const TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GradientButton(
                text: _showSummary ? 'Place Order' : 'Review Order',
                icon: _showSummary ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                onPressed: () {
                  if (_showSummary) {
                    _placeOrder();
                  } else {
                    if (_date == null || _slot == null) {
                      ScaffoldMessenger.of(widget.outerContext).showSnackBar(SnackBar(
                        content: const Text('Please select date and slot'),
                        backgroundColor: AppTheme.warningColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                      return;
                    }
                    setState(() => _showSummary = true);
                  }
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildSelectionForm(String? dk, ColorScheme colorScheme) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GradientButton(
        text: dk ?? 'Select Date',
        icon: Icons.calendar_today,
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (picked != null) {
            setState(() { _date = picked; _slot = null; });
            await _fetchBooked(picked.toIso8601String().split('T')[0]);
          }
        },
      ),
      if (_date != null) ...[
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Select Time Slot:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
        ),
        if (_loadingSlots)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          ..._getSlots().map((slot) {
            final disabled = _isDisabled(slot);
            final booked = _bookedSlots.contains(slot);
            final label = booked ? '$slot (Booked)' : disabled ? '$slot (Unavailable)' : slot;
            return ListTile(
              dense: true,
              leading: RadioGroup<String>(
                groupValue: _slot,
                onChanged: disabled ? (v) {} : (v) => setState(() => _slot = v),
                child: Radio<String>(value: slot),
              ),
              title: Text(label,
                  style: TextStyle(color: disabled ? Colors.grey : null, fontSize: 13)),
              onTap: disabled ? null : () => setState(() => _slot = slot),
            );
          }),
      ],
    ]);
  }

  Widget _buildSummary(String dk, int? price, ColorScheme colorScheme) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          _summaryRow(Icons.stadium_rounded, 'Venue', widget.ground['name'] ?? ''),
          _divider(),
          _summaryRow(Icons.sports_outlined, 'Sport', widget.ground['category'] ?? ''),
          _divider(),
          _summaryRow(Icons.calendar_today_outlined, 'Date', dk),
          _divider(),
          _summaryRow(Icons.access_time_outlined, 'Slot', _slot ?? ''),
          _divider(),
          _summaryRow(Icons.payments_outlined, 'Payment', 'Pay at Venue'),
          if (price != null) ...[
            _divider(),
            _summaryRow(Icons.attach_money_rounded, 'Amount', 'PKR $price',
                valueColor: AppTheme.successColor),
          ],
        ]),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.warningColor, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Booking will be confirmed after manager approval.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _summaryRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ]),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2));
}


// Price chip widget
class _PriceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PriceChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// Location Bottom Sheet
class _LocationBottomSheet extends StatelessWidget {
  final String groundName;
  final String location;
  final double? latitude;
  final double? longitude;

  const _LocationBottomSheet({
    required this.groundName,
    required this.location,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCoords = latitude != null && longitude != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(groundName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(location,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                    maxLines: 3),
              ]),
            ),
          ]),
          const SizedBox(height: 20),

          // Map preview (if coords available)
          if (hasCoords) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: _MapPreview(latitude: latitude!, longitude: longitude!),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Open in map button
          GradientButton(
            text: hasCoords ? 'View on Map' : 'Location Address',
            icon: Icons.map_rounded,
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            onPressed: hasCoords
                ? () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FullMapScreen(
                          groundName: groundName,
                          latitude: latitude!,
                          longitude: longitude!,
                          location: location,
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// Small map preview widget
class _MapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  const _MapPreview({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        flutter_map.FlutterMap(
          options: flutter_map.MapOptions(
            initialCenter: latlong2.LatLng(latitude, longitude),
            initialZoom: 15,
            interactionOptions: const flutter_map.InteractionOptions(
              flags: flutter_map.InteractiveFlag.none,
            ),
          ),
          children: [
            flutter_map.TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.f_y_p',
            ),
            flutter_map.MarkerLayer(markers: [
              flutter_map.Marker(
                point: latlong2.LatLng(latitude, longitude),
                width: 40, height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ]),
          ],
        ),
        // Overlay to prevent interaction
        Positioned.fill(child: Container(color: Colors.transparent)),
      ],
    );
  }
}

// Full screen map
class _FullMapScreen extends StatelessWidget {
  final String groundName;
  final double latitude;
  final double longitude;
  final String location;

  const _FullMapScreen({
    required this.groundName,
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(title: groundName),
      body: Stack(
        children: [
          flutter_map.FlutterMap(
            options: flutter_map.MapOptions(
              initialCenter: latlong2.LatLng(latitude, longitude),
              initialZoom: 15,
            ),
            children: [
              flutter_map.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.f_y_p',
              ),
              flutter_map.MarkerLayer(markers: [
                flutter_map.Marker(
                  point: latlong2.LatLng(latitude, longitude),
                  width: 48, height: 48,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 48),
                ),
              ]),
            ],
          ),
          // Bottom info card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)],
              ),
              child: Row(children: [
                const Icon(Icons.location_on_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(location,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// Search Delegate for Ground Search
class GroundSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> sports;

  GroundSearchDelegate({required this.sports});

  @override
  String get searchFieldLabel => 'Search venues...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredSports = sports.where((ground) {
      return ground['name'].toLowerCase().contains(query.toLowerCase()) ||
             ground['category'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredSports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No venues found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSports.length,
      itemBuilder: (context, index) {
        final ground = filteredSports[index];
        final groundId = ground['id'] ?? ground['name'];
        final isFavourite = GlobalData.favouriteGrounds
            .any((f) => (f['id'] ?? f['name']) == groundId);

        return ModernCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (() {
                  final urls = (ground['imageUrls'] as List?)?.cast<String>() ?? [];
                  return urls.isNotEmpty
                      ? Image.network(urls.first, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.sports))
                      : const Icon(Icons.sports);
                })(),
              ),
            ),
            title: Text(
              ground['name'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(ground['category']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: isFavourite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;
                    final gId = groundId as String? ?? '';
                    if (gId.isEmpty) return;
                    final ref = FirebaseFirestore.instance
                        .collection('users').doc(uid)
                        .collection('favourites').doc(gId);
                    if (isFavourite) {
                      ref.delete();
                    } else {
                      ref.set({
                        'id': gId,
                        'name': ground['name'] ?? '',
                        'category': ground['category'] ?? '',
                        'location': ground['location'] ?? '',
                        'imageUrls': ground['imageUrls'] ?? [],
                        'managerId': ground['managerId'] ?? '',
                        'savedAt': FieldValue.serverTimestamp(),
                      });
                    }
                  },
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              close(context, ground);
              // You can add navigation to booking dialog here if needed
            },
          ),
        );
      },
    );
  }
}