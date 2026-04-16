import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user home/favourite/global_data.dart';
import '../../../main.dart';
import '../../../services/tournament_service.dart';

class Tournament extends StatefulWidget {
  const Tournament({super.key});

  @override
  State<Tournament> createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {
  List<Map<String, dynamic>> tournaments = [];
  StreamSubscription? _sub;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = TournamentService.getUserTournaments(_uid).listen((list) {
        if (mounted) {
          setState(() {
            tournaments = list;
            GlobalData.tournaments = list;
            for (final t in list) {
              // Firestore document ID use karo (id field)
              final id = t['id'] as String? ?? '';
              final teamNames = (t['teamNames'] as List?)?.cast<String>() ?? [];
              final matches = (t['matches'] as List?)
                      ?.map((m) => Map<String, dynamic>.from(m as Map))
                      .toList() ??
                  [];
              if (id.isNotEmpty) {
                // Hamesha update karo taake fresh data rahe
                GlobalData.initializeTournament(id, teamNames, matches);
              }
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

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
                height: 65,
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
                      gradient: _getSportGradient(tournament['sport'] ?? ''),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSportIcon(tournament['sport'] ?? ''),
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
                          tournament['name'] ?? 'Tournament',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${tournament['sport'] ?? ''} • ${tournament['format'] ?? ''}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () => _confirmDelete(tournament),
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
                  _buildInfoChip(Icons.groups_rounded, "${tournament['teams'] ?? 0} Teams", colorScheme),
                  _buildInfoChip(Icons.calendar_today_rounded, "${tournament['startDate'] ?? ''} - ${tournament['endDate'] ?? ''}", colorScheme),
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

  Future<void> _confirmDelete(Map<String, dynamic> tournament) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.delete_outline_rounded, color: Colors.red),
          SizedBox(width: 10),
          Text('Delete Tournament'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "${tournament['name'] ?? 'Tournament'}"?'),
            const SizedBox(height: 8),
            const Text(
              'All ground bookings for this tournament will be cancelled.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final id = tournament['id'] as String? ?? '';
    if (id.isEmpty) return;
    try {
      await TournamentService.deleteTournament(id, _uid ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tournament deleted and bookings cancelled'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to delete tournament'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
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
              widget.tournament['name'] ?? 'Tournament',
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
              _getSportIcon(widget.tournament['sport'] ?? ''),
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
                  widget.tournament['name'] ?? 'Tournament',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${widget.tournament['sport'] ?? ''} Tournament",
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
        _buildDetailRow("Format", widget.tournament['format'] ?? ''),
        _buildDetailRow("Teams", "${widget.tournament['teams'] ?? 0}"),
        _buildDetailRow("Start Date", widget.tournament['startDate'] ?? ''),
        _buildDetailRow("End Date", widget.tournament['endDate'] ?? ''),
        _buildDetailRow("Actual End", widget.tournament['actualEndDate'] ?? widget.tournament['endDate'] ?? ''),
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
    final rawBookings = widget.tournament['bookedGrounds'];
    final bookings = (rawBookings as List?)
            ?.map((b) => Map<String, dynamic>.from(b as Map))
            .toList() ??
        [];
    
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
            // Firestore mein ground flat fields hain (groundName, groundId etc.)
            final groundName = booking['groundName'] as String? ??
                (booking['ground'] as Map?)?['name'] as String? ?? '';
            final date = booking['date'] as String? ?? '';
            final slot = booking['slot'] as String? ?? '';
            final payment = booking['payment'] as String? ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.sports, color: Color(0xFF1A659E)),
                title: Text(groundName),
                subtitle: Text("$date • $slot"),
                trailing: Text(
                  payment,
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
    final tournamentId = widget.tournament['id'] as String? ?? '';
    // GlobalData mein nahi mila to Firestore data se lo
    List<Map<String, dynamic>> matches = GlobalData.tournamentMatches[tournamentId] ?? [];
    if (matches.isEmpty) {
      matches = (widget.tournament['matches'] as List?)
              ?.map((m) => Map<String, dynamic>.from(m as Map))
              .toList() ??
          [];
    }
    
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
    final tournamentId = widget.tournament['id'] as String? ?? '';
    final allMatches = GlobalData.tournamentMatches[tournamentId] ??
        (widget.tournament['matches'] as List?)
            ?.map((m) => Map<String, dynamic>.from(m as Map))
            .toList() ?? [];

    String team1 = _resolveTeamName(match['team1'] ?? '', allMatches);
    String team2 = _resolveTeamName(match['team2'] ?? '', allMatches);
    String status = match['status'] ?? 'scheduled';
    String result = match['result'] ?? '';
    String winner = match['winner'] ?? '';
    String matchType = match['matchType'] ?? 'regular';
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color cardColor;
    Color statusColor;
    String statusText;
    
    if (status == 'completed') {
      cardColor = Colors.green.withValues(alpha: 0.1);
      statusColor = Colors.green;
      if (result == 'abandoned') {
        statusText = 'Abandoned';
        statusColor = Colors.grey;
        cardColor = colorScheme.surfaceContainerHighest;
      } else {
        statusText = 'Completed';
      }
    } else if (status == 'in_progress') {
      cardColor = Colors.blue.withValues(alpha: 0.1);
      statusColor = Colors.blue;
      statusText = 'In Progress';
    } else {
      cardColor = colorScheme.surface;
      statusColor = Colors.orange;
      statusText = 'Scheduled';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: winner == team1 ? Colors.green : colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (winner == team1)
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "VS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        team2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: winner == team2 ? Colors.green : colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (winner == team2)
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        match['ground']?.toString().isNotEmpty == true
                            ? match['ground'] as String
                            : 'Venue TBD',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "${match['date'] ?? 'TBD'} • ${match['time'] ?? 'TBD'}",
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (status == 'scheduled' && team1 != 'BYE' && team2 != 'BYE') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showResultDialog(index, team1, team2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text("Update Result", style: TextStyle(fontSize: 13)),
                ),
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
    final team1ScoreController = TextEditingController();
    final team2ScoreController = TextEditingController();
    String? selectedResult;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Match Result",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "$team1 vs $team2",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Enter Scores (Optional)",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(team1, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: team1ScoreController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "0",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                          child: Text("-", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(team2, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: team2ScoreController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "0",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Select Result",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setDialogState(() => selectedResult = 'team1');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: selectedResult == 'team1' ? Colors.green.withValues(alpha: 0.1) : null,
                          border: Border.all(
                            color: selectedResult == 'team1' ? Colors.green : Colors.grey,
                            width: selectedResult == 'team1' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events, 
                              color: selectedResult == 'team1' ? Colors.green : Colors.grey, 
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "$team1 Wins",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedResult == 'team1' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setDialogState(() => selectedResult = 'team2');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: selectedResult == 'team2' ? Colors.green.withValues(alpha: 0.1) : null,
                          border: Border.all(
                            color: selectedResult == 'team2' ? Colors.green : Colors.grey,
                            width: selectedResult == 'team2' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events, 
                              color: selectedResult == 'team2' ? Colors.green : Colors.grey, 
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "$team2 Wins",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedResult == 'team2' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setDialogState(() => selectedResult = 'draw');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: selectedResult == 'draw' ? Colors.blue.withValues(alpha: 0.1) : null,
                          border: Border.all(
                            color: selectedResult == 'draw' ? Colors.blue : Colors.grey,
                            width: selectedResult == 'draw' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.handshake, 
                              color: selectedResult == 'draw' ? Colors.blue : Colors.grey, 
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Draw",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedResult == 'draw' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setDialogState(() => selectedResult = 'abandoned');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: selectedResult == 'abandoned' ? Colors.grey.withValues(alpha: 0.1) : null,
                          border: Border.all(
                            color: selectedResult == 'abandoned' ? Colors.grey : Colors.grey.shade400,
                            width: selectedResult == 'abandoned' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel, 
                              color: selectedResult == 'abandoned' ? Colors.grey : Colors.grey.shade400, 
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Match Abandoned",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedResult == 'abandoned' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selectedResult == null ? null : () {
                    int? team1Score = team1ScoreController.text.isNotEmpty 
                        ? int.tryParse(team1ScoreController.text) 
                        : null;
                    int? team2Score = team2ScoreController.text.isNotEmpty 
                        ? int.tryParse(team2ScoreController.text) 
                        : null;
                    
                    String? winner;
                    String result = selectedResult!;
                    
                    if (result == 'team1') {
                      winner = team1;
                      result = 'win';
                    } else if (result == 'team2') {
                      winner = team2;
                      result = 'win';
                    }
                    
                    _updateMatchResult(matchIndex, result, winner, team1Score, team2Score);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// "Winner of X vs Y" / "Loser N" ko actual team name mein resolve karo
  String _resolveTeamName(String name, List<Map<String, dynamic>> allMatches) {
    if (name.startsWith('Winner of ')) {
      final vs = name.replaceFirst('Winner of ', '');
      final parts = vs.split(' vs ');
      if (parts.length == 2) {
        final match = allMatches.firstWhere(
          (m) => m['team1'] == parts[0].trim() && m['team2'] == parts[1].trim(),
          orElse: () => {},
        );
        if (match.isNotEmpty && match['winner'] != null) {
          return match['winner'] as String;
        }
      }
      return name; // still pending
    }
    if (name.startsWith('Loser ')) {
      final idx = int.tryParse(name.replaceFirst('Loser ', ''));
      if (idx != null && idx <= allMatches.length) {
        final match = allMatches[idx - 1];
        if (match['winner'] != null && match['status'] == 'completed') {
          final t1 = match['team1'] as String? ?? '';
          final t2 = match['team2'] as String? ?? '';
          final w = match['winner'] as String? ?? '';
          return w == t1 ? t2 : t1;
        }
      }
      return name;
    }
    return name;
  }

  void _updateMatchResult(int matchIndex, String result, String? winner, int? team1Score, int? team2Score) {
    final tournamentId = widget.tournament['id'] as String? ?? '';
    GlobalData.updateMatchResult(
      tournamentId,
      matchIndex,
      result,
      winnerTeam: winner,
      team1Score: team1Score,
      team2Score: team2Score,
    );
    setState(() {});

    // Firestore mein updated matches save karo
    final updatedMatches = GlobalData.tournamentMatches[tournamentId] ?? [];
    TournamentService.updateTournament(tournamentId, {'matches': updatedMatches});

    String message;
    if (result == 'abandoned') {
      message = "Match marked as abandoned. Each team gets 1 point.";
    } else if (result == 'draw') {
      message = "Match ended in a draw. Each team gets 1 point.";
    } else {
      message = "$winner wins! 3 points awarded.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result == 'abandoned' ? Colors.grey : AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPointsTab() {
    final tournamentId = widget.tournament['id'] as String? ?? '';
    // Ensure GlobalData has latest matches
    if (GlobalData.tournamentMatches[tournamentId] == null) {
      final matches = (widget.tournament['matches'] as List?)
              ?.map((m) => Map<String, dynamic>.from(m as Map))
              .toList() ??
          [];
      final teamNames = (widget.tournament['teamNames'] as List?)
              ?.cast<String>() ??
          [];
      GlobalData.initializeTournament(tournamentId, teamNames, matches);
    }
    List<Map<String, dynamic>> pointsTable = GlobalData.getPointsTable(tournamentId);
    Map<String, dynamic> stats = GlobalData.getTournamentStats(tournamentId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (pointsTable.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.leaderboard_rounded, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                "No points data available yet",
                style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                "Complete matches to see standings",
                style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Progress Card
          Card(
            elevation: 2,
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "Tournament Progress",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Total", "${stats['total'] ?? 0}", Icons.sports, colorScheme),
                      _buildStatItem("Completed", "${stats['completed'] ?? 0}", Icons.check_circle, colorScheme),
                      _buildStatItem("Remaining", "${stats['scheduled'] ?? 0}", Icons.schedule, colorScheme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (stats['completed'] ?? 0) / (stats['total'] ?? 1),
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${stats['completionPercentage'] ?? '0.0'}% Complete",
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Standings",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Card(
              elevation: 4,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 40, child: Text("Pos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                        SizedBox(width: 120, child: Text("Team", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                        SizedBox(width: 35, child: Text("P", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 35, child: Text("W", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 35, child: Text("D", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 35, child: Text("L", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 40, child: Text("GF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 40, child: Text("GA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 40, child: Text("GD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                        SizedBox(width: 45, child: Text("Pts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  ...pointsTable.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> team = entry.value;
                    
                    Color rowColor;
                    if (index == 0) {
                      rowColor = Colors.amber.withValues(alpha: 0.15);
                    } else if (index < 3) {
                      rowColor = Colors.green.withValues(alpha: 0.1);
                    } else if (index >= pointsTable.length - 2) {
                      rowColor = Colors.red.withValues(alpha: 0.05);
                    } else {
                      rowColor = index.isEven ? colorScheme.surface : colorScheme.surfaceContainerHighest;
                    }
                    
                    return Container(
                      color: rowColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Row(
                              children: [
                                Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (index == 0) const Icon(Icons.emoji_events, color: Colors.amber, size: 14),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              team['team'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 35, child: Text("${team['played']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colorScheme.onSurface))),
                          SizedBox(width: 35, child: Text("${team['won']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600))),
                          SizedBox(width: 35, child: Text("${team['drawn']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600))),
                          SizedBox(width: 35, child: Text("${team['lost']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600))),
                          SizedBox(width: 40, child: Text("${team['goalsFor']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colorScheme.onSurface))),
                          SizedBox(width: 40, child: Text("${team['goalsAgainst']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colorScheme.onSurface))),
                          SizedBox(
                            width: 40, 
                            child: Text(
                              "${team['goalDifference'] > 0 ? '+' : ''}${team['goalDifference']}", 
                              textAlign: TextAlign.center, 
                              style: TextStyle(
                                fontSize: 12, 
                                color: team['goalDifference'] > 0 ? Colors.green : team['goalDifference'] < 0 ? Colors.red : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              )
                            )
                          ),
                          SizedBox(
                            width: 45,
                            child: Text(
                              "${team['points']}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: AppTheme.primaryColor, 
                                fontSize: 13
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Scoring System",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("• Win: 3 points", style: TextStyle(color: colorScheme.onSurface)),
                  Text("• Draw: 1 point each team", style: TextStyle(color: colorScheme.onSurface)),
                  Text("• Loss: 0 points", style: TextStyle(color: colorScheme.onSurface)),
                  Text("• Abandoned: 1 point each team", style: TextStyle(color: colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Text(
                    "Legend: P=Played, W=Won, D=Draw, L=Lost, GF=Goals For, GA=Goals Against, GD=Goal Difference, Pts=Points",
                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    final tournamentId = widget.tournament['id'] as String? ?? '';
    List<Map<String, dynamic>> matches = GlobalData.tournamentMatches[tournamentId] ?? [];
    if (matches.isEmpty) {
      matches = (widget.tournament['matches'] as List?)
              ?.map((m) => Map<String, dynamic>.from(m as Map))
              .toList() ??
          [];
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Group matches by date
    Map<String, List<Map<String, dynamic>>> matchesByDate = {};
    for (var match in matches) {
      String date = match['date'] ?? 'TBD';
      matchesByDate.putIfAbsent(date, () => []);
      matchesByDate[date]!.add(match);
    }
    
    if (matchesByDate.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                "No schedule available",
                style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // Sort dates
    List<String> sortedDates = matchesByDate.keys.toList();
    sortedDates.sort((a, b) {
      if (a == 'TBD') return 1;
      if (b == 'TBD') return -1;
      return a.compareTo(b);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String date = sortedDates[index];
        List<Map<String, dynamic>> dayMatches = matchesByDate[date]!;
        
        // Count match statuses for the day
        int completedCount = dayMatches.where((m) => m['status'] == 'completed').length;
        int totalCount = dayMatches.length;
        bool isToday = date == DateTime.now().toString().split(' ')[0];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isToday ? AppTheme.primaryGradient : null,
                  color: isToday ? null : const Color(0xFF1A659E),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                date == 'TBD' ? 'To Be Determined' : _formatDate(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "TODAY",
                                    style: TextStyle(
                                      color: Color(0xFF1A659E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$completedCount of $totalCount matches completed",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: totalCount > 0 ? completedCount / totalCount : 0,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
              ...dayMatches.asMap().entries.map((entry) {
                int matchIndex = entry.key;
                Map<String, dynamic> match = entry.value;
                bool isCompleted = match['status'] == 'completed';

                final t1 = _resolveTeamName(match['team1'] ?? '', matches);
                final t2 = _resolveTeamName(match['team2'] ?? '', matches);
                final groundName = (match['ground'] as String?)?.isNotEmpty == true
                    ? match['ground'] as String
                    : null;
                
                return InkWell(
                  onTap: isCompleted ? null : () {
                    int globalIndex = matches.indexOf(match);
                    if (globalIndex != -1 && t1 != 'BYE' && t2 != 'BYE') {
                      _showResultDialog(globalIndex, t1, t2);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green.withValues(alpha: 0.05) 
                          : matchIndex.isEven 
                              ? colorScheme.surface 
                              : colorScheme.surfaceContainerHighest,
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getMatchTypeColor(match['matchType'] ?? 'regular'),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "${match['id']}",
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 14
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$t1 vs $t2",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600, 
                                        fontSize: 13,
                                        color: colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCompleted && match['winner'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        match['result'] == 'draw' ? 'DRAW' : 'WIN',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 12, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    match['time'] ?? 'TBD',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant, 
                                      fontSize: 11
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.location_on, size: 12, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      groundName ?? 'Venue TBD',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant, 
                                        fontSize: 11
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (isCompleted && match['team1Score'] != null && match['team2Score'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  "Score: ${match['team1Score']} - ${match['team2Score']}",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getMatchTypeColor(match['matchType'] ?? 'regular').withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getMatchTypeLabel(match['matchType'] ?? 'regular'),
                                style: TextStyle(
                                  color: _getMatchTypeColor(match['matchType'] ?? 'regular'),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                              ),
                          ],
                        ),
                      ],
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
  
  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
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
}

