# PlaySphere - Detailed Diagram Descriptions

## Table of Contents
1. [Level 0 DFD Description](#level-0-dfd-description)
2. [Level 1 DFD Description](#level-1-dfd-description)
3. [Level 2 DFD Descriptions](#level-2-dfd-descriptions)
4. [Use Case Diagram Description](#use-case-diagram-description)

---

## Level 0 DFD Description

### Overview
The Level 0 Data Flow Diagram (Context Diagram) provides the highest-level view of the PlaySphere system. It shows the system as a single process and illustrates how it interacts with external entities.

### External Entities

#### 1. Player User
**Description:** End users who want to book sports venues and participate in tournaments.

**Outgoing Data Flows (To System):**
- **Registration/Login:** Player credentials (email, password, full name, mobile number)
- **Venue Search:** Search queries, category filters (Cricket, Football, Tennis, etc.)
- **Booking Requests:** Venue selection, date, time slot, payment method
- **Tournament Creation:** Tournament details (name, sport, format, teams, dates)
- **Profile Updates:** Profile picture, password changes

**Incoming Data Flows (From System):**
- **Booking Confirmations:** Booking ID, venue details, date/time, payment status
- **Venue Details:** Venue information, images, availability, pricing
- **Tournament Updates:** Match schedules, results, points table
- **Favorites List:** Saved venues with quick access

#### 2. Manager User
**Description:** Venue owners/managers who list their venues and manage bookings.

**Outgoing Data Flows (To System):**
- **Registration/Login:** Manager credentials (email, password, CNIC, business details)
- **Venue Management:** Venue details, images (1-5), location, pricing
- **Booking Management:** Booking confirmations, cancellations, status updates
- **Analytics Requests:** Time period selection (weekly/monthly/yearly)
- **Profile Updates:** Profile picture, password changes

**Incoming Data Flows (From System):**
- **Booking Notifications:** New booking alerts, customer details
- **Revenue Reports:** Earnings data, payment breakdowns
- **Venue Status:** Booking statistics, occupancy rates
- **Dashboard Data:** Quick stats, today's bookings, performance metrics

#### 3. Firebase Backend
**Description:** Cloud-based backend service providing authentication and data storage.

**Bidirectional Data Flows:**
- **Authentication Data:** User credentials, auth tokens, session management
- **User Profiles:** Display names, email addresses, user metadata
- **Venue Data:** Venue listings, images, details (future implementation)
- **Booking Records:** Booking history, active bookings, cancellations
- **Tournament Data:** Tournament details, matches, results

### System Boundary
The **PlaySphere System** acts as the central processing unit that:
- Authenticates users
- Routes users to appropriate dashboards based on role
- Manages venue listings and bookings
- Handles tournament creation and management
- Provides analytics and reporting
- Manages user profiles and preferences

### Key Characteristics
- **Single System View:** The entire application is represented as one process
- **External Focus:** Emphasizes interactions with external entities
- **High-Level Abstraction:** Does not show internal system details
- **Bidirectional Flows:** Data moves both to and from the system

---

## Level 1 DFD Description

### Overview
The Level 1 Data Flow Diagram decomposes the PlaySphere system into five major subsystems, showing how data flows between them and external entities.

### Subsystem 1: Authentication System (1.0)

**Purpose:** Manages user authentication and authorization for both Player and Manager roles.

**Key Processes:**
- **Email/Password Authentication:** Validates user credentials against Firebase Auth
- **User Registration:** Creates new accounts for Players and Managers with different data requirements
- **Password Reset:** Sends password reset emails via Firebase
- **Session Management:** Maintains user login state and auth tokens

**Data Flows:**
- **Input:** Login credentials (email, password), registration data
- **Output:** Auth tokens, user session data, error messages
- **Storage:** Firebase Authentication database

**Business Rules:**
- Passwords must be minimum 8 characters
- Email must be unique and valid format
- CNIC required for Managers (13 digits)
- Mobile numbers must be 11 digits

### Subsystem 2: Role Routing System (2.0)

**Purpose:** Determines user role and routes to appropriate dashboard.

**Key Processes:**
- **Role Selection:** Allows new users to choose Player or Manager role
- **Route to Appropriate Dashboard:** Navigates authenticated users to their role-specific interface

**Data Flows:**
- **Input:** User role selection, auth token
- **Output:** Navigation route to Player Main or Manager Home
- **Decision Logic:** Based on user role stored in Firebase Auth

**Business Rules:**
- Each user can only have one role
- Role is determined at registration
- Authenticated users bypass role selection

### Subsystem 3: Player Module (3.0)

**Purpose:** Provides all functionality for Player users.

**Sub-processes:**

#### 3.1 Venue Browsing
- **Function:** Display venues filtered by sport category
- **Features:** Category tabs (ALL, Cricket, Football, Tennis, Basketball, Hockey, Volleyball)
- **Data:** Venue images, names, categories, availability

#### 3.2 Booking Management
- **Function:** Handle venue booking process
- **Features:** Date selection, time slot availability, payment method selection
- **Data:** Booking records, slot availability, payment details

#### 3.3 Tournament System
- **Function:** Create and manage tournaments
- **Features:** Tournament creation, fixture generation, match scheduling, results tracking
- **Data:** Tournament details, matches, teams, points table

#### 3.4 Favorites System
- **Function:** Save and manage favorite venues
- **Features:** Add/remove favorites, quick access to saved venues
- **Data:** List of favorite venues per user

#### 3.5 Profile Management
- **Function:** Manage user profile and settings
- **Features:** Profile picture upload, password change, logout
- **Data:** User profile data, preferences

**Data Storage:**
- GlobalData (in-memory state)
- SharedPreferences (local storage)
- Firebase Firestore (future implementation)

### Subsystem 4: Manager Module (4.0)

**Purpose:** Provides all functionality for Manager users.

**Sub-processes:**

#### 4.1 Venue Management
- **Function:** Add, edit, and delete venues
- **Features:** Venue details entry, image upload (1-5), pricing setup
- **Data:** Venue listings, images, location, pricing

#### 4.2 Booking Management
- **Function:** View and manage venue bookings
- **Features:** Today's bookings, future bookings, booking status updates
- **Data:** Booking records, customer details, payment status

#### 4.3 Analytics System
- **Function:** Provide business insights and metrics
- **Features:** Revenue trends, booking statistics, performance metrics
- **Data:** Aggregated booking data, revenue calculations, charts

#### 4.4 Notifications
- **Function:** Alert managers of important events
- **Features:** New booking alerts, cancellation notices
- **Data:** Notification messages, timestamps

#### 4.5 Profile Management
- **Function:** Manage manager profile and settings
- **Features:** Profile picture upload, password change, logout
- **Data:** Manager profile data, business details

**Data Storage:**
- Firebase Firestore (future implementation)
- Local state management

### Subsystem 5: Data Storage System (5.0)

**Purpose:** Centralized data persistence layer.

**Storage Components:**

#### Firebase Firestore
- **User Data:** Profiles, preferences, roles
- **Venue Data:** Listings, images, details, pricing
- **Booking Data:** Active bookings, history, cancellations
- **Tournament Data:** Tournament details, matches, results

#### SharedPreferences
- **Local Cache:** User preferences, settings
- **Images:** Profile pictures (stored per user UID)
- **Session Data:** Last login, app state

#### GlobalData (In-Memory)
- **Favorites:** `favouriteGrounds` list
- **Bookings:** `bookedGrounds` list
- **Tournaments:** `tournamentMatches` map
- **Slot Availability:** Booking conflicts tracking

**Data Flow Characteristics:**
- **Persistence:** Firebase for permanent storage
- **Performance:** GlobalData for fast access
- **Offline Support:** SharedPreferences for local caching

---


## Level 2 DFD Descriptions

### 2.1 Player Module - Venue Booking Process

#### Overview
This diagram details the complete venue booking workflow from browsing to confirmation.

#### Process 3.1: Venue Browsing System

**Purpose:** Enable players to discover and explore available sports venues.

**Sub-processes:**

##### 3.1.1 Category Filter
- **Function:** Filter venues by sport type
- **Input:** User's category selection (Cricket, Football, Tennis, Basketball, Hockey, Volleyball, ALL)
- **Processing:** 
  - Display category tabs with icons
  - Filter venue list based on selection
  - Show "ALL" to display all venues
- **Output:** Filtered list of venues
- **UI Elements:** Circular category buttons with sport icons

##### 3.1.2 Venue List Display
- **Function:** Present venues in a grid layout
- **Input:** Filtered venue data from database
- **Processing:**
  - Display venue images (4 per category)
  - Show venue name and category badge
  - Display favorite icon (heart)
  - Show availability status
- **Output:** Interactive venue cards
- **Layout:** Responsive grid (max 200px width per card)

##### 3.1.3 Search Functionality
- **Function:** Allow text-based venue search
- **Input:** Search query from user
- **Processing:**
  - Search by venue name
  - Search by location
  - Real-time filtering
- **Output:** Matching venues
- **Implementation:** Search delegate with custom UI

**Data Store Interaction:**
- **Read:** Venues Database (venue details, images, categories)
- **Write:** None (read-only process)

**Business Rules:**
- Each category has exactly 4 venues
- Venues can belong to only one category
- Images are pre-loaded assets
- Favorite status is user-specific

---

#### Process 3.2: Booking Management System

**Purpose:** Handle the complete booking lifecycle from selection to confirmation.

**Sub-processes:**

##### 3.2.1 Date Selection
- **Function:** Allow user to choose booking date
- **Input:** User interaction with date picker
- **Processing:**
  - Show calendar starting from tomorrow
  - Allow selection up to 30 days ahead
  - Prevent past date selection
- **Output:** Selected date (YYYY-MM-DD format)
- **Validation:** Date must be in future (tomorrow onwards)

##### 3.2.2 Time Slot Availability Check
- **Function:** Display available time slots for selected date
- **Input:** Selected date, venue name
- **Processing:**
  - Retrieve booked slots from `bookedSlots` map
  - Check tournament bookings via `GlobalData.isSlotAvailable()`
  - Generate slot list based on sport category:
    - **Cricket:** "9am to 2pm", "2pm to 6pm", "Full-day"
    - **Other Sports:** Hourly slots from 9am to 11pm
  - Mark unavailable slots:
    - Already booked by users
    - Reserved for tournaments
    - Conflicting with full-day bookings
- **Output:** List of slots with availability status
- **Display:** Radio buttons with status labels (Available/Booked/Tournament/Unavailable)

**Cricket Slot Logic:**
- Full-day booking blocks both half-day slots
- Half-day booking blocks full-day option
- Tournament bookings block all conflicting slots

##### 3.2.3 Payment Method Selection
- **Function:** Choose payment gateway
- **Input:** User selection
- **Options:** 
  - JazzCash
  - EasyPaisa
- **Output:** Selected payment method
- **Note:** Currently mock implementation (no actual payment processing)

##### 3.2.4 Booking Confirmation
- **Function:** Validate and confirm booking
- **Input:** Date, slot, payment method
- **Validation:**
  - All fields must be selected
  - Slot must still be available (race condition check)
  - Date must be valid
- **Processing:**
  - Create booking record
  - Generate booking details
- **Output:** Booking confirmation or error message

##### 3.2.5 Update Booked Slots
- **Function:** Mark slot as unavailable
- **Input:** Booking details
- **Processing:**
  - Update `bookedSlots` map: `{venueName: {date: [slots]}}`
  - Add to `GlobalData.bookedGrounds` list
  - Store booking details: ground, date, slot, payment
- **Output:** Updated availability data
- **Side Effects:** Slot becomes unavailable for other users

**Data Store Interaction:**
- **Read:** 
  - Venues Database (venue details)
  - Bookings Database (existing bookings)
  - GlobalData (tournament bookings)
- **Write:**
  - Bookings Database (new booking record)
  - GlobalData.bookedGrounds (booking list)
  - bookedSlots map (slot availability)

**Business Rules:**
- Bookings must be made at least 1 day in advance
- Maximum 30 days advance booking
- One slot per booking (except full-day)
- Payment method required but not processed
- Slots are first-come-first-served
- Tournament bookings take precedence

**Error Handling:**
- Missing fields: Show warning snackbar
- Slot already booked: Refresh availability, show error
- Invalid date: Prevent selection in date picker

---

### 2.2 Player Module - Tournament Management

#### Overview
This diagram illustrates the tournament creation and management workflow.

#### Process 3.3: Tournament System

**Purpose:** Enable players to organize and manage sports tournaments.

**Sub-processes:**

##### 3.3.1 Tournament Creation
- **Function:** Collect tournament details
- **Input:** User-entered tournament information
- **Required Fields:**
  - Tournament Name (text)
  - Sport Type (Cricket, Football, Tennis, Basketball, Hockey, Volleyball)
  - Format (Round Robin, Knockout, Double Elimination)
  - Number of Teams (integer)
  - Start Date (date picker)
  - End Date (date picker)
- **Validation:**
  - All fields required
  - End date must be after start date
  - Team count must be valid for format (e.g., power of 2 for knockout)
- **Output:** Tournament object with unique ID
- **Storage:** GlobalData with tournament ID as key

##### 3.3.2 Ground Booking for Tournament
- **Function:** Reserve venues for tournament matches
- **Input:** Tournament details, venue selections
- **Processing:**
  - Display available venues
  - Allow multiple venue bookings
  - Select dates and time slots for each venue
  - Validate slot availability
  - Mark slots as tournament bookings
- **Output:** List of booked grounds with details
- **Storage:** 
  - `tournament['bookedGrounds']` array
  - `GlobalData.tournamentBookings` map
- **Conflict Prevention:** Tournament bookings block regular user bookings

##### 3.3.3 Fixture Generation
- **Function:** Automatically create match schedule
- **Input:** Tournament format, number of teams, dates
- **Processing:**
  - **Round Robin:**
    - Generate all possible team combinations
    - Each team plays every other team once
    - Calculate total matches: n(n-1)/2
  - **Knockout:**
    - Create bracket structure
    - Assign teams to initial matches
    - Generate subsequent rounds (QF, SF, Final)
    - Handle BYE for odd team counts
  - **Double Elimination:**
    - Create winners and losers brackets
    - Generate complex fixture tree
- **Output:** List of matches with:
  - Match ID
  - Team 1 vs Team 2
  - Date and Time
  - Venue/Ground
  - Match Type (regular, semi-final, final, grand final)
  - Status (scheduled)
- **Storage:** `GlobalData.tournamentMatches[tournamentId]`

**Fixture Generation Logic:**
- Distribute matches across booked grounds
- Assign time slots sequentially
- Ensure no team plays multiple matches simultaneously
- Calculate actual end date based on match count

##### 3.3.4 Match Management
- **Function:** Update match results and progress tournament
- **Input:** Match result (winner, scores, or abandoned)
- **Processing:**
  - Display match card with teams
  - Show "Update Result" button for scheduled matches
  - Open result dialog with options:
    - Enter scores (optional)
    - Select winner (Team 1, Team 2, Draw, Abandoned)
  - Update match status to "completed"
  - Store winner and result details
  - For knockout: Advance winner to next round
- **Output:** Updated match record
- **Side Effects:**
  - Points table updated (for round robin)
  - Next round matches populated (for knockout)
  - Tournament status updated

**Result Dialog Options:**
- **Score Entry:** Optional numeric input for each team
- **Winner Selection:** Radio buttons for Team 1, Team 2, Draw, Abandoned
- **Validation:** Winner must be selected (unless abandoned)

##### 3.3.5 Points Table
- **Function:** Calculate and display tournament standings
- **Input:** All match results
- **Processing:**
  - For each team, calculate:
    - Matches Played
    - Wins
    - Losses
    - Draws
    - Points (Win: 2, Draw: 1, Loss: 0)
  - Sort teams by points (descending)
  - Handle tie-breakers (if implemented)
- **Output:** Ranked list of teams with statistics
- **Display:** Table view with columns for each metric
- **Real-time:** Updates after each match result

**Data Store Interaction:**
- **Read:**
  - Tournament Database (tournament details)
  - Venues Database (available grounds)
  - Bookings Database (slot availability)
- **Write:**
  - Tournament Database (new tournament)
  - GlobalData.tournamentMatches (match fixtures)
  - GlobalData.tournamentBookings (ground reservations)

**Business Rules:**
- Tournament must have at least 2 teams
- Grounds must be booked before fixture generation
- Match results can only be updated by tournament creator
- Knockout tournaments require power-of-2 teams (or BYE)
- Round robin generates n(n-1)/2 matches
- Tournament bookings block regular bookings

---


### 2.3 Manager Module - Dashboard & Analytics

#### Overview
This diagram shows how managers view and analyze their business performance.

#### Process 4.1: Venue Management System

**Purpose:** Allow managers to add, edit, and manage their sports venues.

**Sub-processes:**

##### 4.1.1 Add New Venue
- **Function:** Register a new venue in the system
- **Input:** Venue details from manager
- **Required Fields:**
  - Venue Name (text)
  - Sport Category (Cricket, Football, Tennis, Basketball, Hockey, Volleyball)
  - Location/Address (text)
  - Pricing Information (numeric)
  - Venue Images (1-5 images required)
  - Facilities/Amenities (optional)
  - Operating Hours (optional)
- **Image Upload:**
  - Use ImagePicker to select from gallery
  - Support multiple image selection
  - Minimum 1 image, maximum 5 images
  - Images stored locally initially
  - Future: Upload to Firebase Storage
- **Validation:**
  - All required fields must be filled
  - At least 1 image must be uploaded
  - Pricing must be positive number
  - Location must be valid
- **Processing:**
  - Create venue object
  - Generate unique venue ID
  - Store venue data
  - Associate with manager's account
- **Output:** New venue added to system
- **Confirmation:** Success message with venue details

##### 4.1.2 Venue List Management
- **Function:** View and manage all venues owned by manager
- **Display:**
  - List of all manager's venues
  - Venue cards with image, name, category
  - Booking statistics per venue
  - Active/Inactive status
- **Actions:**
  - View venue details
  - Edit venue information
  - Delete venue (with confirmation)
  - Toggle venue availability
- **Filters:**
  - By sport category
  - By booking status
  - By revenue
- **Output:** Organized venue portfolio

**Data Store Interaction:**
- **Read:** Venues Database (existing venues)
- **Write:** Venues Database (new/updated venues)
- **Link:** Manager ID to venue ownership

**Business Rules:**
- Manager must provide business details during registration
- Minimum 1 image required per venue
- Venue name must be unique per manager
- Cannot delete venue with active bookings
- Pricing can be updated anytime

---

#### Process 4.2: Booking Management System

**Purpose:** Track and manage all venue bookings.

**Sub-processes:**

##### 4.2.1 View Today's Bookings
- **Function:** Display all bookings scheduled for current date
- **Input:** Current date, manager's venues
- **Processing:**
  - Filter bookings by date = today
  - Filter by manager's venues
  - Sort by time slot
- **Display:**
  - Booking cards with:
    - Venue name and image
    - Customer name (if available)
    - Time slot
    - Payment method
    - Booking status (Confirmed/Pending)
  - Empty state if no bookings
- **Actions:**
  - View booking details
  - Contact customer (future)
  - Mark as completed
- **Output:** List of today's bookings
- **Refresh:** Real-time updates (future with Firebase listeners)

##### 4.2.2 View Future Bookings
- **Function:** Display upcoming bookings
- **Input:** Date range (today onwards), manager's venues
- **Processing:**
  - Filter bookings by date > today
  - Group by date
  - Sort chronologically
- **Display:**
  - Calendar view or list view
  - Bookings grouped by date
  - Venue occupancy visualization
- **Output:** Future booking schedule
- **Planning:** Helps manager prepare for upcoming bookings

##### 4.2.3 Booking Status Management
- **Function:** Update booking status and handle cancellations
- **Input:** Booking ID, new status
- **Status Options:**
  - Pending → Confirmed
  - Confirmed → Completed
  - Any → Cancelled
- **Processing:**
  - Update booking record
  - If cancelled: Free up time slot
  - Send notification to customer (future)
  - Update revenue calculations
- **Output:** Updated booking status
- **Side Effects:**
  - Slot availability updated
  - Analytics recalculated
  - Customer notified

**Data Store Interaction:**
- **Read:** Bookings Database (all bookings for manager's venues)
- **Write:** Bookings Database (status updates)
- **Update:** Slot availability, revenue data

**Business Rules:**
- Only manager can view bookings for their venues
- Completed bookings cannot be cancelled
- Cancellations must be processed before booking date
- Revenue only counted for completed bookings

---

#### Process 4.3: Analytics System

**Purpose:** Provide business insights and performance metrics.

**Sub-processes:**

##### 4.3.1 Revenue Analytics
- **Function:** Track and visualize revenue trends
- **Input:** Booking data, time period selection
- **Time Periods:**
  - **Weekly:** Last 7 days (Mon-Sun)
  - **Monthly:** Last 12 months (Jan-Dec)
  - **Yearly:** Last 5 years
- **Processing:**
  - Aggregate revenue by time period
  - Calculate totals and averages
  - Generate data points for chart
  - Handle zero-revenue periods
- **Visualization:**
  - Line chart with gradient
  - X-axis: Time periods
  - Y-axis: Revenue in PKR (thousands)
  - Data points with values
  - Gradient fill under line
- **Metrics Displayed:**
  - Total Revenue (PKR)
  - Average per period
  - Growth percentage
  - Peak revenue period
- **Output:** Interactive revenue chart
- **Export:** Future feature to export data

**Chart Configuration:**
- **Weekly:** 7 data points (days)
- **Monthly:** 12 data points (months)
- **Yearly:** 5 data points (years)
- **Colors:** Primary gradient (cyan to blue)
- **Interactions:** Tap to see exact values

##### 4.3.2 Booking Statistics
- **Function:** Analyze booking patterns and trends
- **Input:** Booking data, time period
- **Metrics Calculated:**
  - **Total Bookings:** All-time count
  - **Active Bookings:** Confirmed future bookings
  - **Cancelled Bookings:** Cancellation count
  - **Completion Rate:** Completed / Total
  - **Cancellation Rate:** Cancelled / Total
- **Visualization:**
  - Bar chart for booking counts
  - Pie chart for status distribution (future)
  - Trend lines for patterns
- **Breakdown:**
  - By venue
  - By sport category
  - By time slot
  - By day of week
- **Output:** Comprehensive booking analytics
- **Insights:** Identify peak times, popular venues

##### 4.3.3 Performance Metrics
- **Function:** Evaluate overall business performance
- **Metrics:**
  - **Venue Utilization:** Booked slots / Available slots
  - **Average Booking Value:** Total revenue / Total bookings
  - **Customer Retention:** Repeat bookings (future)
  - **Peak Hours:** Most booked time slots
  - **Popular Venues:** Highest booking count
  - **Revenue per Venue:** Individual venue performance
- **Processing:**
  - Calculate percentages
  - Compare against targets (future)
  - Identify trends
- **Display:**
  - Quick stat cards
  - Progress indicators
  - Comparison charts
- **Output:** Performance dashboard
- **Actionable:** Helps optimize pricing and availability

**Data Store Interaction:**
- **Read:** 
  - Bookings Database (all booking records)
  - Venues Database (venue details)
  - Payment records (future)
- **Aggregate:** Calculate sums, averages, percentages
- **Cache:** Store calculated metrics for performance

**Business Rules:**
- Revenue only from completed bookings
- Cancelled bookings excluded from revenue
- Analytics updated in real-time (future)
- Historical data preserved for trends
- Minimum 1 booking required for meaningful analytics

**Chart Library:**
- **fl_chart:** Used for line and bar charts
- **Customization:** Colors match app theme
- **Responsive:** Adapts to screen size
- **Interactive:** Touch to view details

---


### 2.4 Authentication & Profile Management

#### Overview
This diagram details user authentication, registration, and profile management for both roles.

#### Process 1.1: User Registration System

**Purpose:** Create new user accounts with role-specific requirements.

**Player Registration Flow:**

##### Input Fields:
- **Full Name:** User's complete name (required)
- **Email:** Valid email address (required, unique)
- **Mobile Number:** 11-digit Pakistani mobile number (required)
- **Password:** Minimum 8 characters (required)

##### Validation Rules:
- **Email:**
  - Must contain '@' symbol
  - Must be valid email format
  - Must not already exist in system
- **Mobile:**
  - Exactly 11 digits
  - Numeric only
  - Format: 03XXXXXXXXX
- **Password:**
  - Minimum 8 characters
  - Should contain mix of letters and numbers (recommended)
- **Name:**
  - Cannot be empty
  - Minimum 2 characters

##### Processing Steps:
1. Validate all input fields
2. Check email uniqueness
3. Call `AuthService.signUpWithEmail()`
4. Create Firebase Auth account
5. Update user profile with display name
6. Show success message
7. Navigate to login screen

##### Error Handling:
- **Email already exists:** Show error "An account already exists with this email"
- **Weak password:** Show error "Password is too weak. Use at least 8 characters"
- **Invalid email:** Show error "Invalid email address"
- **Network error:** Show error "Network error. Check your connection"

**Manager Registration Flow:**

##### Additional Input Fields:
- **CNIC:** 13-digit national ID (required)
- **Venue Name:** Business/venue name (required)
- **Venue Location:** Address/location (required)
- **Venue Images:** 1-5 images (minimum 1 required)

##### Additional Validation:
- **CNIC:**
  - Exactly 13 digits
  - Numeric only
  - Unique identifier
- **Venue Name:**
  - Cannot be empty
  - Minimum 3 characters
- **Location:**
  - Cannot be empty
  - Should be descriptive
- **Images:**
  - Minimum 1 image required
  - Maximum 5 images allowed
  - Supported formats: JPG, PNG, WEBP

##### Image Upload Process:
1. User taps "Upload Images" button
2. System opens image picker (gallery)
3. User selects 1-5 images
4. Images displayed as thumbnails
5. User can add more (up to 5 total)
6. Images stored locally initially
7. Future: Upload to Firebase Storage

##### Processing Steps:
1. Validate all player fields
2. Validate manager-specific fields
3. Validate image count (≥1)
4. Create Firebase Auth account
5. Update profile with business details
6. Store venue information
7. Show success message
8. Navigate to manager login

**Data Store Interaction:**
- **Write:** Firebase Auth (user credentials)
- **Write:** User profile (display name, role)
- **Write:** Manager details (CNIC, venue info) - future Firestore
- **Write:** Local storage (images temporarily)

---

#### Process 1.2: User Login System

**Purpose:** Authenticate users and establish sessions.

##### Sub-processes:

**1.2.1 Email/Password Validation**
- **Input:** Email and password from login form
- **Client-side Validation:**
  - Email not empty
  - Email contains '@'
  - Password not empty
  - Password minimum 8 characters
- **Output:** Validated credentials or error message
- **Error Display:** Show validation errors below fields

**1.2.2 Firebase Authentication**
- **Input:** Validated credentials
- **Processing:**
  - Call `AuthService.signInWithEmail()`
  - Send credentials to Firebase Auth
  - Firebase verifies credentials
  - Firebase generates auth token
- **Output:** UserCredential object or error
- **Token:** JWT token for session management

**1.2.3 Session Creation**
- **Input:** Auth token from Firebase
- **Processing:**
  - Store auth token in memory
  - Set user as authenticated
  - Load user profile data
  - Determine user role
- **Output:** Active user session
- **Persistence:** Session maintained until logout

**1.2.4 Route to Dashboard**
- **Input:** User role (Player/Manager)
- **Processing:**
  - Check user role
  - Navigate to appropriate screen:
    - Player → `/UserMain`
    - Manager → `/ManagerHome`
  - Clear navigation stack
- **Output:** User at their dashboard
- **Navigation:** `pushReplacementNamed()` to prevent back navigation

##### Error Handling:
- **User not found:** "No account found with this email"
- **Wrong password:** "Incorrect password"
- **User disabled:** "This account has been disabled"
- **Too many attempts:** "Too many attempts. Please try again later"
- **Network error:** "Network error. Check your connection"

**Security Features:**
- Passwords never stored locally
- Auth tokens encrypted
- Session timeout (Firebase default)
- Secure HTTPS communication

---

#### Process 1.3: Password Management

**Purpose:** Handle password reset and change operations.

##### Sub-processes:

**1.3.1 Forgot Password**
- **Trigger:** User clicks "Forgot Password?" on login screen
- **Input:** Email address
- **Validation:**
  - Email field not empty
  - Valid email format
- **Processing:**
  1. User enters email
  2. System validates email
  3. Call `AuthService.sendPasswordResetEmail()`
  4. Firebase sends reset email
  5. Show success message
- **Email Content:**
  - Password reset link
  - Link expires in 1 hour
  - Instructions to reset
- **Output:** Confirmation message "Password reset email sent! Check your inbox"
- **Error:** "Failed to send reset email" if email not found

**1.3.2 Change Password**
- **Trigger:** User clicks "Change Password" in profile
- **Input:** Current password, new password, confirm password
- **Dialog Fields:**
  - Current Password (password field)
  - New Password (password field, min 8 chars)
  - Confirm New Password (password field)
- **Validation:**
  - Current password not empty
  - New password minimum 8 characters
  - New password matches confirmation
  - New password different from current
- **Processing:**
  1. User enters passwords
  2. System validates inputs
  3. Re-authenticate user with current password
  4. Call `user.updatePassword(newPassword)`
  5. Update password in Firebase
  6. Show success message
  7. Close dialog
- **Re-authentication:**
  - Required by Firebase for security
  - Uses `EmailAuthProvider.credential()`
  - Verifies current password
- **Output:** Password updated successfully
- **Errors:**
  - "Current password is incorrect"
  - "New password is too weak"
  - "Please sign in again to change password" (session expired)

**Security Measures:**
- Current password required for change
- Re-authentication prevents unauthorized changes
- Password strength validation
- Secure password transmission (HTTPS)
- No password storage in app

---

#### Process 3.5 / 4.5: Profile Management System

**Purpose:** Allow users to view and update their profile information.

##### Sub-processes:

**3.5.1 / 4.5.1 View Profile**
- **Display Elements:**
  - Profile picture (circular avatar)
  - User name (from Firebase displayName)
  - Email address (from Firebase email)
  - Role badge (Player/Manager)
- **Data Source:**
  - Firebase Auth (name, email)
  - SharedPreferences (profile picture path)
- **Loading:**
  - Load data on screen init
  - Show placeholder if no profile picture
- **Output:** User profile information displayed

**3.5.2 / 4.5.2 Update Profile Picture**
- **Trigger:** User taps camera icon on profile picture
- **Process:**
  1. Open image picker (gallery)
  2. User selects image
  3. Crop/resize image (optional)
  4. Save image to local storage
  5. Store path in SharedPreferences (per user UID)
  6. Update UI with new image
  7. Show success message
- **Storage:**
  - Key: `imagePath_{userUID}`
  - Value: Local file path
  - Per-user storage prevents conflicts
- **Future Enhancement:**
  - Upload to Firebase Storage
  - Generate thumbnail
  - Cloud sync across devices
- **Output:** Updated profile picture

**3.5.3 / 4.5.3 Change Password**
- **See Process 1.3.2 above**
- **Access:** Via profile screen button
- **Same flow for both Player and Manager**

**3.5.4 / 4.5.4 Logout**
- **Trigger:** User taps "Logout" button
- **Confirmation Dialog:**
  - Title: "Logout"
  - Message: "Are you sure you want to logout?"
  - Actions: Cancel, Logout
- **Process:**
  1. Show confirmation dialog
  2. User confirms logout
  3. Show loading indicator
  4. Call `AuthService.signOut()`
  5. Clear Firebase session
  6. Clear local state (GlobalData)
  7. Navigate to role selection screen
  8. Clear navigation stack
  9. Show success message
- **Cleanup:**
  - Clear auth token
  - Clear cached data
  - Reset app state
  - Preserve profile picture (local)
- **Navigation:** `pushNamedAndRemoveUntil('/', (route) => false)`
- **Output:** User logged out, returned to role selection

**Profile Options (Player):**
- Favorite Venues (navigate to favorites)
- Booking History (navigate to history)
- Change Password (open dialog)
- Logout (confirm and logout)

**Profile Options (Manager):**
- Venue Management (navigate to venues)
- Booking Management (navigate to bookings)
- Change Password (open dialog)
- Logout (confirm and logout)

**Data Store Interaction:**
- **Read:**
  - Firebase Auth (user data)
  - SharedPreferences (profile picture)
- **Write:**
  - SharedPreferences (profile picture path)
  - Firebase Auth (password updates)
- **Clear:**
  - Session data on logout
  - GlobalData on logout

---


### 2.5 Favorites & Booking History

#### Overview
This diagram shows how players manage their favorite venues and view booking history.

#### Process 3.4: Favorites System

**Purpose:** Allow players to save and quickly access their preferred venues.

##### Sub-processes:

**3.4.1 Add to Favorites**
- **Trigger:** User taps heart icon on venue card
- **Input:** Venue object (name, image, category)
- **Processing:**
  1. Check if venue already in favorites
  2. If not in favorites:
     - Add venue to `GlobalData.favouriteGrounds` list
     - Update heart icon to filled (red)
     - Show brief animation
  3. If already in favorites:
     - Remove from list (toggle off)
     - Update heart icon to outline (gray)
- **Storage:** In-memory list in GlobalData
- **Persistence:** Currently session-only (lost on app restart)
- **Future:** Store in Firebase Firestore per user
- **Output:** Updated favorites list
- **Visual Feedback:** Heart icon color change, optional snackbar

**3.4.2 View Favorites List**
- **Navigation:** From home screen quick action or profile
- **Display:**
  - Grid layout of favorite venues
  - Same card design as category view
  - Heart icon (filled, red)
  - Venue image, name, category
  - "Book Now" button
- **Empty State:**
  - Icon: Heart outline
  - Message: "No favorite venues yet"
  - Subtitle: "Add venues to favorites for quick access"
  - Action: "Browse Venues" button
- **Sorting:** Most recently added first
- **Count:** Display total favorites count
- **Output:** List of user's favorite venues

**3.4.3 Remove from Favorites**
- **Trigger:** User taps filled heart icon
- **Confirmation:** Optional "Remove from favorites?" dialog
- **Processing:**
  1. Remove venue from `GlobalData.favouriteGrounds`
  2. Update UI (remove card or update icon)
  3. Show confirmation message
- **Undo:** Optional undo action in snackbar (future)
- **Output:** Updated favorites list

**3.4.4 Book from Favorites**
- **Trigger:** User taps "Book Now" on favorite venue
- **Process:**
  1. Navigate to booking dialog
  2. Pre-fill venue information
  3. Follow standard booking flow (Process 3.2)
- **Advantage:** Quick access without browsing
- **Output:** Booking initiated for favorite venue

**Data Store Interaction:**
- **Read/Write:** GlobalData.favouriteGrounds (in-memory list)
- **Future:** Firebase Firestore (persistent storage)
- **Sync:** Real-time updates across app

**Business Rules:**
- No limit on favorites count
- Duplicates prevented automatically
- Favorites are user-specific
- Deleted venues removed from favorites
- Favorites persist during session only (current)

**UI/UX Features:**
- Heart icon animation on add/remove
- Haptic feedback on interaction
- Smooth transitions
- Quick access from multiple screens

---

#### Process 3.2.6: Booking History System

**Purpose:** Track and display user's past and upcoming bookings.

##### Sub-processes:

**3.2.6.1 View Past Bookings**
- **Navigation:** From profile or home screen
- **Data Source:** `GlobalData.bookedGrounds` list
- **Display:**
  - List view of all bookings
  - Sorted by date (most recent first)
  - Booking cards with:
    - Venue image (thumbnail)
    - Venue name
    - Date (YYYY-MM-DD format)
    - Time slot
    - Payment method
    - Status badge (Confirmed/Completed/Cancelled)
- **Filtering:**
  - All bookings (default)
  - Upcoming only (date ≥ today)
  - Past only (date < today)
  - By venue
  - By sport category
- **Empty State:**
  - Icon: Calendar with X
  - Message: "No booked venues yet 😢"
  - Action: "Browse Venues" button
- **Count:** Display total bookings count
- **Output:** Comprehensive booking history

**Booking Card Details:**
- **Header:** Venue name (bold)
- **Image:** Venue thumbnail (60x60)
- **Date:** "Date: YYYY-MM-DD"
- **Slot:** "Slot: 9am-10am"
- **Payment:** "Payment: JazzCash"
- **Actions:** Delete button (trash icon)

**3.2.6.2 Cancel Booking**
- **Trigger:** User taps delete/trash icon on booking card
- **Confirmation Dialog:**
  - Title: "Cancel Booking"
  - Message: "Are you sure you want to cancel this booking?"
  - Details: Show venue, date, time
  - Actions: No (default), Yes (destructive)
- **Processing:**
  1. User confirms cancellation
  2. Remove booking from `GlobalData.bookedGrounds`
  3. Free up time slot in `bookedSlots` map
  4. Update venue availability
  5. Remove from UI
  6. Show confirmation message
- **Slot Liberation:**
  - Remove slot from `bookedSlots[venueName][date]`
  - Slot becomes available for other users
  - Update availability in real-time
- **Refund:** Not implemented (future feature)
- **Notification:** Notify manager of cancellation (future)
- **Output:** Booking cancelled, slot freed

**Cancellation Rules:**
- Can cancel anytime before booking date
- Cannot cancel past bookings
- Cannot cancel completed bookings
- Cancellation is immediate (no approval needed)
- No cancellation fee (current implementation)

**Data Store Interaction:**
- **Read:** 
  - GlobalData.bookedGrounds (booking list)
  - bookedSlots map (slot availability)
- **Write:**
  - Remove from bookedGrounds
  - Update bookedSlots map
- **Future:** 
  - Update Firestore booking status
  - Trigger cancellation notification

**Business Rules:**
- Bookings stored per user session
- Cancellation frees slot immediately
- Past bookings cannot be cancelled
- Booking history preserved (even after cancellation)
- No limit on booking history size

**UI/UX Features:**
- Swipe to delete (optional)
- Confirmation before cancellation
- Undo cancellation (future)
- Export booking history (future)
- Share booking details (future)

**Status Badges:**
- **Confirmed:** Green badge, upcoming booking
- **Completed:** Blue badge, past booking
- **Cancelled:** Red badge, cancelled booking
- **Pending:** Orange badge, awaiting confirmation (future)

**Additional Features (Future):**
- Booking reminders (notifications)
- Add to calendar
- Share booking with friends
- Rate venue after completion
- Rebook same venue/slot
- Booking receipts/invoices

---


## Use Case Diagram Description

### Overview
The Use Case Diagram provides a comprehensive view of all functional requirements of the PlaySphere system, organized by actor (Player and Manager) and their interactions with the system.

---

### Actors

#### 1. Player User
**Description:** End users who want to book sports venues and participate in tournaments.

**Characteristics:**
- Primary users of the system
- Focus on venue discovery and booking
- Can create and manage tournaments
- Manage personal preferences (favorites)
- Track booking history

**Goals:**
- Find suitable sports venues
- Book venues quickly and easily
- Organize tournaments with friends
- Save favorite venues for quick access
- Track past and upcoming bookings

#### 2. Manager User
**Description:** Venue owners or managers who list and manage sports facilities.

**Characteristics:**
- Business users of the system
- Focus on venue management and analytics
- Monitor bookings and revenue
- Manage multiple venues
- Track business performance

**Goals:**
- List venues to attract customers
- Manage booking requests efficiently
- Track revenue and performance
- Optimize venue utilization
- Grow business through insights

#### 3. Firebase Backend (System Actor)
**Description:** External system providing authentication and data storage services.

**Services Provided:**
- User authentication (email/password)
- User profile storage
- Data persistence (Firestore)
- File storage (Storage)
- Real-time updates (future)

---

### Player Use Cases (UC1-UC16)

#### Authentication & Account Management

**UC1: Register as Player**
- **Description:** Create a new player account
- **Precondition:** User has not registered before
- **Actors:** New Player, Firebase Auth
- **Includes:** Email validation, password encryption
- **Extends:** None
- **Postcondition:** Player account created, user can login

**UC2: Login to System**
- **Description:** Authenticate and access player dashboard
- **Precondition:** User has registered account
- **Actors:** Player, Firebase Auth
- **Includes:** Credential validation, session creation
- **Extends:** UC14 (if first login, may update profile)
- **Postcondition:** User authenticated, navigated to dashboard

#### Venue Discovery & Booking

**UC3: Browse Venues by Category**
- **Description:** View venues filtered by sport type
- **Precondition:** User is logged in
- **Actors:** Player
- **Includes:** Category filtering, venue display
- **Extends:** UC5 (view details), UC9 (add to favorites)
- **Postcondition:** Venues displayed based on category

**UC4: Search Venues**
- **Description:** Find venues using text search
- **Precondition:** User is logged in
- **Actors:** Player
- **Includes:** Search algorithm, result filtering
- **Extends:** UC3 (browse results)
- **Postcondition:** Matching venues displayed

**UC5: View Venue Details**
- **Description:** See comprehensive information about a venue
- **Precondition:** Venue exists in system
- **Actors:** Player
- **Includes:** Image gallery, amenities, pricing, availability
- **Extends:** UC6 (book venue), UC9 (add to favorites)
- **Postcondition:** Venue details displayed

**UC6: Book Venue**
- **Description:** Reserve a venue for specific date and time
- **Precondition:** User is logged in, venue is available
- **Actors:** Player, Payment Gateway (future)
- **Sub-use cases:**
  - Select Date
  - Choose Time Slot
  - Select Payment Method
- **Includes:** Availability check, slot reservation
- **Extends:** UC7 (booking added to history)
- **Postcondition:** Venue booked, slot marked unavailable

**UC7: View Booking History**
- **Description:** See all past and upcoming bookings
- **Precondition:** User is logged in
- **Actors:** Player
- **Includes:** Booking list display, filtering
- **Extends:** UC8 (cancel booking)
- **Postcondition:** Booking history displayed

**UC8: Cancel Booking**
- **Description:** Cancel an existing booking
- **Precondition:** Booking exists, not yet completed
- **Actors:** Player
- **Includes:** Confirmation dialog, slot liberation
- **Extends:** UC7 (history updated)
- **Postcondition:** Booking cancelled, slot freed

#### Favorites Management

**UC9: Add Venue to Favorites**
- **Description:** Save a venue for quick access
- **Precondition:** User is logged in, venue exists
- **Actors:** Player
- **Includes:** Favorites list update
- **Extends:** UC11 (view favorites)
- **Postcondition:** Venue added to favorites

**UC10: Remove from Favorites**
- **Description:** Remove a venue from favorites list
- **Precondition:** Venue is in favorites
- **Actors:** Player
- **Includes:** Favorites list update
- **Extends:** UC11 (favorites updated)
- **Postcondition:** Venue removed from favorites

**UC11: View Favorites List**
- **Description:** See all saved favorite venues
- **Precondition:** User is logged in
- **Actors:** Player
- **Includes:** Favorites display
- **Extends:** UC6 (book from favorites), UC10 (remove)
- **Postcondition:** Favorites list displayed

#### Tournament Management

**UC12: Create Tournament**
- **Description:** Organize a sports tournament
- **Precondition:** User is logged in
- **Actors:** Player
- **Sub-use cases:**
  - Set Tournament Details (name, sport, format, teams, dates)
  - Book Grounds for Tournament (reserve venues)
  - Generate Fixtures (create match schedule)
- **Includes:** Fixture generation algorithm, ground booking
- **Extends:** UC13 (manage tournament)
- **Postcondition:** Tournament created with scheduled matches

**UC13: Manage Tournament**
- **Description:** Update and track tournament progress
- **Precondition:** Tournament exists, user is creator
- **Actors:** Player
- **Sub-use cases:**
  - Update Match Results (enter scores, winners)
  - View Points Table (standings)
  - View Match Schedule (fixtures)
- **Includes:** Points calculation, match status updates
- **Extends:** None
- **Postcondition:** Tournament data updated

#### Profile Management

**UC14: Update Profile**
- **Description:** Modify user profile information
- **Precondition:** User is logged in
- **Actors:** Player, Firebase Auth
- **Sub-use cases:**
  - Change Profile Picture (upload new image)
  - Change Password (update credentials)
- **Includes:** Image upload, password validation
- **Extends:** None
- **Postcondition:** Profile updated

**UC15: View Notifications**
- **Description:** See system notifications and alerts
- **Precondition:** User is logged in
- **Actors:** Player
- **Includes:** Notification list display
- **Extends:** None
- **Postcondition:** Notifications displayed
- **Note:** Currently placeholder, future implementation

**UC16: Logout**
- **Description:** End user session and exit
- **Precondition:** User is logged in
- **Actors:** Player, Firebase Auth
- **Includes:** Session termination, state cleanup
- **Extends:** None
- **Postcondition:** User logged out, returned to role selection

---

### Manager Use Cases (UC17-UC30)

#### Authentication & Account Management

**UC17: Register as Manager**
- **Description:** Create a new manager account with business details
- **Precondition:** User has not registered before
- **Actors:** New Manager, Firebase Auth
- **Sub-use cases:**
  - Provide Business Details (CNIC, venue info)
  - Upload Venue Images (1-5 images)
- **Includes:** Business validation, image upload
- **Extends:** None
- **Postcondition:** Manager account created with venue

**UC18: Login to System**
- **Description:** Authenticate and access manager dashboard
- **Precondition:** User has registered account
- **Actors:** Manager, Firebase Auth
- **Includes:** Credential validation, session creation
- **Extends:** UC26 (navigate to dashboard)
- **Postcondition:** User authenticated, at dashboard

#### Venue Management

**UC19: Add New Venue**
- **Description:** Register a new sports venue
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Sub-use cases:**
  - Enter Venue Details (name, category, location)
  - Upload Images (1-5 images)
  - Set Pricing (rates, packages)
- **Includes:** Venue validation, image storage
- **Extends:** UC20 (venue added to list)
- **Postcondition:** New venue added to system

**UC20: View Venue List**
- **Description:** See all venues owned by manager
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Includes:** Venue list display, statistics
- **Extends:** UC21 (edit), UC22 (delete)
- **Postcondition:** Venue list displayed

**UC21: Edit Venue Details**
- **Description:** Modify existing venue information
- **Precondition:** Venue exists, user is owner
- **Actors:** Manager
- **Includes:** Venue update, validation
- **Extends:** UC20 (list updated)
- **Postcondition:** Venue details updated

**UC22: Delete Venue**
- **Description:** Remove a venue from system
- **Precondition:** Venue exists, no active bookings
- **Actors:** Manager
- **Includes:** Confirmation dialog, cascade delete
- **Extends:** UC20 (list updated)
- **Postcondition:** Venue deleted

#### Booking Management

**UC23: View Today's Bookings**
- **Description:** See all bookings scheduled for today
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Includes:** Booking filter, display
- **Extends:** UC25 (manage status)
- **Postcondition:** Today's bookings displayed

**UC24: View Future Bookings**
- **Description:** See upcoming bookings
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Includes:** Date filtering, calendar view
- **Extends:** UC25 (manage status)
- **Postcondition:** Future bookings displayed

**UC25: Manage Booking Status**
- **Description:** Update booking status and handle cancellations
- **Precondition:** Booking exists for manager's venue
- **Actors:** Manager
- **Sub-use cases:**
  - Confirm Booking (approve reservation)
  - Cancel Booking (reject or cancel)
- **Includes:** Status update, notification (future)
- **Extends:** UC27 (analytics updated)
- **Postcondition:** Booking status updated

#### Dashboard & Analytics

**UC26: View Dashboard**
- **Description:** See overview of business performance
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Sub-use cases:**
  - Quick Stats (total venues, bookings, revenue)
  - Quick Actions (add venue, view bookings)
- **Includes:** Data aggregation, display
- **Extends:** UC27 (detailed analytics)
- **Postcondition:** Dashboard displayed

**UC27: View Analytics**
- **Description:** Analyze business performance and trends
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Sub-use cases:**
  - Revenue Trends (weekly/monthly/yearly charts)
  - Booking Statistics (counts, rates)
  - Performance Metrics (utilization, peak hours)
- **Includes:** Data aggregation, chart generation
- **Extends:** None
- **Postcondition:** Analytics displayed

**UC28: View Notifications**
- **Description:** See booking alerts and system notifications
- **Precondition:** User is logged in as manager
- **Actors:** Manager
- **Includes:** Notification list display
- **Extends:** None
- **Postcondition:** Notifications displayed
- **Note:** Currently placeholder, future implementation

#### Profile Management

**UC29: Update Profile**
- **Description:** Modify manager profile information
- **Precondition:** User is logged in as manager
- **Actors:** Manager, Firebase Auth
- **Sub-use cases:**
  - Change Profile Picture (upload new image)
  - Change Password (update credentials)
- **Includes:** Image upload, password validation
- **Extends:** None
- **Postcondition:** Profile updated

**UC30: Logout**
- **Description:** End manager session and exit
- **Precondition:** User is logged in as manager
- **Actors:** Manager, Firebase Auth
- **Includes:** Session termination, state cleanup
- **Extends:** None
- **Postcondition:** User logged out, returned to role selection

---

### Use Case Relationships

#### Include Relationships
- **UC6 (Book Venue)** includes:
  - Select Date
  - Choose Time Slot
  - Select Payment Method
- **UC12 (Create Tournament)** includes:
  - Set Tournament Details
  - Book Grounds
  - Generate Fixtures
- **UC27 (View Analytics)** includes:
  - Revenue Trends
  - Booking Statistics
  - Performance Metrics

#### Extend Relationships
- **UC3 (Browse Venues)** extends to:
  - UC5 (View Details)
  - UC9 (Add to Favorites)
- **UC6 (Book Venue)** extends to:
  - UC7 (Booking History)
- **UC11 (View Favorites)** extends to:
  - UC6 (Book Venue)
  - UC10 (Remove from Favorites)

#### Generalization
- **UC2 (Login)** and **UC18 (Login)** are similar but for different roles
- **UC14 (Update Profile)** and **UC29 (Update Profile)** share common functionality
- **UC16 (Logout)** and **UC30 (Logout)** are identical processes

---

### External System Interactions

#### Firebase Authentication
- **Used by:** UC1, UC2, UC14, UC16, UC17, UC18, UC29, UC30
- **Functions:**
  - User registration
  - Login/logout
  - Password management
  - Session management

#### Firebase Firestore (Future)
- **Used by:** All data-related use cases
- **Functions:**
  - Store user profiles
  - Store venue data
  - Store booking records
  - Store tournament data

#### Payment Gateways (Future)
- **Used by:** UC6 (Book Venue)
- **Gateways:** JazzCash, EasyPaisa
- **Functions:**
  - Process payments
  - Generate receipts
  - Handle refunds

---

### Use Case Priorities

#### High Priority (MVP)
- UC1, UC2: Registration and Login
- UC3, UC4, UC5: Venue Discovery
- UC6, UC7, UC8: Booking Management
- UC17, UC18: Manager Registration and Login
- UC19, UC20: Venue Management
- UC23, UC24, UC25: Booking Management (Manager)

#### Medium Priority
- UC9, UC10, UC11: Favorites
- UC12, UC13: Tournament Management
- UC26, UC27: Dashboard and Analytics
- UC14, UC29: Profile Management

#### Low Priority (Future Enhancements)
- UC15, UC28: Notifications
- UC21, UC22: Advanced Venue Management
- Payment integration
- Real-time updates

---

## Conclusion

This detailed description document provides comprehensive explanations of all diagrams in the PlaySphere system. Each diagram level reveals progressively more detail about system processes, data flows, and user interactions.

**Key Takeaways:**
- **Level 0 DFD:** System context and external interactions
- **Level 1 DFD:** Major subsystems and their relationships
- **Level 2 DFD:** Detailed process flows and business logic
- **Use Case Diagram:** Complete functional requirements organized by actor

These diagrams serve as:
- **Development Guide:** Clear specifications for implementation
- **Documentation:** System architecture and functionality reference
- **Communication Tool:** Shared understanding among stakeholders
- **Testing Blueprint:** Basis for test case creation

The PlaySphere system is designed with clear separation of concerns, role-based access control, and scalable architecture to support future enhancements.

