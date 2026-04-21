import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user home/favourite/global_data.dart';
import '../../../main.dart';
import '../../../services/tournament_service.dart';
import 'tournament_announcements.dart';

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
  late Map<String, dynamic> _tournament;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tournament = widget.tournament;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tournamentId = widget.tournament['id'] as String? ?? '';

    return StreamBuilder<Map<String, dynamic>>(
      stream: TournamentService.getTournamentStream(tournamentId),
      initialData: widget.tournament,
      builder: (context, snap) {
        if (snap.hasData && snap.data!.isNotEmpty) {
          _tournament = snap.data!;
        }
        return _buildScaffold();
      },
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: AppBar(
            title: Text(
              _tournament['name'] ?? 'Tournament',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Tournament status badge
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(_tournament['status'] as String? ?? 'active')
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _statusColor(_tournament['status'] as String? ?? 'active')),
                ),
                child: Text(
                  _statusLabel(_tournament['status'] as String? ?? 'active'),
                  style: TextStyle(
                      color: _statusColor(_tournament['status'] as String? ?? 'active'),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
                Tab(icon: Icon(Icons.campaign_rounded), text: "Updates"),
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
          TournamentAnnouncementsScreen(
            tournamentId: _tournament['id'] as String? ?? '',
            tournamentName: _tournament['name'] as String? ?? '',
            creatorId: _tournament['createdBy'] as String? ?? '',
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return AppTheme.successColor;
      case 'active': return AppTheme.primaryColor;
      default: return AppTheme.warningColor;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed': return '🏆 Completed';
      case 'active': return '🔴 Live';
      default: return '⏳ Upcoming';
    }
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
    final sport = _tournament['sport'] as String? ?? '';
    final format = _tournament['format'] as String? ?? '';
    final matches = (_tournament['matches'] as List?)?.length ?? 0;
    final completed = (_tournament['matches'] as List? ?? [])
        .where((m) => (m as Map)['status'] == 'completed').length;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getSportIcon(sport), color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_tournament['name'] ?? 'Tournament',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('$sport • $format',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: matches > 0 ? completed / matches : 0,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text('$completed / $matches matches completed',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tournament Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDetailRow("Format", _tournament['format'] ?? ''),
        _buildDetailRow("Teams", "${_tournament['teams'] ?? 0}"),
        _buildDetailRow("Start Date", _tournament['startDate'] ?? ''),
        _buildDetailRow("End Date", _tournament['endDate'] ?? ''),
        _buildDetailRow("Grounds", "${(_tournament['bookedGrounds'] as List?)?.length ?? 0}"),
        _buildDetailRow("Total Matches", "${(_tournament['matches'] as List?)?.length ?? 0}"),
        _buildDetailRow("Status", _statusLabel(_tournament['status'] as String? ?? 'active')),
        if (_tournament['currentLeader'] != null)
          _buildDetailRow("Current Leader", '🏆 ${_tournament['currentLeader']}'),
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
    final rawBookings = _tournament['bookedGrounds'];
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
    final allMatches = GlobalData.tournamentMatches[tournamentId] ??
        (_tournament['matches'] as List?)
            ?.map((m) => Map<String, dynamic>.from(m as Map))
            .toList() ?? [];

    if (matchIndex >= allMatches.length) return;
    final match = allMatches[matchIndex];
    final team1 = _resolveTeamName(match['team1'] ?? '', allMatches);
    final team2 = _resolveTeamName(match['team2'] ?? '', allMatches);

    // Update GlobalData in-memory
    GlobalData.updateMatchResult(
      tournamentId,
      matchIndex,
      result,
      winnerTeam: winner,
      team1Score: team1Score,
      team2Score: team2Score,
    );
    setState(() {});

    // Firestore mein matches + pointsTable dono update karo
    TournamentService.updateMatchResult(
      tournamentId: tournamentId,
      matchIndex: matchIndex,
      result: result == 'win' ? (winner == team1 ? 'team1' : 'team2') : result,
      team1: team1,
      team2: team2,
      team1Score: team1Score,
      team2Score: team2Score,
    );

    String message;
    if (result == 'abandoned') {
      message = "Match abandoned. Each team gets 1 point.";
    } else if (result == 'draw') {
      message = "Draw! Each team gets 1 point.";
    } else {
      message = "🏆 $winner wins! 3 points awarded.";
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: result == 'abandoned' ? Colors.grey : AppTheme.successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _buildPointsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final format = _tournament['format'] as String? ?? '';
    final isRoundRobin = format == 'Round Robin';

    // Use Firestore pointsTable (real-time via stream) — fallback to GlobalData
    Map<String, dynamic> firestoreTable =
        Map<String, dynamic>.from(_tournament['pointsTable'] as Map? ?? {});

    // Build sorted standings list
    List<Map<String, dynamic>> standings = firestoreTable.entries.map((e) {
      final data = Map<String, dynamic>.from(e.value as Map? ?? {});
      final gf = data['goalsFor'] as int? ?? 0;
      final ga = data['goalsAgainst'] as int? ?? 0;
      return {
        'team': e.key,
        'played': data['played'] ?? 0,
        'won': data['won'] ?? 0,
        'drawn': data['drawn'] ?? 0,
        'lost': data['lost'] ?? 0,
        'goalsFor': gf,
        'goalsAgainst': ga,
        'goalDifference': gf - ga,
        'points': data['points'] ?? 0,
      };
    }).toList();

    // Sort: points desc → GD desc → GF desc
    standings.sort((a, b) {
      final pts = (b['points'] as int).compareTo(a['points'] as int);
      if (pts != 0) return pts;
      final gd = (b['goalDifference'] as int).compareTo(a['goalDifference'] as int);
      if (gd != 0) return gd;
      return (b['goalsFor'] as int).compareTo(a['goalsFor'] as int);
    });

    // Stats from matches
    final matches = (_tournament['matches'] as List? ?? []);
    final totalMatches = matches.length;
    final completedMatches = matches.where((m) => (m as Map)['status'] == 'completed').length;
    final winner = _tournament['status'] == 'completed'
        ? (standings.isNotEmpty ? standings.first['team'] as String : null)
        : null;

    if (standings.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.leaderboard_rounded, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No standings yet', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Complete matches to see standings', style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13)),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Winner banner
        if (winner != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF9500)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tournament Winner', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(winner, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // Progress card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _statChip('Total', '$totalMatches', Icons.sports_rounded, AppTheme.primaryColor),
              _statChip('Done', '$completedMatches', Icons.check_circle_rounded, AppTheme.successColor),
              _statChip('Left', '${totalMatches - completedMatches}', Icons.schedule_rounded, AppTheme.warningColor),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: totalMatches > 0 ? completedMatches / totalMatches : 0,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 6),
            Text('${totalMatches > 0 ? (completedMatches / totalMatches * 100).toStringAsFixed(0) : 0}% Complete',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ]),
        ),
        const SizedBox(height: 16),

        // Standings table
        Text('Standings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
            ),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(children: [
                  _th('#', 36),
                  _th('Team', 130),
                  _th('P', 32),
                  _th('W', 32),
                  _th('D', 32),
                  _th('L', 32),
                  _th('GF', 36),
                  _th('GA', 36),
                  _th('GD', 40),
                  _th('Pts', 44),
                ]),
              ),
              // Rows
              ...standings.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;
                final gd = t['goalDifference'] as int;
                Color bg;
                if (i == 0) bg = Colors.amber.withValues(alpha: 0.12);
                else if (i < 3 && isRoundRobin) bg = Colors.green.withValues(alpha: 0.08);
                else if (i >= standings.length - 2 && isRoundRobin) bg = Colors.red.withValues(alpha: 0.06);
                else bg = i.isEven ? colorScheme.surface : colorScheme.surfaceContainerHighest;

                return Container(
                  color: bg,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    SizedBox(width: 36, child: Row(children: [
                      Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      if (i == 0) const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 13),
                    ])),
                    SizedBox(width: 130, child: Text(t['team'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    _td('${t['played']}', 32),
                    _tdColor('${t['won']}', 32, Colors.green),
                    _tdColor('${t['drawn']}', 32, Colors.orange),
                    _tdColor('${t['lost']}', 32, Colors.red),
                    _td('${t['goalsFor']}', 36),
                    _td('${t['goalsAgainst']}', 36),
                    SizedBox(width: 40, child: Text('${gd > 0 ? '+' : ''}$gd', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: gd > 0 ? Colors.green : gd < 0 ? Colors.red : null))),
                    SizedBox(width: 44, child: Text('${t['points']}', textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13))),
                  ]),
                );
              }),
            ]),
          ),
        ),

        // Legend
        if (isRoundRobin) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _legend(Colors.amber, 'Leader'),
            _legend(Colors.green, 'Top 2 → Final'),
            _legend(Colors.red, 'Relegation zone'),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Expanded(child: Text(
                'After all group matches, top 2 teams will play the Final automatically.',
                style: TextStyle(fontSize: 12),
              )),
            ]),
          ),
        ],
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _th(String text, double w) => SizedBox(width: w,
      child: Text(text, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)));

  Widget _td(String text, double w) => SizedBox(width: w,
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)));

  Widget _tdColor(String text, double w, Color color) => SizedBox(width: w,
      child: Text(text, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)));

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Widget _legend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color.withValues(alpha: 0.3),
          border: Border.all(color: color), borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }

  Widget _buildScheduleTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Use Firestore real-time data from stream
    final matches = (_tournament['matches'] as List? ?? [])
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();

    if (matches.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calendar_today_rounded, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text('No schedule available', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      ]));
    }

    // Today's matches
    final todayMatches = matches.where((m) => m['date'] == today).toList();

    // Group by date
    final Map<String, List<Map<String, dynamic>>> byDate = {};
    for (final m in matches) {
      final d = m['date'] as String? ?? 'TBD';
      byDate.putIfAbsent(d, () => []).add(m);
    }
    final sortedDates = byDate.keys.toList()
      ..sort((a, b) {
        if (a == 'TBD') return 1;
        if (b == 'TBD') return -1;
        return a.compareTo(b);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today's matches banner
        if (todayMatches.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.today_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Today's Matches", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
              const SizedBox(height: 10),
              ...todayMatches.map((m) {
                final allM = matches;
                final t1 = _resolveTeamName(m['team1'] ?? '', allM);
                final t2 = _resolveTeamName(m['team2'] ?? '', allM);
                final done = m['status'] == 'completed';
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(t1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        done ? '${m['team1Score'] ?? '-'} : ${m['team2Score'] ?? '-'}' : m['time'] ?? 'VS',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Text(t2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // All dates
        ...sortedDates.map((date) {
          final dayMatches = byDate[date]!;
          final completed = dayMatches.where((m) => m['status'] == 'completed').length;
          final isToday = date == today;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: isToday ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
            ),
            child: Column(children: [
              // Date header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isToday ? AppTheme.primaryGradient : null,
                  color: isToday ? null : const Color(0xFF1A3A4A),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(children: [
                  Icon(isToday ? Icons.today_rounded : Icons.calendar_today_outlined,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    date == 'TBD' ? 'To Be Determined' : _formatDate(date),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  )),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: const Text('TODAY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(width: 8),
                  Text('$completed/${dayMatches.length}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                ]),
              ),
              // Matches
              ...dayMatches.asMap().entries.map((e) {
                final m = e.value;
                final allM = matches;
                final t1 = _resolveTeamName(m['team1'] ?? '', allM);
                final t2 = _resolveTeamName(m['team2'] ?? '', allM);
                final done = m['status'] == 'completed';
                final matchType = m['matchType'] as String? ?? 'regular';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2))),
                  ),
                  child: Row(children: [
                    // Match type badge
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getMatchTypeColor(matchType).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_getMatchTypeLabel(matchType),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getMatchTypeColor(matchType))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: done ? AppTheme.successColor.withValues(alpha: 0.15) : colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: done ? AppTheme.successColor.withValues(alpha: 0.4) : colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        done ? '${m['team1Score'] ?? '-'} : ${m['team2Score'] ?? '-'}' : (m['time'] as String? ?? 'VS'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                            color: done ? AppTheme.successColor : null),
                      ),
                    ),
                    Expanded(child: Text(t2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                    if (done)
                      const Icon(Icons.check_circle_rounded, color: AppTheme.successColor, size: 16)
                    else
                      const Icon(Icons.schedule_rounded, color: Colors.orange, size: 16),
                  ]),
                );
              }),
            ]),
          );
        }),
        const SizedBox(height: 80),
      ],
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

