import 'package:flutter/material.dart';

class TournamentSummaryPage extends StatelessWidget {
  final String name;
  final String sport;
  final String format;
  final String startDate;
  final String endDate;
  final List<Map<String, dynamic>> bookedGrounds;
  final List<List<String>> fixtures;

  const TournamentSummaryPage({
    super.key,
    required this.name,
    required this.sport,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.bookedGrounds,
    required this.fixtures,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text("Tournament Summary"),
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSectionTitle("Booked Grounds & Slots"),
            const SizedBox(height: 8),
            _buildBookedList(),
            const SizedBox(height: 16),
            _buildSectionTitle("Fixtures"),
            const SizedBox(height: 8),
            _buildFixtureList(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  "Finish",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
          const SizedBox(height: 6),
          Text("Sport: $sport", style: const TextStyle(fontSize: 16)),
          Text("Format: $format", style: const TextStyle(fontSize: 16)),
          Text("Dates: $startDate ➜ $endDate", style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40)));
  }

  Widget _buildBookedList() {
    if (bookedGrounds.isEmpty) return const Text("No bookings found.");
    return Column(
      children: bookedGrounds.map((b) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.sports, color: Color(0xFF26A69A)),
            title: Text(b['ground']['name']),
            subtitle: Text("${b['date']} • ${b['slot']}"),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFixtureList() {
    if (fixtures.isEmpty) return const Text("No fixtures generated.");
    return Column(
      children: fixtures.asMap().entries.map((entry) {
        int idx = entry.key + 1;
        var f = entry.value;
        return Card(
          color: Colors.white,
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF26A69A),
              child: Text(idx.toString(), style: const TextStyle(color: Colors.white)),
            ),
            title: f.length == 2
                ? Text("${f[0]}  vs  ${f[1]}", style: const TextStyle(fontWeight: FontWeight.w600))
                : Text("${f[0]} (Bye)", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
        );
      }).toList(),
    );
  }
}
