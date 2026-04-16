import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import '../../services/booking_service.dart';
import '../../services/ground_service.dart';

class ManagerBookForCustomer extends StatefulWidget {
  const ManagerBookForCustomer({super.key});
  @override
  State<ManagerBookForCustomer> createState() => _ManagerBookForCustomerState();
}

class _ManagerBookForCustomerState extends State<ManagerBookForCustomer> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _grounds = [];
  StreamSubscription? _sub;

  // Form state
  Map<String, dynamic>? _selectedGround;
  DateTime? _selectedDate;
  String? _selectedSlot;
  String? _selectedPayment;
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();

  List<String> _bookedSlots = [];
  bool _loadingSlots = false;
  bool _saving = false;

  final List<String> _payments = ['JazzCash', 'EasyPaisa', 'Cash'];

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = GroundService.getManagerGrounds(_uid).listen((g) {
        if (mounted) setState(() => _grounds = g);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    super.dispose();
  }

  List<String> _getSlots() {
    final cat = _selectedGround?['category'] ?? '';
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

  Future<void> _fetchBooked() async {
    if (_selectedGround == null || _selectedDate == null) return;
    setState(() { _loadingSlots = true; _bookedSlots = []; _selectedSlot = null; });
    final gid = _selectedGround!['id'] as String? ?? '';
    final dk = _selectedDate!.toIso8601String().split('T')[0];
    final slots = await BookingService.getBookedSlots(gid, dk);
    if (mounted) setState(() { _bookedSlots = slots; _loadingSlots = false; });
  }

  bool _isDisabled(String slot) {
    final cat = _selectedGround?['category'] ?? '';
    if (_bookedSlots.contains(slot)) return true;
    if (cat == 'Cricket') {
      if (slot == 'Full-day') {
        return _bookedSlots.contains('9am to 2pm') ||
            _bookedSlots.contains('2pm to 6pm') ||
            _selectedSlot == '9am to 2pm' ||
            _selectedSlot == '2pm to 6pm';
      } else {
        return _bookedSlots.contains('Full-day') || _selectedSlot == 'Full-day';
      }
    }
    return false;
  }

  Future<void> _confirm() async {
    if (_selectedGround == null ||
        _selectedDate == null ||
        _selectedSlot == null ||
        _selectedPayment == null ||
        _customerNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _saving = true);
    final dk = _selectedDate!.toIso8601String().split('T')[0];
    final g = _selectedGround!;
    final customerName = _customerNameCtrl.text.trim();
    final customerPhone = _customerPhoneCtrl.text.trim();

    // Price
    int? price;
    final s = _selectedSlot!.toLowerCase();
    int h = 9;
    if (s.startsWith('2pm')) {
      h = 14;
    } else if (!s.startsWith('full')) {
      final p = s.split(RegExp(r'[-\s]')).first.trim();
      if (p.endsWith('am')) { h = int.tryParse(p.replaceAll('am', '')) ?? 9; }
      else if (p.endsWith('pm')) {
        final x = int.tryParse(p.replaceAll('pm', '')) ?? 12;
        h = x == 12 ? 12 : x + 12;
      }
    }
    final isDay = h >= 6 && h < 18;
    if (isDay && g['dayPrice'] != null) { price = (g['dayPrice'] as num).toInt(); }
    else if (!isDay && g['nightPrice'] != null) { price = (g['nightPrice'] as num).toInt(); }

    final id = await BookingService.createBooking(
      groundId: g['id'] ?? '',
      groundName: g['name'] ?? '',
      groundCategory: g['category'] ?? '',
      managerId: _uid ?? '',
      userId: '', // walk-in customer — no app account
      userEmail: customerPhone.isNotEmpty ? customerPhone : 'walk-in',
      userName: customerName,
      date: dk,
      slot: _selectedSlot!,
      payment: _selectedPayment!,
      imageUrls: (g['imageUrls'] as List?)?.cast<String>() ?? [],
      price: price,
    );

    if (mounted) {
      setState(() => _saving = false);
      if (id != null) {
        // Reset form
        setState(() {
          _selectedGround = null;
          _selectedDate = null;
          _selectedSlot = null;
          _selectedPayment = null;
          _bookedSlots = [];
          _customerNameCtrl.clear();
          _customerPhoneCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Booking confirmed for $customerName!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking failed. Try again.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dk = _selectedDate?.toIso8601String().split('T')[0];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(
        title: 'Book for Customer',
        gradient: AppTheme.secondaryGradient,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Customer Info ──
          _sectionTitle('Customer Details', Icons.person_rounded),
          const SizedBox(height: 10),
          TextFormField(
            controller: _customerNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Customer Name *',
              prefixIcon: Icon(Icons.person_outline_rounded,
                  color: AppTheme.secondaryColor),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _customerPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number (optional)',
              prefixIcon: Icon(Icons.phone_outlined,
                  color: AppTheme.secondaryColor),
            ),
          ),

          const SizedBox(height: 24),

          // ── Ground Selection ──
          _sectionTitle('Select Ground', Icons.stadium_rounded),
          const SizedBox(height: 10),
          if (_grounds.isEmpty)
            const Text('No grounds registered.',
                style: TextStyle(color: Colors.grey))
          else
            ...(_grounds.map((g) {
              final selected = _selectedGround?['id'] == g['id'];
              final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGround = g;
                    _selectedDate = null;
                    _selectedSlot = null;
                    _bookedSlots = [];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppTheme.secondaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56, height: 56,
                        child: imageUrls.isNotEmpty
                            ? Image.network(imageUrls.first, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.sports)))
                            : Container(color: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.sports)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(g['category'] ?? '',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12)),
                        if (g['dayPrice'] != null || g['nightPrice'] != null)
                          Text(
                            '${g['dayPrice'] != null ? 'Day: PKR ${g['dayPrice']}' : ''}'
                            '${g['dayPrice'] != null && g['nightPrice'] != null ? '  •  ' : ''}'
                            '${g['nightPrice'] != null ? 'Night: PKR ${g['nightPrice']}' : ''}',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.primaryColor),
                          ),
                      ],
                    )),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.secondaryColor),
                  ]),
                ),
              );
            })),

          if (_selectedGround != null) ...[
            const SizedBox(height: 24),

            // ── Date ──
            _sectionTitle('Select Date', Icons.calendar_today_rounded),
            const SizedBox(height: 10),
            GradientButton(
              text: dk ?? 'Pick a date',
              icon: Icons.calendar_today_rounded,
              gradient: AppTheme.secondaryGradient,
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) {
                  setState(() { _selectedDate = picked; _selectedSlot = null; });
                  await _fetchBooked();
                }
              },
            ),
          ],

          if (_selectedDate != null) ...[
            const SizedBox(height: 24),

            // ── Slots ──
            _sectionTitle('Select Slot', Icons.access_time_rounded),
            const SizedBox(height: 10),
            if (_loadingSlots)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getSlots().map((slot) {
                  final disabled = _isDisabled(slot);
                  final selected = _selectedSlot == slot;
                  final booked = _bookedSlots.contains(slot);
                  return GestureDetector(
                    onTap: disabled ? null : () => setState(() => _selectedSlot = slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? AppTheme.secondaryGradient : null,
                        color: disabled
                            ? colorScheme.surfaceContainerHighest
                            : selected
                                ? null
                                : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppTheme.secondaryColor
                              : disabled
                                  ? Colors.grey.withValues(alpha: 0.3)
                                  : colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        booked ? '$slot (Booked)' : slot,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : disabled
                                  ? Colors.grey
                                  : colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // ── Payment ──
            _sectionTitle('Payment Method', Icons.payment_rounded),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _payments.map((p) {
                final selected = _selectedPayment == p;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPayment = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: selected ? AppTheme.secondaryGradient : null,
                      color: selected ? null : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppTheme.secondaryColor
                            : colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(p,
                        style: TextStyle(
                            color: selected ? Colors.white : colorScheme.onSurface,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // ── Confirm ──
            _saving
                ? const Center(child: CircularProgressIndicator())
                : GradientButton(
                    text: 'Confirm Booking',
                    icon: Icons.check_circle_rounded,
                    gradient: AppTheme.secondaryGradient,
                    width: double.infinity,
                    height: 54,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    onPressed: _confirm,
                  ),
            const SizedBox(height: 40),
          ],
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 20, color: AppTheme.secondaryColor),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }
}
