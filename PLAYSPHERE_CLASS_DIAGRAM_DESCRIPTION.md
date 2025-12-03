# PlaySphere - Class Diagram Description

## UML Class Diagram Components

### Classes and Their Members

---

## 1. SERVICE LAYER

### Class: AuthService
**Type:** Service Class  
**Purpose:** Handles Firebase authentication operations

**Attributes:**
- `- _auth: FirebaseAuth` (private, final)

**Properties:**
- `+ currentUser: User?` (getter)
- `+ authStateChanges: Stream<User?>` (getter)

**Methods:**
- `+ signUpWithEmail(email: String, password: String, context: BuildContext): Future<UserCredential?>`
- `+ signInWithEmail(email: String, password: String, context: BuildContext): Future<UserCredential?>`
- `+ signOut(): Future<void>`
- `+ sendPasswordResetEmail(email: String, context: BuildContext): Future<bool>`
- `+ updateProfile(displayName: String, photoURL: String?): Future<bool>`
- `+ deleteAccount(context: BuildContext): Future<bool>`
- `- _getErrorMessage(code: String): String` (private)
- `- _showErrorSnackBar(context: BuildContext, message: String): void` (private)
- `- _showSuccessSnackBar(context: BuildContext, message: String): void` (private)

---

## 2. DATA LAYER

### Class: GlobalData
**Type:** Singleton/Static Data Class  
**Purpose:** Manages application-wide state and data

**Static Attributes:**
- `+ favouriteGrounds: List<Map<String, dynamic>>`
- `+ bookedGrounds: List<Map<String, dynamic>>`
- `+ tournaments: List<Map<String, dynamic>>`
- `+ tournamentBookedSlots: Map<String, Map<String, List<String>>>`
- `+ tournamentMatches: Map<String, List<Map<String, dynamic>>>`
- `+ tournamentPoints: Map<String, Map<String, int>>`

**Static Methods:**
- `+ isSlotAvailable(groundName: String, date: String, slot: String): bool`
- `+ addTournamentBooking(groundName: String, date: String, slot: String): void`
- `+ removeTournamentBooking(groundName: String, date: String, slot: String): void`
- `+ initializeTournament(tournamentId: String, teamNames: List<String>, matches: List<Map<String, dynamic>>): void`
- `+ updateMatchResult(tournamentId: String, matchIndex: int, result: String, winnerTeam: String?, team1Score: int?, team2Score: int?): void`
- `+ getUpcomingMatches(tournamentId: String, limit: int): List<Map<String, dynamic>>`
- `+ getCompletedMatches(tournamentId: String): List<Map<String, dynamic>>`
- `+ getTournamentStats(tournamentId: String): Map<String, dynamic>`
- `+ getPointsTable(tournamentId: String): List<Map<String, dynamic>>`
- `+ getTournament(tournamentId: String): Map<String, dynamic>?`
- `+ updateTournament(tournamentId: String, updatedData: Map<String, dynamic>): void`

---

## 3. UI LAYER - SCREENS

### Class: MyApp
**Type:** StatelessWidget  
**Purpose:** Root application widget

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ build(context: BuildContext): Widget`

---

### Class: SplashScreen
**Type:** StatefulWidget  
**Purpose:** Initial loading screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<SplashScreen>`

**Inner Class:** `_SplashScreenState`
- `+ initState(): void`
- `+ build(context: BuildContext): Widget`

---

### Class: Role
**Type:** StatefulWidget  
**Purpose:** Role selection screen (Player/Manager)

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Role>`

**Inner Class:** `_RoleState`
- `+ build(context: BuildContext): Widget`

---

### Class: UserSignup
**Type:** StatefulWidget  
**Purpose:** Player registration screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<UserSignup>`

**Inner Class:** `_SignupState`
**Attributes:**
- `- showPass: bool`
- `- isLoading: bool`
- `- formkey: GlobalKey<FormState>`
- `- _authService: AuthService`
- `- fullName: TextEditingController`
- `- eMail: TextEditingController`
- `- mobileNo: TextEditingController`
- `- password: TextEditingController`

**Methods:**
- `- _handleSignup(): Future<void>`
- `+ dispose(): void`
- `+ build(context: BuildContext): Widget`

---

### Class: UserLogin
**Type:** StatefulWidget  
**Purpose:** Player login screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<UserLogin>`

**Inner Class:** `_UserLoginState`
**Attributes:**
- `- formkey: GlobalKey<FormState>`
- `- eMail: TextEditingController`
- `- password: TextEditingController`
- `- _authService: AuthService`
- `- isLoading: bool`

**Methods:**
- `- _handleLogin(): Future<void>`
- `+ dispose(): void`
- `+ build(context: BuildContext): Widget`

---

### Class: ManagerSignup
**Type:** StatefulWidget  
**Purpose:** Manager registration screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<ManagerSignup>`

**Inner Class:** `_ManagerSignupState`
**Attributes:**
- Similar to UserSignup with additional venue-related fields

---

### Class: ManagerLogin
**Type:** StatefulWidget  
**Purpose:** Manager login screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<ManagerLogin>`

**Inner Class:** `_ManagerLoginState`
**Attributes:**
- Similar to UserLogin

---

### Class: UserMain
**Type:** StatefulWidget  
**Purpose:** Player main navigation container

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<UserMain>`

**Inner Class:** `_UserMainState`
**Attributes:**
- `- index: int`
- `- userpages: List<Widget>`

**Methods:**
- `+ build(context: BuildContext): Widget`
- `- _buildModernBottomNav(context: BuildContext): Widget`

---

### Class: Home
**Type:** StatefulWidget  
**Purpose:** Player home/dashboard screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Home>`

---

### Class: Categories
**Type:** StatefulWidget  
**Purpose:** Venue browsing and booking screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Categories>`

**Inner Class:** `_CategoriesState`
**Attributes:**
- `- selectedIndex: int`
- `- bookedSlots: Map<String, Map<String, List<String>>>`
- `- categories: List<Map<String, dynamic>>`
- `- sports: List<Map<String, dynamic>>`

**Methods:**
- `- getSlots(category: String): List<String>`
- `- _showBookingDialog(ground: Map<String, dynamic>): void`
- `+ build(context: BuildContext): Widget`

---

### Class: Favourite
**Type:** StatefulWidget  
**Purpose:** Favorites management screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Favourite>`

---

### Class: Booked
**Type:** StatefulWidget  
**Purpose:** Booking history screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Booked>`

---

### Class: Tournament
**Type:** StatefulWidget  
**Purpose:** Tournament list and management screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Tournament>`

---

### Class: TournamentForm
**Type:** StatefulWidget  
**Purpose:** Tournament creation form

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<TournamentForm>`

**Inner Class:** `_TournamentFormState`
**Attributes:**
- `- _formKey: GlobalKey<FormState>`
- `- name: TextEditingController`
- `- startDateController: TextEditingController`
- `- endDateController: TextEditingController`
- `- selectedSport: String?`
- `- selectedTeam: String?`
- `- selectedFormat: String?`
- `- pickedStartDate: DateTime?`
- `- pickedEndDate: DateTime?`
- `- currentStep: int`
- `- teamControllers: List<TextEditingController>`
- `- selectedGrounds: List<Map<String, dynamic>>`
- `- fixtures: List<List<String>>`

**Methods:**
- `- getSlots(category: String): List<String>`
- `+ build(context: BuildContext): Widget`

---

### Class: Profile
**Type:** StatefulWidget  
**Purpose:** User profile management screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Profile>`

**Inner Class:** `_ProfileState`
**Attributes:**
- `- _authService: AuthService`
- `- _image: File?`

**Methods:**
- `- _pickImage(): Future<void>`
- `- _saveProfileImage(imagePath: String): Future<void>`
- `- _loadProfileImage(): Future<void>`
- `- _showChangePasswordDialog(): void`
- `+ initState(): void`
- `+ build(context: BuildContext): Widget`

---

### Class: Managerhome
**Type:** StatefulWidget  
**Purpose:** Manager main navigation container

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Managerhome>`

**Inner Class:** `_ManagerhomeState`
**Attributes:**
- `- index: int`
- `- bottomNavItems: List<String>`
- `- managerPages: List<Widget>`

**Methods:**
- `+ build(context: BuildContext): Widget`

---

### Class: ManagerDashboard
**Type:** StatefulWidget  
**Purpose:** Manager dashboard screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<ManagerDashboard>`

**Inner Class:** `_ManagerDashboardState`
**Attributes:**
- `- todayBookings: List<Map<String, dynamic>>`

**Methods:**
- `- _buildActionCard(...): Widget`
- `- _buildTodayBookingsList(context: BuildContext): Widget`
- `- _buildQuickStatCard(...): Widget`
- `+ build(context: BuildContext): Widget`

---

### Class: ManagerAnalytics
**Type:** StatefulWidget  
**Purpose:** Manager analytics and reporting screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<ManagerAnalytics>`

**Inner Class:** `_ManagerAnalyticsState`
**Attributes:**
- `- selectedPeriod: String`
- `- bookingStats: Map<String, dynamic>`

**Methods:**
- `- _buildStatCard(...): Widget`
- `- _buildPeriodButton(period: String): Widget`
- `- _buildRevenueChart(): Widget`
- `- _buildBookingsChart(): Widget`
- `- _getRevenueSpots(): List<FlSpot>`
- `- _getBookingBars(): List<BarChartGroupData>`
- `- _getMaxX(): double`
- `- _getBottomTitles(value: int): Widget`
- `+ build(context: BuildContext): Widget`

---

### Class: ManagerProfile
**Type:** StatefulWidget  
**Purpose:** Manager profile management screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<ManagerProfile>`

---

### Class: Notifications
**Type:** StatefulWidget  
**Purpose:** Player notifications screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<Notifications>`

---

### Class: ManagerNotifications
**Type:** StatefulWidget  
**Purpose:** Manager notifications screen

**Attributes:**
- `+ key: Key?`

**Methods:**
- `+ createState(): State<ManagerNotifications>`

---

## 4. CUSTOM WIDGETS

### Class: ModernCard
**Type:** StatefulWidget  
**Purpose:** Reusable card component with animations

**Attributes:**
- `+ key: Key?`
- `+ child: Widget`
- `+ padding: EdgeInsetsGeometry?`
- `+ margin: EdgeInsetsGeometry?`
- `+ onTap: VoidCallback?`
- `+ color: Color?`
- `+ elevation: double?`
- `+ gradient: Gradient?`

**Methods:**
- `+ createState(): State<ModernCard>`

**Inner Class:** `_ModernCardState`
**Attributes:**
- `- _controller: AnimationController`
- `- _scaleAnimation: Animation<double>`

**Methods:**
- `+ initState(): void`
- `+ dispose(): void`
- `+ build(context: BuildContext): Widget`

---

### Class: GradientButton
**Type:** StatefulWidget  
**Purpose:** Reusable gradient button with animations

**Attributes:**
- `+ key: Key?`
- `+ text: String`
- `+ onPressed: VoidCallback?`
- `+ gradient: Gradient?`
- `+ padding: EdgeInsetsGeometry?`
- `+ width: double?`
- `+ height: double?`
- `+ textStyle: TextStyle?`
- `+ icon: IconData?`

**Methods:**
- `+ createState(): State<GradientButton>`

**Inner Class:** `_GradientButtonState`
**Attributes:**
- `- _controller: AnimationController`
- `- _scaleAnimation: Animation<double>`
- `- _elevationAnimation: Animation<double>`

**Methods:**
- `+ initState(): void`
- `+ dispose(): void`
- `+ build(context: BuildContext): Widget`

---

### Class: ModernAppBar
**Type:** StatelessWidget  
**Purpose:** Reusable app bar with gradient

**Implements:** `PreferredSizeWidget`

**Attributes:**
- `+ key: Key?`
- `+ title: String`
- `+ actions: List<Widget>?`
- `+ leading: Widget?`
- `+ centerTitle: bool`
- `+ gradient: Gradient?`
- `+ elevation: double`

**Methods:**
- `+ build(context: BuildContext): Widget`
- `+ preferredSize: Size` (getter)

---

### Class: ShimmerContainer
**Type:** StatefulWidget  
**Purpose:** Loading shimmer effect widget

**Attributes:**
- `+ key: Key?`
- `+ width: double`
- `+ height: double`
- `+ borderRadius: BorderRadius?`

**Methods:**
- `+ createState(): State<ShimmerContainer>`

**Inner Class:** `_ShimmerContainerState`
**Attributes:**
- `- _controller: AnimationController`

**Methods:**
- `+ initState(): void`
- `+ dispose(): void`
- `+ build(context: BuildContext): Widget`

---

## 5. THEME AND STYLING

### Class: AppTheme
**Type:** Static Class  
**Purpose:** Application-wide theme configuration

**Static Constants:**
- `+ primaryColor: Color`
- `+ primaryVariant: Color`
- `+ secondaryColor: Color`
- `+ secondaryVariant: Color`
- `+ accentColor: Color`
- `+ errorColor: Color`
- `+ warningColor: Color`
- `+ successColor: Color`
- `+ backgroundLight: Color`
- `+ backgroundDark: Color`
- `+ surfaceLight: Color`
- `+ surfaceDark: Color`
- `+ textPrimary: Color`
- `+ textSecondary: Color`
- `+ textTertiary: Color`
- `+ primaryGradient: LinearGradient`
- `+ secondaryGradient: LinearGradient`
- `+ accentGradient: LinearGradient`
- `+ heroGradient: LinearGradient`
- `+ fastAnimation: Duration`
- `+ normalAnimation: Duration`
- `+ slowAnimation: Duration`
- `+ defaultCurve: Curve`
- `+ bounceCurve: Curve`
- `+ smoothCurve: Curve`

**Static Methods:**
- `+ lightTheme: ThemeData` (getter)
- `+ darkTheme: ThemeData` (getter)

---

## 6. NAVIGATION

### Class: SlidePageRoute
**Type:** PageRouteBuilder  
**Purpose:** Custom page transition with slide animation

**Attributes:**
- `+ page: Widget`

**Methods:**
- Constructor with pageBuilder and transitionsBuilder

---

### Class: FadePageRoute
**Type:** PageRouteBuilder  
**Purpose:** Custom page transition with fade animation

**Attributes:**
- `+ page: Widget`

**Methods:**
- Constructor with pageBuilder and transitionsBuilder

---

## 7. SEARCH

### Class: GroundSearchDelegate
**Type:** SearchDelegate<Map<String, dynamic>?>  
**Purpose:** Custom search functionality for venues

**Attributes:**
- `+ sports: List<Map<String, dynamic>>`

**Methods:**
- `+ searchFieldLabel: String` (getter)
- `+ appBarTheme(context: BuildContext): ThemeData`
- `+ buildActions(context: BuildContext): List<Widget>`
- `+ buildLeading(context: BuildContext): Widget`
- `+ buildResults(context: BuildContext): Widget`
- `+ buildSuggestions(context: BuildContext): Widget`
- `- _buildSearchResults(context: BuildContext): Widget`

---

## Class Relationships

### Inheritance Relationships
```
StatelessWidget
    ├── MyApp
    ├── ModernAppBar
    └── (other stateless widgets)

StatefulWidget
    ├── SplashScreen
    ├── Role
    ├── UserSignup
    ├── UserLogin
    ├── ManagerSignup
    ├── ManagerLogin
    ├── UserMain
    ├── Home
    ├── Categories
    ├── Favourite
    ├── Booked
    ├── Tournament
    ├── TournamentForm
    ├── Profile
    ├── Managerhome
    ├── ManagerDashboard
    ├── ManagerAnalytics
    ├── ManagerProfile
    ├── Notifications
    ├── ManagerNotifications
    ├── ModernCard
    ├── GradientButton
    └── ShimmerContainer

PageRouteBuilder
    ├── SlidePageRoute
    └── FadePageRoute

SearchDelegate<Map<String, dynamic>?>
    └── GroundSearchDelegate

PreferredSizeWidget
    └── ModernAppBar (implements)
```

### Association Relationships

**AuthService** ←uses─ **UserSignup, UserLogin, ManagerSignup, ManagerLogin, Profile, ManagerProfile**

**GlobalData** ←uses─ **Categories, Favourite, Booked, Tournament, TournamentForm**

**AppTheme** ←uses─ **All UI Components**

**ModernCard** ←uses─ **Multiple Screens**

**GradientButton** ←uses─ **Multiple Screens**

**ModernAppBar** ←uses─ **Multiple Screens**

---

## Dependency Relationships

```
UI Layer (Screens)
    ↓ depends on
Service Layer (AuthService)
    ↓ depends on
Firebase SDK

UI Layer (Screens)
    ↓ depends on
Data Layer (GlobalData)
    ↓ depends on
Dart Collections

UI Layer (Screens)
    ↓ depends on
Custom Widgets (ModernCard, GradientButton, etc.)
    ↓ depends on
Theme (AppTheme)
```

---

## Composition Relationships

**UserMain** ◆─contains─> **Home, Booked, Tournament**

**Managerhome** ◆─contains─> **ManagerDashboard, ManagerAnalytics**

**Categories** ◆─contains─> **GroundSearchDelegate**

**ModernCard** ◆─contains─> **AnimationController**

**GradientButton** ◆─contains─> **AnimationController**

---

## Aggregation Relationships

**_CategoriesState** ◇─has─> **List<Map<String, dynamic>> sports**

**_TournamentFormState** ◇─has─> **List<TextEditingController> teamControllers**

**GlobalData** ◇─has─> **List<Map<String, dynamic>> tournaments**

---

## Multiplicity

- **AuthService** : **Screens** = 1 : *
- **GlobalData** : **Screens** = 1 : *
- **AppTheme** : **Widgets** = 1 : *
- **UserMain** : **Pages** = 1 : 3
- **Managerhome** : **Pages** = 1 : 2

---

## How to Draw the Class Diagram

### Step 1: Draw Main Classes
- Draw rectangles divided into 3 sections (Name, Attributes, Methods)
- Group by layer: Service, Data, UI, Widgets, Theme

### Step 2: Add Relationships
- **Inheritance:** Solid line with hollow triangle arrow
- **Association:** Solid line with arrow
- **Dependency:** Dashed line with arrow
- **Composition:** Solid line with filled diamond
- **Aggregation:** Solid line with hollow diamond

### Step 3: Add Multiplicity
- Mark cardinality on relationship lines (1, *, 0..1, 1..*)

### Step 4: Group by Package
- Create packages for: services, screens, widgets, theme, data

### Layout Suggestion
```
Top: Service Layer (AuthService)
Middle-Top: Data Layer (GlobalData)
Middle: UI Screens (organized by role)
Middle-Bottom: Custom Widgets
Bottom: Theme and Utilities
```
