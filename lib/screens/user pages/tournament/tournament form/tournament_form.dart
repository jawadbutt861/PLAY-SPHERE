// ignore_for_file: unused_local_variable, prefer_final_locals

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../user home/favourite/global_data.dart';

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

  // Fixtures
  List<List<String>> fixtures = [];

  // Lists
  final List<String> sports = ['Cricket', 'Football', 'Hockey', 'Volleyball', 'Tennis', 'Basketball'];
  final List<String> teams = ['4', '6', '8', '10', '12', '14', '16'];
  final List<String> format = ['Single Elimination', 'Double Elimination', 'Round Robin'];

  // Grounds - Using the same structure as categories.dart
  List<Map<String, dynamic>> sportsGrounds = [
    // Cricket
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Buitems Cricket Ground"},
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Shola Cricket Ground"},
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Haideri Cricket Ground"},
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Bolan Cricket Ground"},

    // Football
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Buitems Football Ground"},
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Shahbaz Football Ground"},
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Railway Football Ground"},
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Spini Football Ground"},

    // Tennis
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "Buitems Tennis Court"},
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "UoB Tennis Court"},
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "Alhamd Tennis Court"},
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "NUML Court"},

    // Basketball
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "Buitems Basketball Court"},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "UoB Basketball Court"},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "Alhamd Basketball Court"},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "NUML Basketball Court"},

    // Hockey
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "Ayub Hockey Ground"},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "Buitems Hockey Ground"},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "UoB Hockey Ground"},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "NUML Hockey Ground"},

    // Volleyball
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Buitems Volleyball Court"},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Ayub Volleyball Court"},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Alhamd Volleyball Court"},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "UoB Volleyball Court"},
  ];

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
    
    // Calculate only the dates needed for the tournament
    List<DateTime> requiredDates = _calculateRequiredDates();
    
    // Book each selected ground for required dates and selected slots
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
            'tournamentId': name.text, // Add tournament identifier
          });
          
          // Add to global tournament bookings to prevent conflicts
          GlobalData.addTournamentBooking(ground['name'], dateStr, slot);
          
          // Also add to global booked grounds
          GlobalData.bookedGrounds.add({
            'ground': ground,
            'date': dateStr,
            'slot': slot,
            'payment': selectedPayment,
            'tournamentId': name.text,
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
          'ground': assignedSlot?['ground']['name'] ?? '',
          'status': 'scheduled', // scheduled, in_progress, completed
          'result': null, // win, abandoned
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
  void _nextStep() {
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
      setState(() => currentStep++);
    } else if (currentStep == 3) {
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
      
      // Create fixtures first to calculate required dates
      _createFixtures();
      
      // Book only required grounds for tournament duration
      _bookAllGroundsForTournament();
      _assignGroundsToFixtures();
      
      // Create scheduled matches
      List<Map<String, dynamic>> scheduledMatches = _createScheduledMatches();
      
      // Create tournament data
      String tournamentId = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> teamNames = teamControllers.map((c) => c.text.trim()).toList();
      
      Map<String, dynamic> tournamentData = {
        'id': tournamentId,
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
        'fixtures': fixtures, // Keep for backward compatibility
        'matches': scheduledMatches, // New detailed match system
        'teamNames': teamNames,
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Initialize tournament in global data
      GlobalData.initializeTournament(tournamentId, teamNames, scheduledMatches);
      
      // Add to global tournaments
      GlobalData.tournaments.add(tournamentData);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tournament created successfully! Payment via $selectedPayment")));
      
      // Navigate back to tournament page with tournament data
      Navigator.pop(context, tournamentData);
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
    List<Map<String, dynamic>> filtered = sportsGrounds.where((g) => g['category'] == selectedSport).toList();
    
    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No grounds available for selected sport",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    
    return Column(
      children: filtered.map((g) {
        bool selected = selectedGrounds.any((sg) => sg['name'] == g['name']);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          elevation: 2,
          child: CheckboxListTile(
            title: Text(
              g['name'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              g['category'],
              style: const TextStyle(color: Colors.grey),
            ),
            value: selected,
            activeColor: const Color(0xFF1A659E),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  selectedGrounds.add(g);
                  selectedSlotsPerGround.putIfAbsent(g['name'], () => []);
                } else {
                  selectedGrounds.removeWhere((sg) => sg['name'] == g['name']);
                  selectedSlotsPerGround.remove(g['name']);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _slotsSelectionStep() {
    return Column(
      children: selectedGrounds.map((g) {
        String gName = g['name'];
        String category = g['category'];
        List<String> available = getSlots(category);
        List<String> picked = selectedSlotsPerGround[gName] ?? [];
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          elevation: 3,
          child: ExpansionTile(
            title: Text(
              gName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              "Selected: ${picked.length} slot(s) • ${category}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            children: available.map((slot) {
              bool checked = picked.contains(slot);
              bool isDisabled = false;
              
              // Handle cricket slot conflicts
              if (category == "Cricket") {
                if (slot == "Full-day") {
                  isDisabled = picked.contains("9am to 2pm") || picked.contains("2pm to 6pm");
                } else {
                  isDisabled = picked.contains("Full-day");
                }
              }
              
              return CheckboxListTile(
                dense: true,
                title: Text(
                  slot,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 13,
                  ),
                ),
                subtitle: category == "Cricket" && isDisabled 
                    ? Text(
                        slot == "Full-day" 
                            ? "Cannot select with individual slots" 
                            : "Cannot select with full-day",
                        style: const TextStyle(color: Colors.red, fontSize: 11),
                      )
                    : null,
                value: checked,
                activeColor: const Color(0xFF1A659E),
                onChanged: isDisabled ? null : (v) {
                  setState(() {
                    if (v == true) {
                      // For cricket, clear conflicting slots
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
                              onPressed: details.onStepContinue,
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
                              child: Text(
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
                                value: selectedSport,
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
                                value: selectedTeam,
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
                                value: selectedFormat,
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
                                    leading: Radio<String>(
                                      value: "JazzCash",
                                      groupValue: selectedPayment,
                                      onChanged: (v) => setState(() => selectedPayment = v),
                                      activeColor: const Color(0xFF00D9FF),
                                    ),
                                    title: const Text("JazzCash", style: TextStyle(fontSize: 14)),
                                    subtitle: const Text("Mobile wallet payment", style: TextStyle(fontSize: 12)),
                                    onTap: () => setState(() => selectedPayment = "JazzCash"),
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    dense: true,
                                    leading: Radio<String>(
                                      value: "EasyPaisa",
                                      groupValue: selectedPayment,
                                      onChanged: (v) => setState(() => selectedPayment = v),
                                      activeColor: const Color(0xFF00D9FF),
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