# PlaySphere - Sequence Diagram Descriptions

## UML Sequence Diagram Components

---

## 1. User Registration Sequence Diagram

### Participants (Left to Right):
1. **Player** (Actor)
2. **UserSignup** (Boundary)
3. **AuthService** (Control)
4. **Firebase Auth** (Entity)

### Sequence Flow:

1. Player → UserSignup: `openSignupScreen()`
2. UserSignup → Player: `displaySignupForm()`
3. Player → UserSignup: `enterDetails(name, email, mobile, password)`
4. Player → UserSignup: `submitForm()`
5. UserSignup → UserSignup: `validateForm()`
6. **[alt valid]**
   - UserSignup → AuthService: `signUpWithEmail(email, password, context)`
   - AuthService → Firebase Auth: `createUserWithEmailAndPassword(email, password)`
   - **[alt success]**
     - Firebase Auth → AuthService: `return UserCredential`
     - AuthService → Firebase Auth: `updateProfile(displayName)`
     - Firebase Auth → AuthService: `return success`
     - AuthService → UserSignup: `return UserCredential`
     - UserSignup → Player: `showSuccessMessage()`
     - UserSignup → Player: `navigateToLogin()`
   - **[alt error]**
     - Firebase Auth → AuthService: `throw FirebaseAuthException`
     - AuthService → AuthService: `_getErrorMessage(code)`
     - AuthService → UserSignup: `return null`
     - UserSignup → Player: `showErrorMessage()`
7. **[else invalid]**
   - UserSignup → Player: `showValidationErrors()`

### Lifelines:
- All participants active throughout the interaction
- AuthService and Firebase Auth have activation boxes during processing

---

## 2. User Login Sequence Diagram

### Participants (Left to Right):
1. **Player** (Actor)
2. **UserLogin** (Boundary)
3. **AuthService** (Control)
4. **Firebase Auth** (Entity)
5. **UserMain** (Boundary)

### Sequence Flow:

1. Player → UserLogin: `openLoginScreen()`
2. UserLogin → Player: `displayLoginForm()`
3. Player → UserLogin: `enterCredentials(email, password)`
4. Player → UserLogin: `clickLogin()`
5. UserLogin → UserLogin: `validateInput()`
6. **[alt valid]**
   - UserLogin → AuthService: `signInWithEmail(email, password, context)`
   - AuthService → Firebase Auth: `signInWithEmailAndPassword(email, password)`
   - **[alt authentication success]**
     - Firebase Auth → AuthService: `return UserCredential`
     - AuthService → UserLogin: `return UserCredential`
     - UserLogin → UserLogin: `createSession()`
     - UserLogin → UserMain: `navigateToDashboard()`
     - UserMain → Player: `displayDashboard()`
   - **[alt authentication failed]**
     - Firebase Auth → AuthService: `throw FirebaseAuthException`
     - AuthService → AuthService: `_getErrorMessage(code)`
     - AuthService → UserLogin: `return null`
     - UserLogin → Player: `showAuthError()`
7. **[else invalid]**
   - UserLogin → Player: `showValidationErrors()`

---

## 3. Venue Booking Sequence Diagram

### Participants (Left to Right):
1. **Player** (Actor)
2. **Categories** (Boundary)
3. **GlobalData** (Entity)
4. **BookingDialog** (Boundary)

### Sequence Flow:

1. Player → Categories: `openCategoriesScreen()`
2. Categories → Player: `displayVenueCategories()`
3. Player → Categories: `selectCategory(categoryName)`
4. Categories → Categories: `filterVenues(categoryName)`
5. Categories → Player: `displayFilteredVenues()`
6. Player → Categories: `selectVenue(venue)`
7. Categories → BookingDialog: `openBookingDialog(venue)`
8. BookingDialog → Player: `displayDatePicker()`
9. Player → BookingDialog: `selectDate(date)`
10. BookingDialog → BookingDialog: `validateDate(date)`
11. **[alt date valid]**
    - BookingDialog → GlobalData: `isSlotAvailable(venueName, date, slot)` (for each slot)
    - GlobalData → BookingDialog: `return availability status`
    - BookingDialog → Player: `displayAvailableSlots()`
    - Player → BookingDialog: `selectSlot(slot)`
    - Player → BookingDialog: `selectPaymentMethod(method)`
    - Player → BookingDialog: `confirmBooking()`
    - BookingDialog → BookingDialog: `validateAllFields()`
    - **[alt all fields selected]**
      - BookingDialog → GlobalData: `addToBookedGrounds(bookingDetails)`
      - GlobalData → GlobalData: `updateBookedSlots(venue, date, slot)`
      - GlobalData → BookingDialog: `return success`
      - BookingDialog → Player: `showSuccessMessage()`
      - BookingDialog → Categories: `closeDialog()`
    - **[else missing fields]**
      - BookingDialog → Player: `showWarningMessage()`
12. **[else date invalid]**
    - BookingDialog → Player: `showDateError()`

---

## 4. Tournament Creation Sequence Diagram

### Participants (Left to Right):
1. **Player** (Actor)
2. **TournamentForm** (Boundary)
3. **GlobalData** (Entity)
4. **Tournament** (Boundary)

### Sequence Flow:

1. Player → Tournament: `openTournamentScreen()`
2. Tournament → Player: `displayTournamentList()`
3. Player → Tournament: `clickCreateTournament()`
4. Tournament → TournamentForm: `openTournamentForm()`
5. TournamentForm → Player: `displayFormStep1()`
6. Player → TournamentForm: `enterDetails(name, sport, format, teams, dates)`
7. Player → TournamentForm: `nextStep()`
8. TournamentForm → TournamentForm: `validateFormData()`
9. **[alt valid]**
    - TournamentForm → Player: `displayGroundBookingStep()`
    - Player → TournamentForm: `selectGrounds(grounds[])`
    - Player → TournamentForm: `selectSlotsForGrounds()`
    - TournamentForm → GlobalData: `isSlotAvailable(ground, date, slot)` (for each)
    - GlobalData → TournamentForm: `return availability`
    - **[alt slots available]**
      - Player → TournamentForm: `confirmGroundBookings()`
      - TournamentForm → TournamentForm: `generateFixtures(format, teams)`
      - **[alt Round Robin]**
        - TournamentForm → TournamentForm: `generateRoundRobinFixtures()`
      - **[alt Knockout]**
        - TournamentForm → TournamentForm: `generateKnockoutFixtures()`
      - TournamentForm → GlobalData: `addTournament(tournamentData)`
      - GlobalData → GlobalData: `initializeTournament(id, teams, matches)`
      - GlobalData → GlobalData: `addTournamentBooking(ground, date, slot)` (for each)
      - GlobalData → TournamentForm: `return success`
      - TournamentForm → Player: `showSuccessMessage()`
      - TournamentForm → Tournament: `navigateToTournamentList()`
      - Tournament → Player: `displayUpdatedList()`
    - **[else slots unavailable]**
      - TournamentForm → Player: `showSlotConflictError()`
10. **[else invalid]**
    - TournamentForm → Player: `showValidationErrors()`

---

## 5. Match Result Update Sequence Diagram

### Participants (Left to Right):
1. **Player** (Actor)
2. **Tournament** (Boundary)
3. **ResultDialog** (Boundary)
4. **GlobalData** (Entity)

### Sequence Flow:

1. Player → Tournament: `viewTournamentDetails(tournamentId)`
2. Tournament → GlobalData: `getTournament(tournamentId)`
3. GlobalData → Tournament: `return tournamentData`
4. Tournament → GlobalData: `tournamentMatches[tournamentId]`
5. GlobalData → Tournament: `return matches[]`
6. Tournament → Player: `displayMatchList(matches)`
7. Player → Tournament: `selectMatch(matchIndex)`
8. Tournament → ResultDialog: `openResultDialog(match)`
9. ResultDialog → Player: `displayResultForm()`
10. Player → ResultDialog: `enterScores(team1Score, team2Score)`
11. Player → ResultDialog: `selectWinner(winner)`
12. Player → ResultDialog: `submitResult()`
13. ResultDialog → ResultDialog: `validateResult()`
14. **[alt valid]**
    - ResultDialog → GlobalData: `updateMatchResult(tournamentId, matchIndex, result, winner, scores)`
    - GlobalData → GlobalData: `updateMatchStatus()`
    - GlobalData → GlobalData: `calculatePoints(result, winner)`
    - GlobalData → GlobalData: `updateTournamentPoints()`
    - GlobalData → ResultDialog: `return success`
    - ResultDialog → Tournament: `closeDialog()`
    - Tournament → GlobalData: `getPointsTable(tournamentId)`
    - GlobalData → Tournament: `return pointsTable[]`
    - Tournament → Player: `displayUpdatedPointsTable()`
15. **[else invalid]**
    - ResultDialog → Player: `showValidationError()`

---

## 6. Favorites Management Sequence Diagram

### Participants (Left to Right):
1. **Player** (Actor)
2. **Categories** (Boundary)
3. **GlobalData** (Entity)
4. **Favourite** (Boundary)

### Sequence Flow:

**Add to Favorites:**
1. Player → Categories: `viewVenueCard(venue)`
2. Categories → GlobalData: `favouriteGrounds.contains(venue)`
3. GlobalData → Categories: `return false`
4. Categories → Player: `displayEmptyHeartIcon()`
5. Player → Categories: `tapHeartIcon(venue)`
6. Categories → GlobalData: `favouriteGrounds.add(venue)`
7. GlobalData → Categories: `return success`
8. Categories → Player: `displayFilledHeartIcon()`

**View Favorites:**
9. Player → Favourite: `openFavouritesScreen()`
10. Favourite → GlobalData: `getFavouriteGrounds()`
11. GlobalData → Favourite: `return favouriteGrounds[]`
12. **[alt has favorites]**
    - Favourite → Player: `displayFavoritesList()`
13. **[else empty]**
    - Favourite → Player: `displayEmptyState()`

**Remove from Favorites:**
14. Player → Favourite: `tapHeartIcon(venue)`
15. Favourite → GlobalData: `favouriteGrounds.remove(venue)`
16. GlobalData → Favourite: `return success`
17. Favourite → Player: `updateDisplay()`

---

## 7. Manager Dashboard Load Sequence Diagram

### Participants (Left to Right):
1. **Manager** (Actor)
2. **Managerhome** (Boundary)
3. **ManagerDashboard** (Boundary)
4. **GlobalData** (Entity)

### Sequence Flow:

1. Manager → Managerhome: `openManagerDashboard()`
2. Managerhome → ManagerDashboard: `loadDashboard()`
3. ManagerDashboard → GlobalData: `getTodayBookings()`
4. GlobalData → ManagerDashboard: `return todayBookings[]`
5. ManagerDashboard → GlobalData: `getTotalVenues()`
6. GlobalData → ManagerDashboard: `return venueCount`
7. ManagerDashboard → GlobalData: `getBookingStats()`
8. GlobalData → ManagerDashboard: `return stats`
9. ManagerDashboard → ManagerDashboard: `calculateQuickStats()`
10. ManagerDashboard → Manager: `displayDashboard(quickActions, bookings, stats)`
11. Manager → ManagerDashboard: `clickQuickAction(action)`
12. **[alt Book Venue]**
    - ManagerDashboard → Manager: `showComingSoonMessage()`
13. **[alt Future Bookings]**
    - ManagerDashboard → Manager: `showComingSoonMessage()`
14. **[alt Add Venue]**
    - ManagerDashboard → Manager: `showComingSoonMessage()`

---

## 8. Manager Analytics View Sequence Diagram

### Participants (Left to Right):
1. **Manager** (Actor)
2. **Managerhome** (Boundary)
3. **ManagerAnalytics** (Boundary)
4. **GlobalData** (Entity)

### Sequence Flow:

1. Manager → Managerhome: `switchToAnalyticsTab()`
2. Managerhome → ManagerAnalytics: `loadAnalytics()`
3. ManagerAnalytics → GlobalData: `getAllBookings()`
4. GlobalData → ManagerAnalytics: `return bookings[]`
5. ManagerAnalytics → ManagerAnalytics: `calculateBookingStats(bookings)`
6. ManagerAnalytics → ManagerAnalytics: `calculateRevenue(bookings)`
7. ManagerAnalytics → ManagerAnalytics: `generateChartData(selectedPeriod)`
8. ManagerAnalytics → Manager: `displayAnalytics(stats, charts)`
9. Manager → ManagerAnalytics: `selectPeriod(period)`
10. ManagerAnalytics → ManagerAnalytics: `filterDataByPeriod(period)`
11. ManagerAnalytics → ManagerAnalytics: `updateChartData(filteredData)`
12. ManagerAnalytics → Manager: `displayUpdatedCharts()`

---

## 9. Profile Update Sequence Diagram

### Participants (Left to Right):
1. **User** (Actor)
2. **Profile** (Boundary)
3. **ImagePicker** (Control)
4. **SharedPreferences** (Entity)
5. **AuthService** (Control)
6. **Firebase Auth** (Entity)

### Sequence Flow:

**Update Profile Image:**
1. User → Profile: `openProfileScreen()`
2. Profile → SharedPreferences: `getString('imagePath_${uid}')`
3. SharedPreferences → Profile: `return imagePath`
4. Profile → User: `displayProfile(currentImage)`
5. User → Profile: `tapEditImage()`
6. Profile → ImagePicker: `pickImage(source: gallery)`
7. ImagePicker → Profile: `return imageFile`
8. Profile → SharedPreferences: `setString('imagePath_${uid}', path)`
9. SharedPreferences → Profile: `return success`
10. Profile → User: `displayUpdatedImage()`

**Change Password:**
11. User → Profile: `clickChangePassword()`
12. Profile → User: `displayPasswordDialog()`
13. User → Profile: `enterPasswords(current, new, confirm)`
14. Profile → Profile: `validatePasswords()`
15. **[alt valid]**
    - Profile → AuthService: `signInWithEmail(email, currentPassword)`
    - AuthService → Firebase Auth: `signInWithEmailAndPassword()`
    - **[alt re-auth success]**
      - Firebase Auth → AuthService: `return UserCredential`
      - AuthService → Firebase Auth: `updatePassword(newPassword)`
      - Firebase Auth → AuthService: `return success`
      - AuthService → Profile: `return true`
      - Profile → User: `showSuccessMessage()`
    - **[alt re-auth failed]**
      - Firebase Auth → AuthService: `throw exception`
      - AuthService → Profile: `return false`
      - Profile → User: `showErrorMessage()`
16. **[else invalid]**
    - Profile → User: `showValidationErrors()`

---

## 10. Logout Sequence Diagram

### Participants (Left to Right):
1. **User** (Actor)
2. **Profile** (Boundary)
3. **AuthService** (Control)
4. **Firebase Auth** (Entity)
5. **GlobalData** (Entity)
6. **Role** (Boundary)

### Sequence Flow:

1. User → Profile: `clickLogout()`
2. Profile → Profile: `showConfirmationDialog()`
3. User → Profile: `confirmLogout()`
4. Profile → AuthService: `signOut()`
5. AuthService → Firebase Auth: `signOut()`
6. Firebase Auth → AuthService: `return success`
7. AuthService → Profile: `return void`
8. Profile → GlobalData: `clearSessionData()`
9. GlobalData → Profile: `return success`
10. Profile → Role: `navigateToRoleScreen()`
11. Role → User: `displayRoleSelection()`

---

## Sequence Diagram Notation Guide

### Participants:
- **Actor:** Stick figure (User/Player/Manager)
- **Boundary:** Circle with line (UI Components)
- **Control:** Circle with arrow (Services)
- **Entity:** Circle with underline (Data/Database)

### Messages:
- **Synchronous Call:** Solid line with filled arrow →
- **Return:** Dashed line with open arrow ⤶
- **Self Call:** Loop back to same lifeline ↻
- **Create:** Dashed line with "new" label
- **Destroy:** X at end of lifeline

### Fragments:
- **alt:** Alternative (if-else)
- **opt:** Optional (if)
- **loop:** Iteration
- **par:** Parallel execution
- **ref:** Reference to another diagram

### Lifelines:
- Vertical dashed lines below participants
- Activation boxes show when object is active

---

## How to Draw Sequence Diagrams

### Step 1: Identify Participants
- List all actors, boundaries, controls, and entities
- Arrange left to right in order of interaction

### Step 2: Draw Lifelines
- Draw vertical dashed lines below each participant
- Extend throughout the interaction

### Step 3: Add Messages
- Draw arrows between lifelines for each interaction
- Label with method name and parameters
- Number messages sequentially

### Step 4: Add Activation Boxes
- Draw rectangles on lifelines when object is processing
- Stack boxes for nested calls

### Step 5: Add Fragments
- Draw frames around conditional or loop sections
- Label with fragment type (alt, opt, loop)

### Step 6: Add Return Messages
- Use dashed arrows for return values
- Label with return data type or value

### Layout Tips:
- Keep messages horizontal
- Minimize crossing lines
- Group related interactions
- Use consistent spacing
- Add notes for clarification

---

## Common Patterns in PlaySphere

### Authentication Pattern:
```
User → UI → AuthService → Firebase Auth
                ↓
            return result
                ↓
            UI → User (display result)
```

### Data Access Pattern:
```
User → UI → GlobalData
            ↓
        return data
            ↓
        UI → User (display data)
```

### Validation Pattern:
```
User → UI → UI.validate()
            ↓
        [alt valid]
            process
        [else invalid]
            show error
```

---

**Document Version:** 1.0  
**Last Updated:** December 1, 2024  
**Status:** Complete
