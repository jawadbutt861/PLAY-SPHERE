
class GlobalData {
  static List<Map<String, dynamic>> favouriteGrounds = [];
  static List<Map<String, dynamic>> bookedGrounds = [];
  static List<Map<String, dynamic>> tournaments = [];
  
  // Tournament booking conflicts tracking
  static Map<String, Map<String, List<String>>> tournamentBookedSlots = {}; // groundName -> date -> slots
  
  // Match results tracking
  static Map<String, List<Map<String, dynamic>>> tournamentMatches = {}; // tournamentId -> matches
  static Map<String, Map<String, int>> tournamentPoints = {}; // tournamentId -> teamName -> points
  
  // Check if a slot is available for booking (not conflicting with tournaments)
  static bool isSlotAvailable(String groundName, String date, String slot) {
    Map<String, List<String>>? groundBookings = tournamentBookedSlots[groundName];
    if (groundBookings == null) return true;
    
    List<String>? dateSlots = groundBookings[date];
    if (dateSlots == null) return true;
    
    return !dateSlots.contains(slot);
  }
  
  // Add tournament booking to prevent conflicts
  static void addTournamentBooking(String groundName, String date, String slot) {
    tournamentBookedSlots.putIfAbsent(groundName, () => {});
    tournamentBookedSlots[groundName]!.putIfAbsent(date, () => []);
    tournamentBookedSlots[groundName]![date]!.add(slot);
  }
  
  // Remove tournament booking when tournament ends early
  static void removeTournamentBooking(String groundName, String date, String slot) {
    Map<String, List<String>>? groundBookings = tournamentBookedSlots[groundName];
    if (groundBookings != null) {
      List<String>? dateSlots = groundBookings[date];
      if (dateSlots != null) {
        dateSlots.remove(slot);
        if (dateSlots.isEmpty) {
          groundBookings.remove(date);
        }
      }
      if (groundBookings.isEmpty) {
        tournamentBookedSlots.remove(groundName);
      }
    }
  }
  
  // Initialize tournament matches and points
  static void initializeTournament(String tournamentId, List<String> teamNames, List<Map<String, dynamic>> matches) {
    tournamentMatches[tournamentId] = matches;
    tournamentPoints[tournamentId] = {};
    
    // Initialize points for all teams
    for (String team in teamNames) {
      if (team != 'BYE') {
        tournamentPoints[tournamentId]![team] = 0;
      }
    }
  }
  
  // Update match result and points
  static void updateMatchResult(String tournamentId, int matchIndex, String result, {String? winnerTeam, int? team1Score, int? team2Score}) {
    if (tournamentMatches[tournamentId] == null || matchIndex >= tournamentMatches[tournamentId]!.length) return;
    
    Map<String, dynamic> match = tournamentMatches[tournamentId]![matchIndex];
    match['result'] = result;
    match['status'] = 'completed';
    match['completedAt'] = DateTime.now().toIso8601String();
    
    String team1 = match['team1'];
    String team2 = match['team2'];
    
    // Store scores if provided
    if (team1Score != null) match['team1Score'] = team1Score;
    if (team2Score != null) match['team2Score'] = team2Score;
    
    // Update points based on result
    if (result == 'abandoned') {
      // 1 point each for abandoned match
      if (team1 != 'BYE') tournamentPoints[tournamentId]![team1] = (tournamentPoints[tournamentId]![team1] ?? 0) + 1;
      if (team2 != 'BYE') tournamentPoints[tournamentId]![team2] = (tournamentPoints[tournamentId]![team2] ?? 0) + 1;
    } else if (result == 'draw') {
      // 1 point each for draw
      if (team1 != 'BYE') tournamentPoints[tournamentId]![team1] = (tournamentPoints[tournamentId]![team1] ?? 0) + 1;
      if (team2 != 'BYE') tournamentPoints[tournamentId]![team2] = (tournamentPoints[tournamentId]![team2] ?? 0) + 1;
    } else if (result == 'win' && winnerTeam != null) {
      // 3 points for winner (standard in football/soccer), 0 for loser
      if (winnerTeam != 'BYE') {
        tournamentPoints[tournamentId]![winnerTeam] = (tournamentPoints[tournamentId]![winnerTeam] ?? 0) + 3;
      }
      match['winner'] = winnerTeam;
    }
  }
  
  // Get upcoming matches for a tournament
  static List<Map<String, dynamic>> getUpcomingMatches(String tournamentId, {int limit = 5}) {
    List<Map<String, dynamic>>? matches = tournamentMatches[tournamentId];
    if (matches == null) return [];
    
    return matches
        .where((m) => m['status'] == 'scheduled')
        .take(limit)
        .toList();
  }
  
  // Get completed matches for a tournament
  static List<Map<String, dynamic>> getCompletedMatches(String tournamentId) {
    List<Map<String, dynamic>>? matches = tournamentMatches[tournamentId];
    if (matches == null) return [];
    
    return matches
        .where((m) => m['status'] == 'completed')
        .toList();
  }
  
  // Get match statistics
  static Map<String, dynamic> getTournamentStats(String tournamentId) {
    List<Map<String, dynamic>>? matches = tournamentMatches[tournamentId];
    if (matches == null) return {};
    
    int total = matches.length;
    int completed = matches.where((m) => m['status'] == 'completed').length;
    int scheduled = matches.where((m) => m['status'] == 'scheduled').length;
    int inProgress = matches.where((m) => m['status'] == 'in_progress').length;
    
    return {
      'total': total,
      'completed': completed,
      'scheduled': scheduled,
      'inProgress': inProgress,
      'completionPercentage': total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0.0',
    };
  }
  
  // Get points table for a tournament
  static List<Map<String, dynamic>> getPointsTable(String tournamentId) {
    Map<String, int>? points = tournamentPoints[tournamentId];
    if (points == null) return [];
    
    List<Map<String, dynamic>> table = [];
    points.forEach((team, pts) {
      if (team != 'BYE') {
        // Calculate matches played, won, lost, abandoned, drawn
        int played = 0, won = 0, lost = 0, abandoned = 0, drawn = 0;
        int goalsFor = 0, goalsAgainst = 0;
        
        List<Map<String, dynamic>>? matches = tournamentMatches[tournamentId];
        if (matches != null) {
          for (var match in matches) {
            bool isTeam1 = match['team1'] == team;
            bool isTeam2 = match['team2'] == team;
            
            if ((isTeam1 || isTeam2) && match['status'] == 'completed') {
              played++;
              String result = match['result'] ?? '';
              
              if (result == 'abandoned') {
                abandoned++;
              } else if (result == 'draw') {
                drawn++;
              } else if (result == 'win' && match['winner'] == team) {
                won++;
              } else if (result == 'win' && match['winner'] != team) {
                lost++;
              }
              
              // Calculate goal difference if scores are available
              if (match['team1Score'] != null && match['team2Score'] != null) {
                if (isTeam1) {
                  goalsFor += match['team1Score'] as int;
                  goalsAgainst += match['team2Score'] as int;
                } else if (isTeam2) {
                  goalsFor += match['team2Score'] as int;
                  goalsAgainst += match['team1Score'] as int;
                }
              }
            }
          }
        }
        
        int goalDifference = goalsFor - goalsAgainst;
        
        table.add({
          'team': team,
          'points': pts,
          'played': played,
          'won': won,
          'drawn': drawn,
          'lost': lost,
          'abandoned': abandoned,
          'goalsFor': goalsFor,
          'goalsAgainst': goalsAgainst,
          'goalDifference': goalDifference,
        });
      }
    });
    
    // Sort by points (descending), then by goal difference, then by goals for
    table.sort((a, b) {
      if (a['points'] != b['points']) {
        return b['points'].compareTo(a['points']);
      }
      if (a['goalDifference'] != b['goalDifference']) {
        return b['goalDifference'].compareTo(a['goalDifference']);
      }
      return b['goalsFor'].compareTo(a['goalsFor']);
    });
    
    return table;
  }
  
  // Get tournament by ID
  static Map<String, dynamic>? getTournament(String tournamentId) {
    try {
      return tournaments.firstWhere((t) => t['id'] == tournamentId);
    } catch (e) {
      return null;
    }
  }
  
  // Update tournament
  static void updateTournament(String tournamentId, Map<String, dynamic> updatedData) {
    int index = tournaments.indexWhere((t) => t['id'] == tournamentId);
    if (index != -1) {
      tournaments[index] = {...tournaments[index], ...updatedData};
    }
  }
}