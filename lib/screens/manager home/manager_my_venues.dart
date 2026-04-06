import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../services/ground_service.dart';
import '../../services/booking_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/notification_service.dart';

class ManagerMyVenues extends StatefulWidget {
  const ManagerMyVenues({super.key});
  @override
  State<ManagerMyVenues> createState() => _ManagerMyVenuesState();
}

class _ManagerMyVenuesState extends State<ManagerMyVenues> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _grounds = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = GroundService.getManagerGrounds(_uid).listen((g) {
        if (mounted) {
          setState(() { _grounds = g; _loading = false; });
          // Price set nahi hai to notification bhejo
          for (final ground in g) {
            if (ground['dayPrice'] == null || ground['nightPrice'] == null) {
              NotificationService.sendPriceNotSetNotification(
                managerId: _uid,
                groundName: ground['name'] ?? 'Venue',
              );
            }
          }
        }
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
          title: 'My Venues', gradient: AppTheme.secondaryGradient),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grounds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stadium_rounded,
                          size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('No venues registered',
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Register a venue during signup',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _grounds.length,
                  itemBuilder: (_, i) => _venueTile(context, _grounds[i]),
                ),
    );
  }

  Widget _venueTile(BuildContext context, Map<String, dynamic> g) {
    final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with edit overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: imageUrls.isNotEmpty
                      ? Image.network(imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(colorScheme))
                      : _placeholder(colorScheme),
                ),
              ),
              // Edit button top-right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showEditDialog(context, g),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(g['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(g['category'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 6),
                if ((g['location'] ?? '').isNotEmpty)
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(g['location'],
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                const SizedBox(height: 12),
                // Price info row
                _priceRow(context, g),
                const SizedBox(height: 12),
                // Multiple images row
                if (imageUrls.length > 1)
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (_, idx) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: NetworkImage(imageUrls[idx]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                if (imageUrls.length > 1) const SizedBox(height: 12),
                // Buttons row
                Row(children: [
                  Expanded(
                    child: GradientButton(
                      text: 'View Bookings',
                      icon: Icons.event_note_rounded,
                      gradient: AppTheme.secondaryGradient,
                      width: double.infinity,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      textStyle: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => VenueBookingsScreen(ground: g))),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Map<String, dynamic> g) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditVenueDialog(ground: g),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Venue updated!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else if (result == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Update failed, try again.'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Widget _priceRow(BuildContext context, Map<String, dynamic> g) {
    final dayPrice = g['dayPrice'];
    final nightPrice = g['nightPrice'];
    final theme = Theme.of(context);
    if (dayPrice == null || nightPrice == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              size: 14, color: AppTheme.warningColor),
          const SizedBox(width: 6),
          Text('Price not set — Tap Edit to set',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningColor, fontWeight: FontWeight.w600)),
        ]),
      );
    }
    return Row(children: [
      _priceChip(Icons.wb_sunny_rounded, 'Day', 'PKR $dayPrice',
          const Color(0xFFFF9500)),
      const SizedBox(width: 8),
      _priceChip(Icons.nights_stay_rounded, 'Night', 'PKR $nightPrice',
          const Color(0xFF5856D6)),
    ]);
  }

  Widget _priceChip(IconData icon, String label, String price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text('$label: $price',
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _placeholder(ColorScheme c) => Container(
      color: c.surfaceContainerHighest,
      child: Icon(Icons.stadium_rounded, color: c.onSurfaceVariant, size: 48));
}

// ─────────────────────────────────────────────
// EDIT VENUE DIALOG
// ─────────────────────────────────────────────
class _EditVenueDialog extends StatefulWidget {
  final Map<String, dynamic> ground;
  const _EditVenueDialog({required this.ground});
  @override
  State<_EditVenueDialog> createState() => _EditVenueDialogState();
}

class _EditVenueDialogState extends State<_EditVenueDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dayCtrl;
  late final TextEditingController _nightCtrl;
  late final List<String> _imageUrls;
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.ground;
    _nameCtrl = TextEditingController(text: g['name'] ?? '');
    _dayCtrl = TextEditingController(
        text: g['dayPrice'] != null ? '${g['dayPrice']}' : '');
    _nightCtrl = TextEditingController(
        text: g['nightPrice'] != null ? '${g['nightPrice']}' : '');
    _imageUrls = List<String>.from(
        (g['imageUrls'] as List?)?.cast<String>() ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dayCtrl.dispose();
    _nightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty || !mounted) return;
    setState(() => _isUploading = true);
    try {
      final urls = await CloudinaryService.uploadMultipleImages(
        picked.map((x) => File(x.path)).toList(),
        folder: 'venues',
      );
      if (mounted) setState(() { _imageUrls.addAll(urls); _isUploading = false; });
    } catch (_) {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) return;
    setState(() => _isSaving = true);
    final updateData = <String, dynamic>{
      'name': newName,
      'imageUrls': _imageUrls,
    };
    final dayVal = int.tryParse(_dayCtrl.text.trim());
    final nightVal = int.tryParse(_nightCtrl.text.trim());
    if (dayVal != null) updateData['dayPrice'] = dayVal;
    if (nightVal != null) updateData['nightPrice'] = nightVal;
    final success = await GroundService.updateGround(widget.ground['id'], updateData);
    if (mounted) Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.edit_rounded, color: AppTheme.secondaryColor),
        SizedBox(width: 10),
        Text('Edit Venue'),
      ]),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Venue Name',
                prefixIcon: Icon(Icons.business_outlined,
                    color: AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Slot Prices (PKR)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _dayCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Day Price',
                    hintText: 'e.g. 1500',
                    prefixIcon: Icon(Icons.wb_sunny_rounded,
                        color: Color(0xFFFF9500), size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _nightCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Night Price',
                    hintText: 'e.g. 2000',
                    prefixIcon: Icon(Icons.nights_stay_rounded,
                        color: Color(0xFF5856D6), size: 20),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Day = 6AM–6PM  •  Night = 6PM–6AM',
                  style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Venue Images',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...List.generate(_imageUrls.length, (i) => Stack(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: NetworkImage(_imageUrls[i]),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _imageUrls.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                )),
                if (!_isUploading && _imageUrls.length < 5)
                  GestureDetector(
                    onTap: _pickAndUpload,
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.secondaryColor, width: 2),
                      ),
                      child: const Icon(Icons.add_a_photo_rounded,
                          color: AppTheme.secondaryColor, size: 26),
                    ),
                  ),
                if (_isUploading)
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 28, height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                              AppTheme.secondaryColor),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_imageUrls.isEmpty && !_isUploading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('No images — tap + to add',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, null),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        _isSaving
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : GradientButton(
                text: 'Save',
                gradient: AppTheme.secondaryGradient,
                height: 42,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                onPressed: _save,
              ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// VENUE BOOKINGS DETAIL
// ─────────────────────────────────────────────
class VenueBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> ground;
  const VenueBookingsScreen({super.key, required this.ground});
  @override
  State<VenueBookingsScreen> createState() => _VenueBookingsScreenState();
}

class _VenueBookingsScreenState extends State<VenueBookingsScreen> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = BookingService.getManagerBookings(_uid).listen((all) {
        final groundId = widget.ground['id'];
        if (mounted) {
          setState(() {
            _bookings =
                all.where((b) => b['groundId'] == groundId).toList();
            _loading = false;
          });
        }
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
      appBar: ModernAppBar(
        title: widget.ground['name'] ?? 'Bookings',
        gradient: AppTheme.secondaryGradient,
      ),
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
                      Text('No bookings for this venue',
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (_, i) {
                    final b = _bookings[i];
                    return ModernCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b['userName'] ?? b['userEmail'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        '${b['date']} • ${b['slot']}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant)),
                                  ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: (b['status'] == 'cancelled'
                                          ? AppTheme.errorColor
                                          : b['status'] == 'completed'
                                              ? AppTheme.primaryColor
                                              : AppTheme.successColor)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                b['status'] == 'completed'
                                    ? 'Completed'
                                    : b['status'] == 'cancelled'
                                        ? 'Cancelled'
                                        : 'Confirmed',
                                style: TextStyle(
                                    color: b['status'] == 'cancelled'
                                        ? AppTheme.errorColor
                                        : b['status'] == 'completed'
                                            ? AppTheme.primaryColor
                                            : AppTheme.successColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.payment_outlined,
                                size: 14, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(b['payment'] ?? '',
                                style: theme.textTheme.bodySmall),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
