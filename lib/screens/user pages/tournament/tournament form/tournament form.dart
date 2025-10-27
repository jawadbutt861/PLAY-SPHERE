// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

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

  // Dropdown selected value
  String? selectedSport;
  String? selectedTeam;
  String? selectedFormat;

  // Picked Dates
  DateTime? pickedStartDate;
  DateTime? pickedEndDate;

  // List of sports
  final List<String> sports = [
    'Cricket',
    'Football',
    'Hockey',
    'Volleyball',
    'Tennis',
    'Basketball',
  ];
  // List of teams
  final List<String> teams = [
    '6',
    '8',
    '10',
    '12',
    '14',
    '16',
  ];

  // List of teams
  final List<String> format = [
    'Single Elimination',
    'Double Elimination',
    'Round Robin',
    
  ];







  // Function to pick a date
  Future<void> _pickDate({
    required BuildContext context,
    required bool isStart,
  }) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? pickedStartDate ?? DateTime.now()
          : pickedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(selectedDate);
        if (isStart) {
          pickedStartDate = selectedDate;
          startDateController.text = formatted;
        } else {
          pickedEndDate = selectedDate;
          endDateController.text = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Create Tournament",
                    style: TextStyle(
                      color: Color(0xFF4E342E),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Tournament Name
                _buildLabel("Tournament Name"),
                _buildTextField(
                  controller: name,
                  hintText: "e.g. Summer Soccer Clash",
                  validator: (value) => value!.isEmpty
                      ? "Please enter tournament name"
                      : null,
                ),

                const SizedBox(height: 20),

                // Sport (Dropdown)
                _buildLabel("Sport"),
                DropdownButtonFormField<String>(
                  value: selectedSport,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: _borderStyle(),
                    focusedBorder: _borderStyle(),
                    errorBorder: _borderStyle(color: Colors.redAccent),
                    focusedErrorBorder: _borderStyle(color: Colors.redAccent),
                  ),
                  hint: const Text("Select a sport"),
                  items: sports
                      .map((sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(sport),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSport = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select a sport" : null,
                ),

                const SizedBox(height: 20),

                
                // Team (Dropdown)
                _buildLabel("Team"),
                DropdownButtonFormField<String>(
                  value: selectedTeam,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: _borderStyle(),
                    focusedBorder: _borderStyle(),
                    errorBorder: _borderStyle(color: Colors.redAccent),
                    focusedErrorBorder: _borderStyle(color: Colors.redAccent),
                  ),
                  hint: const Text("Select no of Teams"),
                  items: teams
                      .map((team) => DropdownMenuItem(
                            value: team,
                            child: Text(team),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTeam = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select no of teams" : null,
                ),


                const SizedBox(height: 20),

                
                // Team (Dropdown)
                _buildLabel("Format"),
                DropdownButtonFormField<String>(
                  value: selectedFormat,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: _borderStyle(),
                    focusedBorder: _borderStyle(),
                    errorBorder: _borderStyle(color: Colors.redAccent),
                    focusedErrorBorder: _borderStyle(color: Colors.redAccent),
                  ),
                  hint: const Text("Select Format"),
                  items: format
                      .map((format) => DropdownMenuItem(
                            value: format,
                            child: Text(format),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFormat = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select format" : null,
                ),




              

                const SizedBox(height: 20),

                // Start Date
                _buildLabel("Start Date"),
                _buildDateField(
                  controller: startDateController,
                  onTap: () => _pickDate(context: context, isStart: true),
                ),

                const SizedBox(height: 20),

                // End Date
                _buildLabel("End Date"),
                _buildDateField(
                  controller: endDateController,
                  onTap: () => _pickDate(context: context, isStart: false),
                ),

                const SizedBox(height: 40),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        debugPrint("Tournament Name: ${name.text}");
                        debugPrint("Sport: $selectedSport");
                        debugPrint("Start Date: ${startDateController.text}");
                        debugPrint("End Date: ${endDateController.text}");
                        
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      minimumSize: const Size(220, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Create Tournament",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 Helper Widgets
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(),
        errorBorder: _borderStyle(color: Colors.redAccent),
        focusedErrorBorder: _borderStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: "Select Date",
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        suffixIcon: const Icon(Icons.calendar_month_rounded,
            color: Color(0xFF757575)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(),
        errorBorder: _borderStyle(color: Colors.redAccent),
        focusedErrorBorder: _borderStyle(color: Colors.redAccent),
      ),
      validator: (value) => value!.isEmpty ? "Please select date" : null,
    );
  }

  OutlineInputBorder _borderStyle({Color color = const Color(0xFF26A69A)}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 2),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
