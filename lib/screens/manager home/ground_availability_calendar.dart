import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/booking_service.dart';

class GroundAvailabilityCalendar extends StatefulWidget {
  final String groundId;
  final String groundName;

  const GroundAvailabilityCalendar({
    super.key,
    required this.groundId,
    required this.groundName,
  });

  @override
  State<GroundAvailabilityCalendar> createState() =>
      _GroundAvailabilityCalendarState();
}

class _GroundAvailabilityCalendarState
    extends State<GroundAvailabilityCalendar> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _bookingsByDate = {};
  StreamSubscription? _sub;

  static const _slots = [
    '9am-10am', '10am-11am', '11am-12pm',
    '12pm-1pm', '1pm-2pm', '2pm-6pm',
    '6pm-7pm', '7pm-8pm', '8pm-9pm', 'Full-day',
  ];

  @override
  void initState() {
    super.initState();
    _sub = BookingService.getGroundBookings(widget.groundId).listen((bookings) {
      if (!mounted) return;
      final map = <String, List<Map<String, dynamic>>>{};
      for (final b in bookings) {
        if (b['status'] == 'cancelled') continue;
        final date = b['date'] as String? ?? '';
        map.putIfAbsent(date, () => []).add(b);
      }
      setState(() => _bookingsByDate = map);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isBooked(DateTime day) => _bookingsByDate.containsKey(_dateKey(day));
  bool _isFullyBooked(DateTime day) {
    final bookings = _bookingsByDate[_dateKey(day)] ?? [];
    final bookedSlots = bookings.map((b) => b['slot'] as String? ?? '').toSet();
    return bookedSlots.contains('Full-day') || bookedSlots.length >= _slots.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final days = _daysInMonth(_focusedMonth);
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ModernAppBar(
        title: widget.groundName,
        gradient: AppTheme.secondaryGradient,
      ),
      body: Column(
        children: [
          // Month navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() => _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant)),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: days.length + firstWeekday,
              itemBuilder: (_, i) {
                if (i < firstWeekday) return const SizedBox();
                final day = days[i - firstWeekday];
                final key = _dateKey(day);
                final isSelected = _selectedDay != null &&
                    _dateKey(_selectedDay!) == key;
                final isToday = _dateKey(DateTime.now()) == key;
                final booked = _isBooked(day);
                final fullyBooked = _isFullyBooked(day);
                final isPast = day.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)));

                Color bgColor = Colors.transparent;
                Color textColor = colorScheme.onSurface;

                if (isSelected) {
                  bgColor = AppTheme.primaryColor;
                  textColor = Colors.white;
                } else if (fullyBooked) {
                  bgColor = AppTheme.errorColor.withValues(alpha: 0.2);
                  textColor = AppTheme.errorColor;
                } else if (booked) {
                  bgColor = AppTheme.warningColor.withValues(alpha: 0.2);
                  textColor = AppTheme.warningColor;
                } else if (isPast) {
                  textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(color: AppTheme.primaryColor, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AppTheme.successColor, 'Available'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.warningColor, 'Partial'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.errorColor, 'Full'),
              ],
            ),
          ),

          const Divider(),

          // Selected day slots
          if (_selectedDay != null)
            Expanded(
              child: _buildSlotView(_selectedDay!, colorScheme, theme),
            )
          else
            Expanded(
              child: Center(
                child: Text('Tap a date to see slots',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotView(DateTime day, ColorScheme colorScheme, ThemeData theme) {
    final key = _dateKey(day);
    final bookings = _bookingsByDate[key] ?? [];
    final bookedSlots = bookings.map((b) => b['slot'] as String? ?? '').toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            DateFormat('EEEE, d MMMM').format(day),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _slots.length,
            itemBuilder: (_, i) {
              final slot = _slots[i];
              final isBooked = bookedSlots.contains(slot) ||
                  bookedSlots.contains('Full-day');
              final booking = bookings.firstWhere(
                  (b) => b['slot'] == slot || b['slot'] == 'Full-day',
                  orElse: () => {});

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isBooked
                      ? AppTheme.errorColor.withValues(alpha: 0.1)
                      : AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBooked
                        ? AppTheme.errorColor.withValues(alpha: 0.3)
                        : AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(children: [
                  Icon(
                    isBooked
                        ? Icons.lock_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isBooked
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slot,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isBooked
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor)),
                        if (isBooked && booking.isNotEmpty)
                          Text(
                            booking['userName'] ?? booking['userEmail'] ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isBooked ? 'Booked' : 'Free',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      );
}
