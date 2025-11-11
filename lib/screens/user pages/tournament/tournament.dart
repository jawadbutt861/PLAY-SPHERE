import 'package:flutter/material.dart';
import '../user home/favourite/global_data.dart';
import '../../../main.dart';

class Tournament extends StatefulWidget {
  const Tournament({super.key});

  @override
  State<Tournament> createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {
  List<Map<String, dynamic>> tournaments = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: tournaments.isEmpty ? _buildEmptyState(context) : _buildTournamentList(context),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 100), // Add margin to avoid bottom nav
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/TournamentForm');
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                tournaments.add(result);
              });
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "No Tournaments Yet",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Create your first tournament to get started\nand compete with other players",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientButton(
                text: "Create Tournament",
                icon: Icons.add_rounded,
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/TournamentForm');
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      tournaments.add(result);
                    });
                  }
                },
                width: double.infinity,
                height: 56,
              ),
            ),
            const SizedBox(height: 120), // Add bottom padding to avoid bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Add bottom padding to avoid bottom nav
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return ModernCard(
          margin: const EdgeInsets.only(bottom: 16),
          onTap: () => _showTournamentDetails(tournament),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: _getSportGradient(tournament['sport']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSportIcon(tournament['sport']),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament['name'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${tournament['sport']} • ${tournament['format']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.groups_rounded, "${tournament['teams']} Teams", colorScheme),
                  _buildInfoChip(Icons.calendar_today_rounded, "${tournament['startDate']} - ${tournament['endDate']}", colorScheme),
                  _buildInfoChip(Icons.sports_rounded, "${tournament['bookedGrounds']?.length ?? 0} Grounds", colorScheme),
                  _buildInfoChip(Icons.schedule_rounded, "${tournament['matches']?.length ?? tournament['fixtures']?.length ?? 0} Matches", colorScheme),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16, 
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getSportGradient(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]);
      case 'football':
        return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
      case 'tennis':
        return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
      case 'basketball':
        return const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFE64A19)]);
      case 'hockey':
        return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)]);
      case 'volleyball':
        return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]);
      default:
        return AppTheme.primaryGradient;
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'tennis':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'hockey':
        return Icons.sports_hockey;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.emoji_events;
    }
  }

  void _showTournamentDetails(Map<String, dynamic> tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsPage(tournament: tournament),
      ),
    );
  }
}

// Tournament Details Page with tabs
class TournamentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> tournament;
  
  const TournamentDetailsPage({super.key, required this.tournament});

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: AppBar(
            title: Text(
              widget.tournament['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline_rounded), text: "Info"),
                Tab(icon: Icon(Icons.sports_rounded), text: "Matches"),
                Tab(icon: Icon(Icons.leaderboard_rounded), text: "Points"),
                Tab(icon: Icon(Icons.schedule_rounded), text: "Schedule"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildMatchesTab(),
          _buildPointsTab(),
          _buildScheduleTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTournamentHeader(),
          const SizedBox(height: 24),
          _buildTournamentInfo(),
          const SizedBox(height: 24),
          _buildGroundBookings(),
        ],
      ),
    );
  }

  Widget _buildTournamentHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A659E), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSportIcon(widget.tournament['sport']),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tournament['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${widget.tournament['sport']} Tournament",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tournament Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDetailRow("Format", widget.tournament['format']),
        _buildDetailRow("Teams", "${widget.tournament['teams']}"),
        _buildDetailRow("Start Date", widget.tournament['startDate']),
        _buildDetailRow("End Date", widget.tournament['endDate']),
        _buildDetailRow("Actual End", widget.tournament['actualEndDate'] ?? widget.tournament['endDate']),
        _buildDetailRow("Grounds Booked", "${widget.tournament['bookedGrounds']?.length ?? 0}"),
        _buildDetailRow("Total Matches", "${widget.tournament['matches']?.length ?? widget.tournament['fixtures']?.length ?? 0}"),
        _buildDetailRow("Status", widget.tournament['status'] ?? 'Active'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroundBookings() {
    final bookings = widget.tournament['bookedGrounds'] as List<Map<String, dynamic>>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ground Bookings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          const Text("No ground bookings")
        else
          ...bookings.map((booking) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.sports, color: Color(0xFF1A659E)),
                title: Text(booking['ground']['name']),
                subtitle: Text("${booking['date']} • ${booking['slot']}"),
                trailing: Text(
                  booking['payment'],
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMatchesTab() {
    String tournamentId = widget.tournament['id'];
    List<Map<String, dynamic>> matches = GlobalData.tournamentMatches[tournamentId] ?? [];
    
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          "No matches scheduled yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> match = matches[index];
        return _buildMatchCard(match, index);
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, int index) {
    String team1 = match['team1'] ?? '';
    String team2 = match['team2'] ?? '';
    String status = match['status'] ?? 'scheduled';
    String result = match['result'] ?? '';
    String winner = match['winner'] ?? '';
    String matchType = match['matchType'] ?? 'regular';
    
    Color cardColor = Colors.white;
    Color statusColor = Colors.orange;
    String statusText = 'Scheduled';
    
    if (status == 'completed') {
      cardColor = Colors.green.shade50;
      statusColor = Colors.green;
      if (result == 'abandoned') {
        statusText = 'Abandoned';
        statusColor = Colors.grey;
      } else {
        statusText = 'Completed';
      }
    } else if (status == 'in_progress') {
      cardColor = Colors.blue.shade50;
      statusColor = Colors.blue;
      statusText = 'In Progress';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMatchTypeColor(matchType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMatchTypeLabel(matchType),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        team1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: winner == team1 ? Colors.green : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (winner == team1)
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "VS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        team2,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: winner == team2 ? Colors.green : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (winner == team2)
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  match['ground'] ?? 'TBD',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "${match['date'] ?? 'TBD'} • ${match['time'] ?? 'TBD'}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            if (status == 'scheduled' && team1 != 'BYE' && team2 != 'BYE') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showResultDialog(index, team1, team2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A659E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Update Result"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMatchTypeColor(String matchType) {
    switch (matchType) {
      case 'grand_final':
        return Colors.purple;
      case 'final':
        return Colors.red;
      case 'semi_final':
        return Colors.orange;
      default:
        return const Color(0xFF1A659E);
    }
  }

  String _getMatchTypeLabel(String matchType) {
    switch (matchType) {
      case 'grand_final':
        return 'GRAND FINAL';
      case 'final':
        return 'FINAL';
      case 'semi_final':
        return 'SEMI FINAL';
      default:
        return 'MATCH';
    }
  }

  void _showResultDialog(int matchIndex, String team1, String team2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Match Result: $team1 vs $team2"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.green),
                title: Text("$team1 Wins"),
                onTap: () {
                  _updateMatchResult(matchIndex, 'win', team1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.green),
                title: Text("$team2 Wins"),
                onTap: () {
                  _updateMatchResult(matchIndex, 'win', team2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text("Match Abandoned"),
                onTap: () {
                  _updateMatchResult(matchIndex, 'abandoned', null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _updateMatchResult(int matchIndex, String result, String? winner) {
    String tournamentId = widget.tournament['id'];
    GlobalData.updateMatchResult(tournamentId, matchIndex, result, winnerTeam: winner);
    setState(() {}); // Refresh the UI
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == 'abandoned' 
              ? "Match marked as abandoned. Each team gets 1 point."
              : "$winner wins! 2 points awarded.",
        ),
      ),
    );
  }

  Widget _buildPointsTab() {
    String tournamentId = widget.tournament['id'];
    List<Map<String, dynamic>> pointsTable = GlobalData.getPointsTable(tournamentId);
    
    if (pointsTable.isEmpty) {
      return const Center(
        child: Text(
          "No points data available yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Points Table",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A659E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40, child: Text("Pos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Team", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      SizedBox(width: 50, child: Text("P", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 50, child: Text("W", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 50, child: Text("L", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 50, child: Text("A", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 60, child: Text("Pts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...pointsTable.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> team = entry.value;
                  
                  Color rowColor = index == 0 ? Colors.amber.shade50 : Colors.white;
                  if (index == 0) {
                    // Champion styling
                  } else if (index < 3) {
                    rowColor = Colors.green.shade50;
                  }
                  
                  return Container(
                    color: rowColor,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Row(
                            children: [
                              Text(
                                "${index + 1}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (index == 0) const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            team['team'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: 50, child: Text("${team['played']}", textAlign: TextAlign.center)),
                        SizedBox(width: 50, child: Text("${team['won']}", textAlign: TextAlign.center)),
                        SizedBox(width: 50, child: Text("${team['lost']}", textAlign: TextAlign.center)),
                        SizedBox(width: 50, child: Text("${team['abandoned']}", textAlign: TextAlign.center)),
                        SizedBox(
                          width: 60,
                          child: Text(
                            "${team['points']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A659E)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Scoring System",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("• Win: 2 points"),
                  const Text("• Loss: 0 points"),
                  const Text("• Abandoned: 1 point each team"),
                  const SizedBox(height: 8),
                  const Text(
                    "Legend: P=Played, W=Won, L=Lost, A=Abandoned, Pts=Points",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    String tournamentId = widget.tournament['id'];
    List<Map<String, dynamic>> matches = GlobalData.tournamentMatches[tournamentId] ?? [];
    
    // Group matches by date
    Map<String, List<Map<String, dynamic>>> matchesByDate = {};
    for (var match in matches) {
      String date = match['date'] ?? 'TBD';
      matchesByDate.putIfAbsent(date, () => []);
      matchesByDate[date]!.add(match);
    }
    
    if (matchesByDate.isEmpty) {
      return const Center(
        child: Text(
          "No schedule available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchesByDate.length,
      itemBuilder: (context, index) {
        String date = matchesByDate.keys.elementAt(index);
        List<Map<String, dynamic>> dayMatches = matchesByDate[date]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A659E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(
                  date == 'TBD' ? 'To Be Determined' : date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...dayMatches.map((match) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getMatchTypeColor(match['matchType'] ?? 'regular'),
                    child: Text(
                      "${match['id']}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text("${match['team1']} vs ${match['team2']}"),
                  subtitle: Text("${match['time'] ?? 'TBD'} • ${match['ground'] ?? 'TBD'}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMatchTypeColor(match['matchType'] ?? 'regular').withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getMatchTypeLabel(match['matchType'] ?? 'regular'),
                      style: TextStyle(
                        color: _getMatchTypeColor(match['matchType'] ?? 'regular'),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'tennis':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'hockey':
        return Icons.sports_hockey;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.emoji_events;
    }
  }
}