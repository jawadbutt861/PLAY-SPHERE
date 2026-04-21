import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../main.dart';
import '../../../../services/booking_service.dart';
import '../../../booking_chat_screen.dart';

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
  List<String> _bookedSlots = [];
  bool _loadingSlots = false;
  bool _showSummary = false;
  bool _placingOrder = false;

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
    // Only disable if already booked in Firestore — not based on user's current selection
    if (_bookedSlots.contains(slot)) return true;
    final cat = widget.ground['category'] ?? '';
    if (cat == 'Cricket') {
      // Full-day disable if any partial slot is Firestore-booked
      if (slot == 'Full-day') {
        return _bookedSlots.contains('9am to 2pm') ||
            _bookedSlots.contains('2pm to 6pm');
      } else {
        // Partial slots disable if Full-day is Firestore-booked
        return _bookedSlots.contains('Full-day');
      }
    }
    return false;
  }

  void _selectSlot(String slot) {
    final cat = widget.ground['category'] ?? '';
    setState(() {
      if (cat == 'Cricket') {
        if (slot == 'Full-day') {
          // Full-day selected — deselect partials
          _slot = slot;
        } else {
          // Partial selected — deselect full-day if it was selected
          if (_slot == 'Full-day') _slot = null;
          _slot = slot;
        }
      } else {
        _slot = slot;
      }
    });
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
    if (isDay && widget.ground['dayPrice'] != null) return (widget.ground['dayPrice'] as num).toInt();
    if (!isDay && widget.ground['nightPrice'] != null) return (widget.ground['nightPrice'] as num).toInt();
    return null;
  }

  void _placeOrder() async {
    if (_placingOrder) return;
    setState(() => _placingOrder = true);
    final dk = _date!.toIso8601String().split('T')[0];
    final user = FirebaseAuth.instance.currentUser;
    final managerId = widget.ground['managerId'] as String? ?? '';

    final bookingId = await BookingService.createBooking(
      groundId: widget.ground['id'] ?? '',
      groundName: widget.ground['name'] ?? '',
      groundCategory: widget.ground['category'] ?? '',
      managerId: managerId,
      userId: user?.uid ?? '',
      userEmail: user?.email ?? '',
      userName: user?.displayName ?? user?.email ?? '',
      date: dk,
      slot: _slot!,
      payment: 'Pay at Venue',
      imageUrls: (widget.ground['imageUrls'] as List?)?.cast<String>() ?? [],
      price: _calcPrice(),
    );
    if (!mounted || bookingId == null) return;

    // Fetch manager payment info immediately
    Map<String, dynamic> paymentInfo = {};
    if (managerId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(managerId)
            .get();
        if (doc.exists) {
          final pi = doc.data()?['paymentInfo'];
          if (pi is Map) paymentInfo = Map<String, dynamic>.from(pi);
        }
      } catch (_) {}
    }

    // Send system welcome message + payment card to chat
    final chatCol = FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .collection('chat');

    await chatCol.add({
      'text': '🎉 Booking request sent! Waiting for manager approval.',
      'senderId': 'system',
      'senderName': 'System',
      'isSystem': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatCol.add({
      'senderId': 'system',
      'senderName': 'System',
      'isManager': true,
      'isPaymentCard': true,
      'paymentInfo': paymentInfo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      widget.outerContext,
      MaterialPageRoute(
        builder: (_) => BookingChatScreen(
          bookingId: bookingId,
          booking: {
            'groundName': widget.ground['name'] ?? '',
            'groundCategory': widget.ground['category'] ?? '',
            'date': dk,
            'slot': _slot!,
            'payment': 'Pay at Venue',
            'price': _calcPrice(),
            'managerId': managerId,
            'status': 'pending',
          },
          isManager: false,
        ),
      ),
    );
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
      content: SizedBox(
        width: double.maxFinite,
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
              child: _placingOrder
                  ? Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        ),
                      ),
                    )
                  : GradientButton(
                      text: _showSummary ? 'Place Order' : 'Review Order',
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      textStyle: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      onPressed: () {
                        if (_showSummary) {
                          _placeOrder();
                        } else {
                          if (_date == null || _slot == null) {
                            ScaffoldMessenger.of(widget.outerContext).showSnackBar(
                              SnackBar(
                                content: const Text('Please select date and slot'),
                                backgroundColor: AppTheme.warningColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
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
      // Date picker
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
              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
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
                onChanged: disabled ? (v) {} : (v) => _selectSlot(slot),
                child: Radio<String>(value: slot),
              ),
              title: Text(label, style: TextStyle(color: disabled ? Colors.grey : null, fontSize: 13)),
              onTap: disabled ? null : () => _selectSlot(slot),
            );
          }),
      ],
    ]);
  }

  Widget _buildSummary(String dk, int? price, ColorScheme colorScheme) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Order summary card — Binance style
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
      // Pending notice
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
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor)),
      ]),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2));
}
