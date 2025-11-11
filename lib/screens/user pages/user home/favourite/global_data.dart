
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
  static void updateMatchResult(String tournamentId, int matchIndex, String result, {String? winnerTeam}) {
    if (tournamentMatches[tournamentId] == null || matchIndex >= tournamentMatches[tournamentId]!.length) return;
    
    Map<String, dynamic> match = tournamentMatches[tournamentId]![matchIndex];
    match['result'] = result;
    match['status'] = 'completed';
    
    String team1 = match['team1'];
    String team2 = match['team2'];
    
    // Update points based on result
    if (result == 'abandoned') {
      // 1 point each for abandoned match
      if (team1 != 'BYE') tournamentPoints[tournamentId]![team1] = (tournamentPoints[tournamentId]![team1] ?? 0) + 1;
      if (team2 != 'BYE') tournamentPoints[tournamentId]![team2] = (tournamentPoints[tournamentId]![team2] ?? 0) + 1;
    } else if (result == 'win' && winnerTeam != null) {
      // 2 points for winner, 0 for loser
      if (winnerTeam != 'BYE') {
        tournamentPoints[tournamentId]![winnerTeam] = (tournamentPoints[tournamentId]![winnerTeam] ?? 0) + 2;
      }
      match['winner'] = winnerTeam;
    }
  }
  
  // Get points table for a tournament
  static List<Map<String, dynamic>> getPointsTable(String tournamentId) {
    Map<String, int>? points = tournamentPoints[tournamentId];
    if (points == null) return [];
    
    List<Map<String, dynamic>> table = [];
    points.forEach((team, pts) {
      if (team != 'BYE') {
        // Calculate matches played, won, lost, abandoned
        int played = 0, won = 0, lost = 0, abandoned = 0;
        
        List<Map<String, dynamic>>? matches = tournamentMatches[tournamentId];
        if (matches != null) {
          for (var match in matches) {
            if ((match['team1'] == team || match['team2'] == team) && match['status'] == 'completed') {
              played++;
              String result = match['result'] ?? '';
              if (result == 'abandoned') {
                abandoned++;
              } else if (result == 'win' && match['winner'] == team) {
                won++;
              } else if (result == 'win' && match['winner'] != team) {
                lost++;
              }
            }
          }
        }
        
        table.add({
          'team': team,
          'points': pts,
          'played': played,
          'won': won,
          'lost': lost,
          'abandoned': abandoned,
        });
      }
    });
    
    // Sort by points (descending), then by matches won
    table.sort((a, b) {
      if (a['points'] != b['points']) {
        return b['points'].compareTo(a['points']);
      }
      return b['won'].compareTo(a['won']);
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