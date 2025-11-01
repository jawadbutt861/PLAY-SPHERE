// ignore_for_file: unused_local_variable, prefer_final_locals

import 'package:f_y_p/screens/user%20pages/tournament/tournament%20form/tournament%20summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
 // ✅ import summary page

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

  // Grounds
  List<Map<String, dynamic>> sportsGrounds = [
    {'image': 'assets/images/c1.jpeg', 'category': "Cricket", 'name': "Buitems Cricket Ground"},
    {'image': 'assets/images/c1.jpeg', 'category': "Cricket", 'name': "Shola Cricket Ground"},
    {'image': 'assets/images/c1.jpeg', 'category': "Cricket", 'name': "Haideri Cricket Ground"},
    {'image': 'assets/images/f1.jpg', 'category': "Football", 'name': "Buitems Football Ground"},
    {'image': 'assets/images/f1.jpg', 'category': "Football", 'name': "Shahbaz Football Ground"},
    {'image': 'assets/images/t1.jpeg', 'category': "Tennis", 'name': "Buitems Tennis Court"},
    {'image': 'assets/images/b1.webp', 'category': "Basketball", 'name': "Buitems Basketball Court"},
    {'image': 'assets/images/h1.webp', 'category': "Hockey", 'name': "Ayub Hockey Ground"},
    {'image': 'assets/images/v1.jpg', 'category': "Volleyball", 'name': "Buitems Volleyball Court"},
  ];

  // Slot generator
  List<String> getSlots(String category) {
    if (category == "Cricket") {
      return ["9am to 2pm", "2pm to 6pm", "Full-day"];
    } else {
      List<String> slots = [];
      for (int i = 9; i < 24; i++) {
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
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? pickedStartDate ?? DateTime.now() : pickedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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

  // Fixture generator
  void _createFixtures() {
    List<String> teamNames = teamControllers.map((c) => c.text.trim()).toList();
    fixtures.clear();

    if (selectedFormat == 'Single Elimination' || selectedFormat == 'Double Elimination') {
      teamNames.shuffle();
      for (int i = 0; i < teamNames.length; i += 2) {
        if (i + 1 < teamNames.length) {
          fixtures.add([teamNames[i], teamNames[i + 1]]);
        } else {
          fixtures.add([teamNames[i]]);
        }
      }
    } else if (selectedFormat == 'Round Robin') {
      List<String> teamsRR = List.from(teamNames);
      if (teamsRR.length.isOdd) teamsRR.add('BYE');
      int n = teamsRR.length, rounds = n - 1, half = n ~/ 2;
      List<String> arr = List.from(teamsRR);
      for (int r = 0; r < rounds; r++) {
        for (int i = 0; i < half; i++) {
          String t1 = arr[i];
          String t2 = arr[n - 1 - i];
          if (t1 != 'BYE' && t2 != 'BYE') fixtures.add([t1, t2]);
          else if (t1 != 'BYE' && t2 == 'BYE') fixtures.add([t1]);
        }
        List<String> newArr = [arr[0]];
        newArr.addAll(arr.sublist(n - 1));
        newArr.addAll(arr.sublist(1, n - 1));
        arr = newArr;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment successful via $selectedPayment")));
      _createFixtures();

      // ✅ Navigate to summary page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TournamentSummaryPage(
            name: name.text,
            sport: selectedSport ?? '',
            format: selectedFormat ?? '',
            startDate: startDateController.text,
            endDate: endDateController.text,
            bookedGrounds: bookedGrounds,
            fixtures: fixtures,
          ),
        ),
      );
    }
  }

  void _prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  // === UI helpers ===
  OutlineInputBorder _borderStyle({Color color = const Color(0xFF1A659E)}) {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 2));
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _buildTextField({required TextEditingController controller, required String hintText, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({required TextEditingController controller, required VoidCallback onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: "Select Date",
        suffixIcon: const Icon(Icons.calendar_month, color: Color(0xFF757575)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(),
      ),
      validator: (value) => value!.isEmpty ? "Please select date" : null,
    );
  }

  Widget _groundsSelectionStep() {
    List<Map<String, dynamic>> filtered = sportsGrounds.where((g) => g['category'] == selectedSport).toList();
    return Column(
      children: filtered.map((g) {
        bool selected = selectedGrounds.any((sg) => sg['name'] == g['name']);
        return CheckboxListTile(
          title: Text(g['name']),
          value: selected,
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
        );
      }).toList(),
    );
  }

  Widget _slotsSelectionStep() {
    return Column(
      children: selectedGrounds.map((g) {
        String gName = g['name'];
        List<String> available = getSlots(g['category']);
        List<String> picked = selectedSlotsPerGround[gName] ?? [];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: available.map((slot) {
              bool checked = picked.contains(slot);
              return CheckboxListTile(
                title: Text(slot),
                value: checked,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      picked.add(slot);
                    } else {
                      picked.remove(slot);
                    }
                    selectedSlotsPerGround[gName] = picked;
                    bookedGrounds.add({'ground': g, 'date': startDateController.text, 'slot': slot});
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
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(title: const Text("Create Tournament"), backgroundColor: const Color(0xFF1A659E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stepper(
              currentStep: currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _prevStep,
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7043)),
                      child: Text(currentStep == 4 ? "Finish" : "Next"),
                    ),
                    const SizedBox(width: 10),
                    if (currentStep > 0)
                      OutlinedButton(onPressed: details.onStepCancel, child: const Text("Back")),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text("Details"),
                  isActive: currentStep >= 0,
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildLabel("Tournament Name"),
                        _buildTextField(
                            controller: name,
                            hintText: "e.g. Summer Soccer Clash",
                            validator: (v) => v!.isEmpty ? "Required" : null),
                        const SizedBox(height: 12),
                        _buildLabel("Sport"),
                        DropdownButtonFormField<String>(
                          value: selectedSport,
                          decoration: InputDecoration(filled: true, fillColor: Colors.white, enabledBorder: _borderStyle()),
                          hint: const Text("Select a sport"),
                          items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() {
                            selectedSport = v;
                            selectedGrounds.clear();
                          }),
                        ),
                        const SizedBox(height: 12),
                        _buildLabel("Teams"),
                        DropdownButtonFormField<String>(
                          value: selectedTeam,
                          decoration: InputDecoration(filled: true, fillColor: Colors.white, enabledBorder: _borderStyle()),
                          hint: const Text("Select teams count"),
                          items: teams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => selectedTeam = v),
                        ),
                        const SizedBox(height: 12),
                        _buildLabel("Format"),
                        DropdownButtonFormField<String>(
                          value: selectedFormat,
                          decoration: InputDecoration(filled: true, fillColor: Colors.white, enabledBorder: _borderStyle()),
                          hint: const Text("Select format"),
                          items: format.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                          onChanged: (v) => setState(() => selectedFormat = v),
                        ),
                        const SizedBox(height: 12),
                        _buildLabel("Start Date"),
                        _buildDateField(controller: startDateController, onTap: () => _pickDate(context: context, isStart: true)),
                        const SizedBox(height: 12),
                        _buildLabel("End Date"),
                        _buildDateField(controller: endDateController, onTap: () => _pickDate(context: context, isStart: false)),
                      ],
                    ),
                  ),
                ),
                Step(title: const Text("Teams"), isActive: currentStep >= 1, content: Column(children: [
                  ...teamControllers.asMap().entries.map((e) {
                    int idx = e.key + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(labelText: "Team $idx", filled: true, fillColor: Colors.white, enabledBorder: _borderStyle()),
                      ),
                    );
                  }),
                ])),
                Step(title: const Text("Grounds"), isActive: currentStep >= 2, content: _groundsSelectionStep()),
                Step(title: const Text("Slots"), isActive: currentStep >= 3, content: _slotsSelectionStep()),
                Step(
                  title: const Text("Payment"),
                  isActive: currentStep >= 4,
                  content: Column(
                    children: [
                      const Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
                      RadioListTile<String>(
                        title: const Text("JazzCash"),
                        value: "JazzCash",
                        groupValue: selectedPayment,
                        onChanged: (v) => setState(() => selectedPayment = v),
                      ),
                      RadioListTile<String>(
                        title: const Text("EasyPaisa"),
                        value: "EasyPaisa",
                        groupValue: selectedPayment,
                        onChanged: (v) => setState(() => selectedPayment = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
