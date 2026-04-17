// ignore_for_file: unused_local_variable, prefer_final_locals

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../user home/favourite/global_data.dart';
import '../../../../services/ground_service.dart';
import '../../../../services/booking_service.dart';
import '../../../../services/tournament_service.dart';
import '../../../../services/notification_service.dart';

class TournamentForm extends StatefulWidget {
  const TournamentForm({super.key});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // Dropdown selected values
  String? selectedSport;
  String? selectedTeam;
  String? selectedFormat;

  // Picked Dates
  DateTime? pickedStartDate;
  DateTime? pickedEndDate;

  // Stepper
  int currentStep = 0;

  // Dynamic team name controllers
  List<TextEditingController> teamControllers = [];

  // Grounds & slots
  List<Map<String, dynamic>> selectedGrounds = [];
  Map<String, List<String>> selectedSlotsPerGround = {};
  Map<String, Map<String, List<String>>> bookedSlots = {};
  List<Map<String, dynamic>> bookedGrounds = [];

  // Payment
  String? selectedPayment;

  bool _isSubmitting = false;

  // Fixtures
  List<List<String>> fixtures = [];

  // Lists
  final List<String> sports = ['Cricket', 'Football', 'Hockey', 'Volleyball', 'Tennis', 'Basketball'];
  final List<String> teams = ['4', '6', '8', '10', '12', '14', '16'];
  final List<String> format = ['Single Elimination', 'Double Elimination', 'Round Robin'];

  // Firestore grounds
  List<Map<String, dynamic>> sportsGrounds = [];
  StreamSubscription? _groundsSub;

  @override
  void initState() {
    super.initState();
    _groundsSub = GroundService.getGroundsByCategory('ALL').listen((grounds) {
      if (mounted) setState(() => sportsGrounds = grounds);
    });
  }

  @override
  void dispose() {
    _groundsSub?.cancel();
    for (var c in teamControllers) { c.dispose(); }
    name.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // Slot generator - consistent with categories.dart
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

  // Date picker
  Future<void> _pickDate({required BuildContext context, required bool isStart}) async {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? (pickedStartDate ?? tomorrow) : (pickedEndDate ?? tomorrow),
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(selectedDate);
        if (isStart) {
          pickedStartDate = selectedDate;
          startDateController.text = formatted;
          if (pickedEndDate != null && pickedEndDate!.isBefore(pickedStartDate!)) {
            pickedEndDate = null;
            endDateController.text = '';
          }
        } else {
          pickedEndDate = selectedDate;
          endDateController.text = formatted;
        }
      });
    }
  }

  void _createTeamControllers(int count) {
    teamControllers = List.generate(count, (_) => TextEditingController());
  }

  // Calculate required dates based on tournament format and fixtures
  List<DateTime> _calculateRequiredDates() {
    int totalMatches = fixtures.length;
    int slotsPerDay = selectedGrounds.fold(0, (sum, ground) {
      return sum + (selectedSlotsPerGround[ground['name']]?.length ?? 0);
    });
    
    if (slotsPerDay == 0) return [];
    
    int requiredDays = (totalMatches / slotsPerDay).ceil();
    
    List<DateTime> requiredDates = [];
    DateTime currentDate = pickedStartDate!;
    
    for (int i = 0; i < requiredDays; i++) {
      requiredDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return requiredDates;
  }

  // Book only required grounds for tournament duration
  void _bookAllGroundsForTournament() {
    bookedGrounds.clear();
    List<DateTime> requiredDates = _calculateRequiredDates();
    final user = FirebaseAuth.instance.currentUser;

    for (var ground in selectedGrounds) {
      List<String> slots = selectedSlotsPerGround[ground['name']] ?? [];
      for (var date in requiredDates) {
        for (var slot in slots) {
          String dateStr = DateFormat('yyyy-MM-dd').format(date);

          bookedGrounds.add({
            'ground': ground,
            'date': dateStr,
            'slot': slot,
            'payment': selectedPayment,
            'tournamentId': name.text,
            'isTournament': true,
          });

          GlobalData.addTournamentBooking(ground['name'], dateStr, slot);

          // GlobalData mein tournament booking add karo
          GlobalData.bookedGrounds.add({
            'ground': ground,
            'date': dateStr,
            'slot': slot,
            'payment': selectedPayment,
            'tournamentId': name.text,
            'isTournament': true,
            'status': 'confirmed',
            'bookingId': '',
          });
        }
      }
    }
  }

  // Proper fixture generator based on tournament format
  void _createFixtures() {
    List<String> teamNames = teamControllers.map((c) => c.text.trim()).toList();
    fixtures.clear();

    if (selectedFormat == 'Single Elimination') {
      _createSingleEliminationFixtures(teamNames);
    } else if (selectedFormat == 'Double Elimination') {
      _createDoubleEliminationFixtures(teamNames);
    } else if (selectedFormat == 'Round Robin') {
      _createRoundRobinFixtures(teamNames);
    }
  }

  void _createSingleEliminationFixtures(List<String> teams) {
    List<String> currentRound = List.from(teams);
    currentRound.shuffle();
    
    int round = 1;
    while (currentRound.length > 1) {
      List<String> nextRound = [];
      
      for (int i = 0; i < currentRound.length; i += 2) {
        if (i + 1 < currentRound.length) {
          fixtures.add([
            currentRound[i], 
            currentRound[i + 1], 
            'Round $round'
          ]);
          nextRound.add('Winner of ${currentRound[i]} vs ${currentRound[i + 1]}');
        } else {
          // Bye - team advances automatically
          fixtures.add([currentRound[i], 'BYE', 'Round $round']);
          nextRound.add(currentRound[i]);
        }
      }
      
      currentRound = nextRound;
      round++;
    }
  }

  void _createDoubleEliminationFixtures(List<String> teams) {
    // Winner's bracket
    _createSingleEliminationFixtures(teams);
    
    // Add loser's bracket matches (simplified)
    int losersMatches = (teams.length / 2).floor();
    for (int i = 0; i < losersMatches; i++) {
      fixtures.add(['Loser ${i + 1}', 'Loser ${i + 2}', 'Losers Bracket']);
    }
    
    // Grand Final
    fixtures.add(['Winners Champion', 'Losers Champion', 'Grand Final']);
  }

  void _createRoundRobinFixtures(List<String> teams) {
    List<String> teamsRR = List.from(teams);
    if (teamsRR.length.isOdd) teamsRR.add('BYE');
    
    int n = teamsRR.length;
    int rounds = n - 1;
    int half = n ~/ 2;
    
    List<String> arr = List.from(teamsRR);
    
    for (int r = 0; r < rounds; r++) {
      for (int i = 0; i < half; i++) {
        String t1 = arr[i];
        String t2 = arr[n - 1 - i];
        
        if (t1 != 'BYE' && t2 != 'BYE') {
          fixtures.add([t1, t2, 'Round ${r + 1}']);
        } else if (t1 != 'BYE' && t2 == 'BYE') {
          fixtures.add([t1, 'BYE', 'Round ${r + 1}']);
        }
      }
      
      // Rotate teams for next round
      List<String> newArr = [arr[0]];
      newArr.addAll(arr.sublist(n - 1));
      newArr.addAll(arr.sublist(1, n - 1));
      arr = newArr;
    }
  }

  // Create detailed match objects with scheduling
  List<Map<String, dynamic>> _createScheduledMatches() {
    List<Map<String, dynamic>> matches = [];
    
    // Create a map of available slots per date
    Map<String, List<Map<String, dynamic>>> availableSlots = {};
    for (var booking in bookedGrounds) {
      String date = booking['date'];
      availableSlots.putIfAbsent(date, () => []);
      availableSlots[date]!.add(booking);
    }
    
    // Convert fixtures to detailed match objects
    int matchId = 1;
    int slotIndex = 0;
    List<Map<String, dynamic>> allSlots = [];
    
    // Flatten all available slots
    availableSlots.forEach((date, slots) {
      for (var slot in slots) {
        allSlots.add(slot);
      }
    });
    
    for (int i = 0; i < fixtures.length; i++) {
      List<String> fixture = fixtures[i];
      
      if (fixture.length >= 3) {
        String team1 = fixture[0];
        String team2 = fixture[1];
        String round = fixture[2];
        
        // Assign slot if available
        Map<String, dynamic>? assignedSlot;
        if (slotIndex < allSlots.length) {
          assignedSlot = allSlots[slotIndex];
          slotIndex++;
        }
        
        // Determine match type for special rounds
        String matchType = 'regular';
        if (round.toLowerCase().contains('final')) {
          if (round.toLowerCase().contains('grand')) {
            matchType = 'grand_final';
          } else {
            matchType = 'final';
          }
        } else if (round.toLowerCase().contains('semi')) {
          matchType = 'semi_final';
        }
        
        matches.add({
          'id': matchId++,
          'team1': team1,
          'team2': team2,
          'round': round,
          'matchType': matchType,
          'date': assignedSlot?['date'] ?? '',
          'time': assignedSlot?['slot'] ?? '',
          'ground': assignedSlot != null
              ? ((assignedSlot['ground'] as Map?)?['name'] as String? ??
                  assignedSlot['groundName'] as String? ??
                  '')
              : '',
          'status': 'scheduled',
          'result': null,
          'winner': null,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }
    
    return matches;
  }

  // Assign grounds to fixtures based on availability (legacy method for backward compatibility)
  void _assignGroundsToFixtures() {
    if (fixtures.isEmpty || bookedGrounds.isEmpty) return;
    
    // Create a map of available slots per date
    Map<String, List<Map<String, dynamic>>> availableSlots = {};
    for (var booking in bookedGrounds) {
      String date = booking['date'];
      availableSlots.putIfAbsent(date, () => []);
      availableSlots[date]!.add(booking);
    }
    
    // Assign fixtures to available slots
    int fixtureIndex = 0;
    for (var dateEntry in availableSlots.entries) {
      String date = dateEntry.key;
      List<Map<String, dynamic>> daySlots = dateEntry.value;
      
      for (var slot in daySlots) {
        if (fixtureIndex < fixtures.length) {
          // Add ground and date info to fixture
          fixtures[fixtureIndex].add(slot['ground']['name']);
          fixtures[fixtureIndex].add(date);
          fixtures[fixtureIndex].add(slot['slot']);
          fixtureIndex++;
        }
      }
    }
  }

  // Move to next step or page
  void _nextStep() async {
    if (currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        if (selectedTeam == null || selectedFormat == null || selectedSport == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
          return;
        }
        _createTeamControllers(int.parse(selectedTeam!));
        setState(() => currentStep++);
      }
    } else if (currentStep == 1) {
      bool allFilled = teamControllers.every((c) => c.text.trim().isNotEmpty);
      if (!allFilled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter all team names")));
        return;
      }
      setState(() => currentStep++);
    } else if (currentStep == 2) {
      if (selectedGrounds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select at least one ground")));
        return;
      }
      // Agle step ke liye booked slots pre-fetch karo
      _fetchBookedSlotsForGrounds();
      setState(() => currentStep++);
    } else if (currentStep == 3) {
      // Slots step mein enter karte waqt Firestore se booked slots fetch karo
      await _fetchBookedSlotsForGrounds();
      if (!mounted) return;
      bool allHaveSlots = selectedGrounds.every((g) {
        final name = g['name'];
        final picked = selectedSlotsPerGround[name] ?? [];
        return picked.isNotEmpty;
      });
      if (!allHaveSlots) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select slots for each selected ground")));
        return;
      }
      setState(() => currentStep++);
    } else if (currentStep == 4) {
      if (selectedPayment == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a payment method")));
        return;
      }

      // Loading show karo
      setState(() => _isSubmitting = true);

      // Create fixtures first to calculate required dates
      _createFixtures();
      _bookAllGroundsForTournament();
      _assignGroundsToFixtures();
      List<Map<String, dynamic>> scheduledMatches = _createScheduledMatches();

      final user = FirebaseAuth.instance.currentUser;
      List<String> teamNames = teamControllers.map((c) => c.text.trim()).toList();

      Map<String, dynamic> tournamentData = {
        'name': name.text,
        'sport': selectedSport ?? '',
        'format': selectedFormat ?? '',
        'teams': int.parse(selectedTeam ?? '0'),
        'startDate': startDateController.text,
        'endDate': endDateController.text,
        'actualEndDate': _calculateRequiredDates().isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(_calculateRequiredDates().last)
            : endDateController.text,
        'bookedGrounds': bookedGrounds,
        'fixtures': fixtures,
        'matches': scheduledMatches,
        'teamNames': teamNames,
        'status': 'active',
        'createdBy': user?.uid ?? '',
        'createdByName': user?.displayName ?? user?.email ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      try {
        // Firestore mein save karo aur ID lo
        final firestoreId = await TournamentService.createTournament(tournamentData);
        if (firestoreId == null) throw Exception('Failed to save tournament');

        // Firestore ID use karo everywhere
        tournamentData['id'] = firestoreId;

        // GlobalData initialize karo Firestore ID se
        GlobalData.initializeTournament(firestoreId, teamNames, scheduledMatches);

        // Bookings save karo Firestore ID ke saath
        for (final bg in bookedGrounds) {
          final ground = bg['ground'] as Map<String, dynamic>? ?? {};
          BookingService.createBooking(
            groundId: ground['id'] ?? '',
            groundName: ground['name'] ?? '',
            groundCategory: ground['category'] ?? '',
            managerId: ground['managerId'] ?? '',
            userId: user?.uid ?? '',
            userEmail: user?.email ?? '',
            userName: user?.displayName ?? user?.email ?? '',
            date: bg['date'] ?? '',
            slot: bg['slot'] ?? '',
            payment: bg['payment'] ?? selectedPayment ?? '',
            imageUrls: (ground['imageUrls'] as List?)?.cast<String>() ?? [],
            tournamentId: firestoreId,
            tournamentName: name.text,
          );
        }

        // Saari bookings save hone ke baad ek summary notification bhejo
        final uniqueManagerIds = bookedGrounds
            .map((bg) => (bg['ground'] as Map?)?['managerId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
        for (final mid in uniqueManagerIds) {
          NotificationService.sendTournamentBookingNotification(
            managerId: mid,
            userId: user?.uid ?? '',
            tournamentName: name.text,
            creatorName: user?.displayName ?? user?.email ?? '',
            slotCount: bookedGrounds.length,
          );
        }

        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Tournament created! Payment via $selectedPayment')));
          Navigator.pop(context, tournamentData);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create tournament. Try again.'),
                  backgroundColor: Colors.red));
        }
      }
    }
  }

  void _prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  // === UI helpers ===
  Widget _buildLabel(String text) => Text(
    text, 
    style: const TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w600,
      color: Color(0xFF00D9FF),
    ),
  );

  Widget _buildTextField({required TextEditingController controller, required String hintText, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: hintText,
        filled: true,
        fillColor: const Color(0xFF0A1929),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({required TextEditingController controller, required VoidCallback onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Select Date",
        labelText: "Select Date",
        suffixIcon: const Icon(Icons.calendar_month, color: Color(0xFF00D9FF)),
        filled: true,
        fillColor: const Color(0xFF0A1929),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: (value) => value!.isEmpty ? "Please select date" : null,
    );
  }

  Widget _groundsSelectionStep() {
    List<Map<String, dynamic>> filtered = sportsGrounds
        .where((g) => (g['category'] ?? '') == selectedSport)
        .toList();

    if (sportsGrounds.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No grounds available for selected sport.\nAsk a manager to register one.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((g) {
        bool selected = selectedGrounds.any((sg) => sg['id'] == g['id']);
        final imageUrls = (g['imageUrls'] as List?)?.cast<String>() ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 2,
          child: CheckboxListTile(
            secondary: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: imageUrls.isNotEmpty
                    ? Image.network(imageUrls.first, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.sports))
                    : const Icon(Icons.sports),
              ),
            ),
            title: Text(g['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(g['location'] ?? g['category'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            value: selected,
            activeColor: const Color(0xFF1A659E),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  selectedGrounds.add(g);
                  selectedSlotsPerGround.putIfAbsent(g['name'], () => []);
                } else {
                  selectedGrounds.removeWhere((sg) => sg['id'] == g['id']);
                  selectedSlotsPerGround.remove(g['name']);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  // Firestore se booked slots cache — groundId -> date -> List<slot>
  final Map<String, Map<String, List<String>>> _firestoreBookedSlots = {};
  bool _loadingBookedSlots = false;

  /// Selected grounds aur dates ke liye Firestore se booked slots fetch karo
  Future<void> _fetchBookedSlotsForGrounds() async {
    if (pickedStartDate == null || selectedGrounds.isEmpty) return;
    setState(() => _loadingBookedSlots = true);
    _firestoreBookedSlots.clear();

    // Start date se end date tak + 30 extra days (tournament duration cover karo)
    final end = pickedEndDate ?? pickedStartDate!.add(const Duration(days: 60));
    final days = end.difference(pickedStartDate!).inDays + 1;
    final dates = List.generate(days, (i) {
      final d = pickedStartDate!.add(Duration(days: i));
      return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
    });

    for (final g in selectedGrounds) {
      final gid = g['id'] as String? ?? '';
      if (gid.isEmpty) continue;
      _firestoreBookedSlots[gid] = {};
      for (final date in dates) {
        try {
          final slots = await BookingService.getBookedSlots(gid, date);
          if (slots.isNotEmpty) _firestoreBookedSlots[gid]![date] = slots;
        } catch (e) {
          debugPrint('fetchBookedSlots ERROR: $e');
        }
      }
    }
    if (mounted) setState(() => _loadingBookedSlots = false);
  }

  bool _isSlotBookedOnAnyDate(String groundId, String slot) {
    final groundSlots = _firestoreBookedSlots[groundId];
    if (groundSlots == null || groundSlots.isEmpty) return false;
    // Check if this slot is booked on ANY of the tournament dates
    return groundSlots.values.any((slots) => slots.contains(slot));
  }

  Widget _slotsSelectionStep() {
    if (_loadingBookedSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Checking available slots...', style: TextStyle(color: Colors.grey)),
          ]),
        ),
      );
    }
    return Column(
      children: selectedGrounds.map((g) {
        String gName = g['name'];
        String gId = g['id'] as String? ?? '';
        String category = g['category'];
        List<String> available = getSlots(category);
        List<String> picked = selectedSlotsPerGround[gName] ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          elevation: 3,
          child: ExpansionTile(
            title: Text(gName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              "Selected: ${picked.length} slot(s) • $category",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            children: available.map((slot) {
              bool checked = picked.contains(slot);
              // Firestore mein already booked hai?
              bool isFirestoreBooked = _isSlotBookedOnAnyDate(gId, slot);
              bool isDisabled = isFirestoreBooked;

              // Handle cricket slot conflicts — Firestore booked + user picked
              if (category == "Cricket") {
                if (slot == "Full-day") {
                  // Full-day disable if any partial slot is booked (Firestore) OR picked by user
                  final partialFirestoreBooked =
                      _isSlotBookedOnAnyDate(gId, "9am to 2pm") ||
                      _isSlotBookedOnAnyDate(gId, "2pm to 6pm");
                  isDisabled = isDisabled ||
                      partialFirestoreBooked ||
                      picked.contains("9am to 2pm") ||
                      picked.contains("2pm to 6pm");
                } else {
                  // Partial slots disable if Full-day is booked (Firestore) OR picked by user
                  final fullDayFirestoreBooked = _isSlotBookedOnAnyDate(gId, "Full-day");
                  isDisabled = isDisabled ||
                      fullDayFirestoreBooked ||
                      picked.contains("Full-day");
                }
              }

              String? subtitle;
              if (isFirestoreBooked) {
                subtitle = "Already booked by another tournament";
              } else if (category == "Cricket" && isDisabled) {
                subtitle = slot == "Full-day"
                    ? "Cannot select with individual slots"
                    : "Cannot select with full-day";
              }

              return CheckboxListTile(
                dense: true,
                title: Text(
                  isFirestoreBooked ? '$slot (Booked)' : slot,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 13,
                  ),
                ),
                subtitle: subtitle != null
                    ? Text(subtitle,
                        style: TextStyle(
                            color: isFirestoreBooked ? Colors.red : Colors.orange,
                            fontSize: 11))
                    : null,
                value: checked,
                activeColor: const Color(0xFF1A659E),
                onChanged: isDisabled ? null : (v) {
                  setState(() {
                    if (v == true) {
                      if (category == "Cricket") {
                        if (slot == "Full-day") {
                          picked.removeWhere((s) => s == "9am to 2pm" || s == "2pm to 6pm");
                        } else {
                          picked.removeWhere((s) => s == "Full-day");
                        }
                      }
                      picked.add(slot);
                    } else {
                      picked.remove(slot);
                    }
                    selectedSlotsPerGround[gName] = picked;
                  });
                },
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 16.0 : 8.0;
    final cardPadding = screenWidth > 600 ? 20.0 : 12.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Create Tournament",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A659E),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
            color: Colors.white,
            child: Row(
              children: List.generate(5, (index) {
                bool isActive = index <= currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1A659E) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Stepper(
                    currentStep: currentStep,
                    onStepContinue: _nextStep,
                    onStepCancel: _prevStep,
                    type: StepperType.vertical,
                    physics: const ClampingScrollPhysics(),
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D9FF),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth > 600 ? 32 : 24, 
                                  vertical: 14
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                              ),
                              child: _isSubmitting && currentStep == 4
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text(
                                      currentStep == 4 ? "Create Tournament" : "Next",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                            ),
                            if (currentStep > 0)
                              OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF00D9FF),
                                  side: const BorderSide(color: Color(0xFF00D9FF), width: 2),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth > 600 ? 32 : 24, 
                                    vertical: 14
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      Step(
                        title: const Text("Details"),
                        isActive: currentStep >= 0,
                        content: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel("Tournament Name"),
                              const SizedBox(height: 4),
                              _buildTextField(
                                  controller: name,
                                  hintText: "e.g. Summer Soccer Clash",
                                  validator: (v) => v!.isEmpty ? "Required" : null),
                              const SizedBox(height: 12),
                              _buildLabel("Sport"),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedSport,
                                style: const TextStyle(color: Colors.white),
                                dropdownColor: const Color(0xFF132F4C),
                                decoration: InputDecoration(
                                  filled: true, 
                                  fillColor: const Color(0xFF0A1929),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                ),
                                hint: const Text("Select a sport"),
                                items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (v) => setState(() {
                                  selectedSport = v;
                                  selectedGrounds.clear();
                                }),
                              ),
                              const SizedBox(height: 12),
                              _buildLabel("Teams"),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedTeam,
                                style: const TextStyle(color: Colors.white),
                                dropdownColor: const Color(0xFF132F4C),
                                decoration: InputDecoration(
                                  filled: true, 
                                  fillColor: const Color(0xFF0A1929),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                ),
                                hint: const Text("Select teams count"),
                                items: teams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (v) => setState(() => selectedTeam = v),
                              ),
                              const SizedBox(height: 12),
                              _buildLabel("Format"),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedFormat,
                                style: const TextStyle(color: Colors.white),
                                dropdownColor: const Color(0xFF132F4C),
                                decoration: InputDecoration(
                                  filled: true, 
                                  fillColor: const Color(0xFF0A1929),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                ),
                                hint: const Text("Select format"),
                                items: format.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                                onChanged: (v) => setState(() => selectedFormat = v),
                              ),
                              const SizedBox(height: 12),
                              _buildLabel("Start Date"),
                              const SizedBox(height: 4),
                              _buildDateField(controller: startDateController, onTap: () => _pickDate(context: context, isStart: true)),
                              const SizedBox(height: 12),
                              _buildLabel("End Date"),
                              const SizedBox(height: 4),
                              _buildDateField(controller: endDateController, onTap: () => _pickDate(context: context, isStart: false)),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: const Text("Teams"), 
                        isActive: currentStep >= 1, 
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: teamControllers.asMap().entries.map((e) {
                            int idx = e.key + 1;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                controller: e.value,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: "Team $idx",
                                  hintText: "Enter team $idx name",
                                  filled: true, 
                                  fillColor: const Color(0xFF0A1929),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Step(title: const Text("Grounds"), isActive: currentStep >= 2, content: _groundsSelectionStep()),
                      Step(title: const Text("Slots"), isActive: currentStep >= 3, content: _slotsSelectionStep()),
                      Step(
                        title: const Text("Payment"),
                        isActive: currentStep >= 4,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Select Payment Method", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    dense: true,
                                    leading: RadioGroup<String>(
                                      groupValue: selectedPayment,
                                      onChanged: (v) => setState(() => selectedPayment = v),
                                      child: Radio<String>(
                                        value: "JazzCash",
                                        activeColor: const Color(0xFF00D9FF),
                                      ),
                                    ),
                                    title: const Text("JazzCash", style: TextStyle(fontSize: 14)),
                                    subtitle: const Text("Mobile wallet payment", style: TextStyle(fontSize: 12)),
                                    onTap: () => setState(() => selectedPayment = "JazzCash"),
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    dense: true,
                                    leading: RadioGroup<String>(
                                      groupValue: selectedPayment,
                                      onChanged: (v) => setState(() => selectedPayment = v),
                                      child: Radio<String>(
                                        value: "EasyPaisa",
                                        activeColor: const Color(0xFF00D9FF),
                                      ),
                                    ),
                                    title: const Text("EasyPaisa", style: TextStyle(fontSize: 14)),
                                    subtitle: const Text("Mobile wallet payment", style: TextStyle(fontSize: 12)),
                                    onTap: () => setState(() => selectedPayment = "EasyPaisa"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}