import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'booking_helper.dart';
import '../../../../main.dart';

class Favourite extends StatefulWidget {
  const Favourite({super.key});

  @override
  State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  final _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _favourites = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = _db
          .collection('users')
          .doc(_uid)
          .collection('favourites')
          .snapshots()
          .listen((snap) {
        if (mounted) {
          setState(() {
            _favourites = snap.docs
                .map((d) => {...d.data(), 'favDocId': d.id})
                .toList();
            _loading = false;
          });
        }
      }, onError: (_) {
        if (mounted) setState(() => _loading = false);
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _removeFavourite(String favDocId, String name) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('favourites')
        .doc(favDocId)
        .delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name removed from favourites'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(title: 'Favourite Venues'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favourites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded,
                          size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('No favourite venues yet',
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Tap the heart icon on any venue to save it',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favourites.length,
                  itemBuilder: (context, index) {
                    final ground = _favourites[index];
                    final imageUrls =
                        (ground['imageUrls'] as List?)?.cast<String>() ?? [];
                    final favDocId = ground['favDocId'] as String? ?? '';

                    return ModernCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: imageUrls.isNotEmpty
                                  ? Image.network(imageUrls.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(colorScheme))
                                  : _placeholder(colorScheme),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ground['name'] ?? '',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.sports_outlined,
                                          size: 14,
                                          color: AppTheme.primaryColor),
                                      const SizedBox(width: 4),
                                      Text(ground['category'] ?? '',
                                          style: theme.textTheme.bodySmall),
                                      if ((ground['location'] ?? '')
                                          .isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.location_on_outlined,
                                            size: 14,
                                            color: AppTheme.primaryColor),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                              ground['location'] ?? '',
                                              style:
                                                  theme.textTheme.bodySmall,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ]),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Row(children: [
                              Expanded(
                                child: GradientButton(
                                  text: 'Book Now',
                                  icon: Icons.book_online_outlined,
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  onPressed: () =>
                                      BookingHelper.showBookingDialog(
                                          context, ground),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GradientButton(
                                  text: 'Remove',
                                  icon: Icons.favorite_rounded,
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFFEF4444),
                                    Color(0xFFDC2626)
                                  ]),
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  onPressed: () => _removeFavourite(
                                      favDocId, ground['name'] ?? ''),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _placeholder(ColorScheme c) => Container(
      color: c.surfaceContainerHighest,
      child: Icon(Icons.sports, color: c.onSurfaceVariant, size: 48));
}
