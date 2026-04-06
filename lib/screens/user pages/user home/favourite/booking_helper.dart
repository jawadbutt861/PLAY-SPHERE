import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../main.dart';
import '../../../../services/booking_service.dart';

class BookingHelper {
  static void showBookingDialog(BuildContext context, Map<String, dynamic> ground) {
    showDialog(
      context: context,
      builder: (_) => _BookingDialog(ground: ground, outerContext: context),
    );
  }
}

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
  String? _payment;
  List<String> _bookedSlots = [];
  bool _loadingSlots = false;
  final List<String> _payments = ['JazzCash', 'EasyPaisa'];

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
            _slot == '9am to 2pm' ||
            _slot == '2pm to 6pm';
      } else {
        return _bookedSlots.contains('Full-day') || _slot == 'Full-day';
      }
    }
    return false;
  }

  String _slotLabel(String slot) {
    if (_bookedSlots.contains(slot)) return '$slot (Booked)';
    if (_isDisabled(slot)) return '$slot (Unavailable)';
    return slot;
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = _date?.toIso8601String().split('T')[0];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          child: Text('Book ${widget.ground['name'] ?? 'Venue'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Date picker
            GradientButton(
              text: _date == null ? 'Select Date' : dateKey!,
              icon: Icons.calendar_today,
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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

            // Slots
            if (_date != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Time Slot:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor)),
              ),
              if (_loadingSlots)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ..._getSlots().map((slot) {
                  final disabled = _isDisabled(slot);
                  return ListTile(
                    dense: true,
                    leading: Radio<String>(
                      value: slot,
                      groupValue: _slot,
                      onChanged: disabled ? null : (v) => setState(() => _slot = v),
                    ),
                    title: Text(_slotLabel(slot),
                        style: TextStyle(
                            color: disabled ? Colors.grey : null,
                            fontSize: 13)),
                    onTap: disabled ? null : () => setState(() => _slot = slot),
                  );
                }),
            ],

            // Payment
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Payment Method:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor)),
            ),
            ..._payments.map((p) => ListTile(
                  dense: true,
                  leading: Radio<String>(
                    value: p,
                    groupValue: _payment,
                    onChanged: (v) => setState(() => _payment = v),
                  ),
                  title: Text(p, style: const TextStyle(fontSize: 13)),
                  onTap: () => setState(() => _payment = p),
                )),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        GradientButton(
          text: 'Confirm',
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          onPressed: () {
            if (_date == null || _slot == null || _payment == null) {
              ScaffoldMessenger.of(widget.outerContext).showSnackBar(
                  const SnackBar(content: Text('Please select all options')));
              return;
            }
            final dk = _date!.toIso8601String().split('T')[0];
            final user = FirebaseAuth.instance.currentUser;

            // Price
            int? price;
            final s = _slot!.toLowerCase();
            int h = 9;
            if (s.startsWith('2pm')) h = 14;
            else if (!s.startsWith('full')) {
              final p = s.split(RegExp(r'[-\s]')).first.trim();
              if (p.endsWith('am')) h = int.tryParse(p.replaceAll('am', '')) ?? 9;
              else if (p.endsWith('pm')) {
                final x = int.tryParse(p.replaceAll('pm', '')) ?? 12;
                h = x == 12 ? 12 : x + 12;
              }
            }
            final isDay = h >= 6 && h < 18;
            if (isDay && widget.ground['dayPrice'] != null) {
              price = (widget.ground['dayPrice'] as num).toInt();
            } else if (!isDay && widget.ground['nightPrice'] != null) {
              price = (widget.ground['nightPrice'] as num).toInt();
            }

            BookingService.createBooking(
              groundId: widget.ground['id'] ?? '',
              groundName: widget.ground['name'] ?? '',
              groundCategory: widget.ground['category'] ?? '',
              managerId: widget.ground['managerId'] ?? '',
              userId: user?.uid ?? '',
              userEmail: user?.email ?? '',
              userName: user?.displayName ?? user?.email ?? '',
              date: dk,
              slot: _slot!,
              payment: _payment!,
              imageUrls: (widget.ground['imageUrls'] as List?)?.cast<String>() ?? [],
              price: price,
            );

            Navigator.pop(context);
            ScaffoldMessenger.of(widget.outerContext).showSnackBar(SnackBar(
              content: const Text('Booking confirmed!'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          },
        ),
      ],
    );
  }
}
