# PlaySphere - Main Features Activity Diagrams

This document contains activity diagrams for all main features of the PlaySphere sports venue booking application using Mermaid syntax.

---

## Table of Contents
1. [User Authentication Flow](#1-user-authentication-flow)
2. [Player Registration Flow](#2-player-registration-flow)
3. [Manager Registration Flow](#3-manager-registration-flow)
4. [Venue Browsing and Search](#4-venue-browsing-and-search)
5. [Venue Booking Process](#5-venue-booking-process)
6. [Favorites Management](#6-favorites-management)
7. [Tournament Creation](#7-tournament-creation)
8. [Tournament Management](#8-tournament-management)
9. [Manager Dashboard Access](#9-manager-dashboard-access)
10. [Analytics and Reports](#10-analytics-and-reports)
11. [Profile Management](#11-profile-management)
12. [Password Reset Flow](#12-password-reset-flow)

---

## 1. User Authentication Flow

```mermaid
flowchart TD
    Start([User Opens App]) --> Splash[Display Splash Screen]
    Splash --> RoleSelect[Show Role Selection Screen]
    RoleSelect --> ChooseRole{Choose Role}
    ChooseRole -->|Player| PlayerLogin[Navigate to Player Login]
    ChooseRole -->|Manager| ManagerLogin[Navigate to Manager Login]
    
    PlayerLogin --> EnterCreds1[Enter Email & Password]
    ManagerLogin --> EnterCreds2[Enter Email & Password]
    
    EnterCreds1 --> ValidateP{Validate Input}
    EnterCreds2 --> ValidateM{Validate Input}
    
    ValidateP -->|Invalid| ShowErrorP[Show Error Message]
    ValidateM -->|Invalid| ShowErrorM[Show Error Message]
    ShowErrorP --> EnterCreds1
    ShowErrorM --> EnterCreds2
    
    ValidateP -->|Valid| AuthP[Firebase Authentication]
    ValidateM -->|Valid| AuthM[Firebase Authentication]
    
    AuthP --> CheckAuthP{Authentication Success?}
    AuthM --> CheckAuthM{Authentication Success?}
    
    CheckAuthP -->|No| ShowAuthErrorP[Show Auth Error]
    CheckAuthM -->|No| ShowAuthErrorM[Show Auth Error]
    ShowAuthErrorP --> EnterCreds1
    ShowAuthErrorM --> EnterCreds2
    
    CheckAuthP -->|Yes| PlayerDash[Navigate to Player Dashboard]
    CheckAuthM -->|Yes| ManagerDash[Navigate to Manager Dashboard]
    
    PlayerDash --> EndP([Player Home Screen])
    ManagerDash --> EndM([Manager Home Screen])
```

---

## 2. Player Registration Flow

```mermaid
flowchart TD
    Start([Click Sign Up]) --> ShowForm[Display Registration Form]
    ShowForm --> EnterDetails[Enter Full Name, Email, Mobile, Password]
    EnterDetails --> Validate{Validate All Fields}
    
    Validate -->|Invalid| ShowError[Show Validation Error]
    ShowError --> EnterDetails
    
    Validate -->|Valid| CheckPassword{Password >= 8 chars?}
    CheckPassword -->|No| ShowPassError[Show Password Error]
    ShowPassError --> EnterDetails
    
    CheckPassword -->|Yes| CheckEmail{Valid Email Format?}
    CheckEmail -->|No| ShowEmailError[Show Email Error]
    ShowEmailError --> EnterDetails
    
    CheckEmail -->|Yes| CreateAccount[Create Firebase Account]
    CreateAccount --> CheckCreation{Account Created?}
    
    CheckCreation -->|No| ShowCreationError[Show Error Message]
    ShowCreationError --> EnterDetails
    
    CheckCreation -->|Yes| ShowSuccess[Show Success Message]
    ShowSuccess --> NavigateLogin[Navigate to Login Screen]
    NavigateLogin --> End([Login Screen])
```

---

## 3. Manager Registration Flow

```mermaid
flowchart TD
    Start([Click Manager Sign Up]) --> ShowForm[Display Manager Registration Form]
    ShowForm --> EnterBasic[Enter Name, Email, Mobile, Password]
    EnterBasic --> EnterBusiness[Enter CNIC, Venue Name, Location]
    EnterBusiness --> UploadImages[Upload Venue Images 1-5]
    
    UploadImages --> Validate{Validate All Fields}
    Validate -->|Invalid| ShowError[Show Validation Error]
    ShowError --> EnterBasic
    
    Validate -->|Valid| CheckCNIC{CNIC = 13 digits?}
    CheckCNIC -->|No| ShowCNICError[Show CNIC Error]
    ShowCNICError --> EnterBusiness
    
    CheckCNIC -->|Yes| CheckImages{Images Uploaded?}
    CheckImages -->|No| ShowImageError[Show Image Error]
    ShowImageError --> UploadImages
    
    CheckImages -->|Yes| CreateAccount[Create Firebase Manager Account]
    CreateAccount --> StoreDetails[Store Business Details]
    StoreDetails --> CheckCreation{Account Created?}
    
    CheckCreation -->|No| ShowCreationError[Show Error Message]
    ShowCreationError --> EnterBasic
    
    CheckCreation -->|Yes| ShowSuccess[Show Success Message]
    ShowSuccess --> NavigateLogin[Navigate to Manager Login]
    NavigateLogin --> End([Manager Login Screen])
```

---

## 4. Venue Browsing and Search

```mermaid
flowchart TD
    Start([Player Dashboard]) --> ShowCategories[Display Sport Categories]
    ShowCategories --> Categories[Cricket, Football, Tennis, Basketball, Hockey, Volleyball, ALL]
    
    Categories --> UserAction{User Action}
    UserAction -->|Select Category| FilterVenues[Filter Venues by Category]
    UserAction -->|Enter Search| SearchVenues[Search by Venue Name]
    UserAction -->|View All| ShowAll[Display All Venues]
    
    FilterVenues --> DisplayResults[Display Filtered Venues in Grid]
    SearchVenues --> DisplayResults
    ShowAll --> DisplayResults
    
    DisplayResults --> CheckResults{Venues Found?}
    CheckResults -->|No| ShowEmpty[Show Empty State Message]
    CheckResults -->|Yes| ShowVenues[Show Venue Cards with Images]
    
    ShowVenues --> UserChoice{User Choice}
    UserChoice -->|Click Venue| ViewDetails[View Venue Details]
    UserChoice -->|Add to Favorites| AddFav[Add to Favorites List]
    UserChoice -->|Book Venue| StartBooking[Navigate to Booking Screen]
    
    ViewDetails --> BookingOption{Want to Book?}
    BookingOption -->|Yes| StartBooking
    BookingOption -->|No| ShowVenues
    
    AddFav --> UpdateFav[Update Favorites in GlobalData]
    UpdateFav --> ShowVenues
    
    ShowEmpty --> End([Return to Dashboard])
    StartBooking --> End2([Booking Screen])
```

---

## 5. Venue Booking Process

```mermaid
flowchart TD
    Start([Select Venue to Book]) --> ShowBookingDialog[Display Booking Dialog]
    ShowBookingDialog --> EnterVenueName[Enter Venue Name]
    EnterVenueName --> SelectDate[Select Booking Date]
    
    SelectDate --> ValidateDate{Date Valid?}
    ValidateDate -->|Past Date| ShowDateError[Show Date Error]
    ShowDateError --> SelectDate
    
    ValidateDate -->|Future Date| CheckAvailability[Check Slot Availability]
    CheckAvailability --> DisplaySlots[Display Available Time Slots]
    
    DisplaySlots --> CheckCategory{Venue Category?}
    CheckCategory -->|Cricket| ShowCricketSlots[Full Day, First Half, Second Half]
    CheckCategory -->|Other Sports| ShowRegularSlots[Morning, Afternoon, Evening, Night]
    
    ShowCricketSlots --> SelectSlot[User Selects Slot]
    ShowRegularSlots --> SelectSlot
    
    SelectSlot --> CheckSlotAvail{Slot Available?}
    CheckSlotAvail -->|Booked| ShowSlotError[Show Slot Unavailable]
    CheckSlotAvail -->|Tournament| ShowTournamentError[Show Tournament Conflict]
    ShowSlotError --> DisplaySlots
    ShowTournamentError --> DisplaySlots
    
    CheckSlotAvail -->|Available| SelectPayment[Select Payment Method]
    SelectPayment --> PaymentOptions[JazzCash, EasyPaisa, Bank Transfer, Cash]
    PaymentOptions --> ConfirmBooking{Confirm Booking?}
    
    ConfirmBooking -->|No| Cancel[Cancel Booking]
    Cancel --> End1([Return to Dashboard])
    
    ConfirmBooking -->|Yes| ProcessBooking[Process Booking]
    ProcessBooking --> UpdateGlobalData[Add to Booked Grounds]
    UpdateGlobalData --> UpdateSlots[Mark Slot as Booked]
    UpdateSlots --> ShowConfirmation[Show Booking Confirmation]
    ShowConfirmation --> End2([Booking Successful])
```

---

## 6. Favorites Management

```mermaid
flowchart TD
    Start([User Views Venue]) --> CheckFavStatus{Already in Favorites?}
    
    CheckFavStatus -->|No| ShowEmptyHeart[Display Empty Heart Icon]
    CheckFavStatus -->|Yes| ShowFilledHeart[Display Filled Red Heart]
    
    ShowEmptyHeart --> UserClickAdd{User Clicks Heart?}
    ShowFilledHeart --> UserClickRemove{User Clicks Heart?}
    
    UserClickAdd -->|Yes| AddToFav[Add Venue to Favorites]
    UserClickAdd -->|No| End1([Continue Browsing])
    
    UserClickRemove -->|Yes| RemoveFromFav[Remove from Favorites]
    UserClickRemove -->|No| End2([Continue Browsing])
    
    AddToFav --> UpdateGlobalData1[Update GlobalData.favouriteGrounds]
    RemoveFromFav --> UpdateGlobalData2[Update GlobalData.favouriteGrounds]
    
    UpdateGlobalData1 --> ChangeIcon1[Change to Filled Heart]
    UpdateGlobalData2 --> ChangeIcon2[Change to Empty Heart]
    
    ChangeIcon1 --> ShowSuccess1[Show Success Message]
    ChangeIcon2 --> ShowSuccess2[Show Removed Message]
    
    ShowSuccess1 --> End3([Venue Favorited])
    ShowSuccess2 --> End4([Venue Unfavorited])
    
    Start2([Navigate to Favorites Page]) --> LoadFavorites[Load Favorites from GlobalData]
    LoadFavorites --> CheckFavorites{Favorites Exist?}
    
    CheckFavorites -->|No| ShowEmptyState[Show Empty State]
    CheckFavorites -->|Yes| DisplayFavorites[Display Favorite Venues Grid]
    
    DisplayFavorites --> UserAction{User Action}
    UserAction -->|Click Venue| ViewVenue[View Venue Details]
    UserAction -->|Remove| RemoveFavorite[Remove from Favorites]
    UserAction -->|Book| BookVenue[Navigate to Booking]
    
    ShowEmptyState --> End5([Browse Venues])
    ViewVenue --> End6([Venue Details])
    RemoveFavorite --> LoadFavorites
    BookVenue --> End7([Booking Screen])
```

---

## 7. Tournament Creation

```mermaid
flowchart TD
    Start([Click Create Tournament]) --> ShowForm[Display Tournament Form]
    ShowForm --> EnterDetails[Enter Tournament Name]
    EnterDetails --> SelectSport[Select Sport Category]
    SelectSport --> SelectFormat[Select Tournament Format]
    
    SelectFormat --> FormatChoice{Format Type}
    FormatChoice -->|Round Robin| SetRR[Set Round Robin Parameters]
    FormatChoice -->|Knockout| SetKO[Set Knockout Parameters]
    FormatChoice -->|Double Elimination| SetDE[Set Double Elimination]
    
    SetRR --> EnterTeams[Enter Number of Teams]
    SetKO --> EnterTeams
    SetDE --> EnterTeams
    
    EnterTeams --> ValidateTeams{Teams >= 2?}
    ValidateTeams -->|No| ShowTeamError[Show Team Count Error]
    ShowTeamError --> EnterTeams
    
    ValidateTeams -->|Yes| EnterTeamNames[Enter Team Names]
    EnterTeamNames --> SelectDates[Select Start & End Dates]
    SelectDates --> ValidateDates{Dates Valid?}
    
    ValidateDates -->|No| ShowDateError[Show Date Error]
    ShowDateError --> SelectDates
    
    ValidateDates -->|Yes| BookGrounds[Book Grounds for Tournament]
    BookGrounds --> SelectVenue[Select Venue]
    SelectVenue --> SelectDate[Select Date]
    SelectDate --> SelectSlot[Select Time Slot]
    
    SelectSlot --> CheckAvailability{Slot Available?}
    CheckAvailability -->|No| ShowSlotError[Show Slot Unavailable]
    ShowSlotError --> SelectDate
    
    CheckAvailability -->|Yes| AddGround[Add Ground to Tournament]
    AddGround --> MoreGrounds{Book More Grounds?}
    
    MoreGrounds -->|Yes| SelectVenue
    MoreGrounds -->|No| GenerateFixtures[Generate Tournament Fixtures]
    
    GenerateFixtures --> CalculateMatches[Calculate Total Matches]
    CalculateMatches --> AssignVenues[Assign Venues to Matches]
    AssignVenues --> CreateSchedule[Create Match Schedule]
    CreateSchedule --> SaveTournament[Save Tournament Data]
    
    SaveTournament --> UpdateGlobalData[Update GlobalData.tournamentMatches]
    UpdateGlobalData --> ShowSuccess[Show Tournament Created]
    ShowSuccess --> End([Navigate to Tournament List])
```

---

## 8. Tournament Management

```mermaid
flowchart TD
    Start([View Tournament List]) --> LoadTournaments[Load Tournaments from GlobalData]
    LoadTournaments --> CheckTournaments{Tournaments Exist?}
    
    CheckTournaments -->|No| ShowEmpty[Show Empty State]
    CheckTournaments -->|Yes| DisplayList[Display Tournament Cards]
    
    DisplayList --> SelectTournament[User Selects Tournament]
    SelectTournament --> ShowDetails[Display Tournament Details]
    ShowDetails --> ShowFixtures[Display Match Fixtures]
    
    ShowFixtures --> UserAction{User Action}
    UserAction -->|View Match| ViewMatch[View Match Details]
    UserAction -->|Update Result| UpdateResult[Update Match Result]
    UserAction -->|View Standings| ViewStandings[View Points Table]
    
    ViewMatch --> ShowMatchInfo[Show Teams, Venue, Date, Time]
    ShowMatchInfo --> CheckStatus{Match Completed?}
    CheckStatus -->|No| AllowUpdate[Allow Result Update]
    CheckStatus -->|Yes| ShowResult[Show Final Result]
    
    AllowUpdate --> UpdateResult
    ShowResult --> End1([Return to Fixtures])
    
    UpdateResult --> EnterScores[Enter Team Scores]
    EnterScores --> SelectWinner[Select Winning Team]
    SelectWinner --> ValidateResult{Valid Result?}
    
    ValidateResult -->|No| ShowError[Show Validation Error]
    ShowError --> EnterScores
    
    ValidateResult -->|Yes| UpdatePoints[Calculate & Update Points]
    UpdatePoints --> UpdateMatchStatus[Mark Match as Completed]
    UpdateMatchStatus --> SaveResult[Save Result to GlobalData]
    SaveResult --> CheckNextRound{Knockout Format?}
    
    CheckNextRound -->|Yes| UpdateBracket[Update Tournament Bracket]
    CheckNextRound -->|No| UpdateTable[Update Points Table]
    
    UpdateBracket --> CheckComplete{Tournament Complete?}
    UpdateTable --> CheckComplete
    
    CheckComplete -->|Yes| DeclareWinner[Declare Tournament Winner]
    CheckComplete -->|No| ShowFixtures
    
    DeclareWinner --> End2([Tournament Completed])
    
    ViewStandings --> LoadStandings[Load Points Table]
    LoadStandings --> SortTeams[Sort Teams by Points]
    SortTeams --> DisplayTable[Display Standings Table]
    DisplayTable --> End3([Return to Tournament])
    
    ShowEmpty --> End4([Create New Tournament])
```

---

## 9. Manager Dashboard Access

```mermaid
flowchart TD
    Start([Manager Logs In]) --> LoadDashboard[Load Manager Dashboard]
    LoadDashboard --> FetchData[Fetch Booking & Revenue Data]
    FetchData --> CalculateStats[Calculate Quick Statistics]
    
    CalculateStats --> DisplayStats[Display Quick Stats Cards]
    DisplayStats --> ShowStats[Total Bookings, Revenue, Active Bookings, Cancelled]
    
    ShowStats --> NavigationChoice{Manager Navigation}
    
    NavigationChoice -->|View Bookings| ViewBookings[Navigate to Bookings List]
    NavigationChoice -->|View Analytics| ViewAnalytics[Navigate to Analytics]
    NavigationChoice -->|Manage Venues| ManageVenues[Navigate to Venue Management]
    NavigationChoice -->|View Profile| ViewProfile[Navigate to Profile]
    
    ViewBookings --> LoadBookings[Load All Bookings]
    LoadBookings --> FilterBookings{Filter Options}
    FilterBookings -->|All| ShowAll[Show All Bookings]
    FilterBookings -->|Active| ShowActive[Show Active Bookings]
    FilterBookings -->|Completed| ShowCompleted[Show Completed Bookings]
    FilterBookings -->|Cancelled| ShowCancelled[Show Cancelled Bookings]
    
    ShowAll --> DisplayBookingList[Display Booking Cards]
    ShowActive --> DisplayBookingList
    ShowCompleted --> DisplayBookingList
    ShowCancelled --> DisplayBookingList
    
    DisplayBookingList --> BookingAction{Manager Action}
    BookingAction -->|View Details| ShowBookingDetails[Show Booking Details]
    BookingAction -->|Update Status| UpdateStatus[Update Booking Status]
    BookingAction -->|Contact User| ContactUser[Show User Contact Info]
    
    ShowBookingDetails --> End1([Return to Bookings])
    UpdateStatus --> SaveStatus[Save Status Update]
    SaveStatus --> End2([Booking Updated])
    ContactUser --> End3([Return to Bookings])
    
    ManageVenues --> End4([Venue Management - Future])
    ViewProfile --> End5([Profile Screen])
    ViewAnalytics --> End6([Analytics Screen])
```

---

## 10. Analytics and Reports

```mermaid
flowchart TD
    Start([Manager Opens Analytics]) --> LoadAnalytics[Load Analytics Dashboard]
    LoadAnalytics --> SelectPeriod[Select Time Period]
    
    SelectPeriod --> PeriodChoice{Period Type}
    PeriodChoice -->|Weekly| FetchWeekly[Fetch Weekly Data]
    PeriodChoice -->|Monthly| FetchMonthly[Fetch Monthly Data]
    PeriodChoice -->|Yearly| FetchYearly[Fetch Yearly Data]
    
    FetchWeekly --> ProcessData[Process Booking Data]
    FetchMonthly --> ProcessData
    FetchYearly --> ProcessData
    
    ProcessData --> CalculateMetrics[Calculate Key Metrics]
    CalculateMetrics --> Metrics[Total Revenue, Bookings, Avg per Booking, Growth Rate]
    
    Metrics --> GenerateCharts[Generate Visualization Charts]
    GenerateCharts --> RevenueChart[Revenue Trend Line Chart]
    GenerateCharts --> BookingChart[Bookings Bar Chart]
    GenerateCharts --> CategoryChart[Category Distribution Pie Chart]
    
    RevenueChart --> DisplayDashboard[Display Analytics Dashboard]
    BookingChart --> DisplayDashboard
    CategoryChart --> DisplayDashboard
    
    DisplayDashboard --> ShowInsights[Show Key Insights]
    ShowInsights --> Insights[Peak Hours, Popular Venues, Revenue Trends]
    
    Insights --> ManagerAction{Manager Action}
    ManagerAction -->|Change Period| SelectPeriod
    ManagerAction -->|Export Report| ExportData[Export Analytics Report]
    ManagerAction -->|View Details| DrillDown[Drill Down into Specific Metric]
    ManagerAction -->|Return| End1([Return to Dashboard])
    
    ExportData --> GenerateReport[Generate PDF/CSV Report]
    GenerateReport --> DownloadReport[Download Report]
    DownloadReport --> End2([Report Downloaded])
    
    DrillDown --> ShowDetailedView[Show Detailed Breakdown]
    ShowDetailedView --> DetailedMetrics[Individual Booking Details, Trends]
    DetailedMetrics --> End3([Return to Analytics])
```

---

## 11. Profile Management

```mermaid
flowchart TD
    Start([User Opens Profile]) --> LoadProfile[Load User Profile Data]
    LoadProfile --> DisplayProfile[Display Profile Information]
    DisplayProfile --> ShowInfo[Name, Email, Mobile, Profile Picture]
    
    ShowInfo --> UserAction{User Action}
    UserAction -->|Edit Profile| EditMode[Enable Edit Mode]
    UserAction -->|Change Password| ChangePassword[Navigate to Change Password]
    UserAction -->|Update Picture| UpdatePicture[Update Profile Picture]
    UserAction -->|Logout| LogoutConfirm[Confirm Logout]
    
    EditMode --> EditFields[Edit Name, Mobile, Email]
    EditFields --> ValidateChanges{Validate Changes?}
    ValidateChanges -->|Invalid| ShowError[Show Validation Error]
    ShowError --> EditFields
    
    ValidateChanges -->|Valid| SaveChanges[Save Profile Changes]
    SaveChanges --> UpdateFirebase[Update Firebase Profile]
    UpdateFirebase --> ShowSuccess1[Show Success Message]
    ShowSuccess1 --> LoadProfile
    
    ChangePassword --> EnterOldPassword[Enter Current Password]
    EnterOldPassword --> EnterNewPassword[Enter New Password]
    EnterNewPassword --> ConfirmNewPassword[Confirm New Password]
    
    ConfirmNewPassword --> ValidatePassword{Passwords Match?}
    ValidatePassword -->|No| ShowPassError[Show Password Mismatch]
    ShowPassError --> EnterNewPassword
    
    ValidatePassword -->|Yes| CheckStrength{Password >= 8 chars?}
    CheckStrength -->|No| ShowStrengthError[Show Strength Error]
    ShowStrengthError --> EnterNewPassword
    
    CheckStrength -->|Yes| VerifyOldPassword[Verify Current Password]
    VerifyOldPassword --> CheckVerification{Verification Success?}
    
    CheckVerification -->|No| ShowVerifyError[Show Incorrect Password]
    ShowVerifyError --> EnterOldPassword
    
    CheckVerification -->|Yes| UpdatePassword[Update Password in Firebase]
    UpdatePassword --> ShowSuccess2[Show Password Changed]
    ShowSuccess2 --> End1([Return to Profile])
    
    UpdatePicture --> ChooseSource{Image Source}
    ChooseSource -->|Camera| OpenCamera[Open Camera]
    ChooseSource -->|Gallery| OpenGallery[Open Gallery]
    
    OpenCamera --> CaptureImage[Capture Photo]
    OpenGallery --> SelectImage[Select Photo]
    
    CaptureImage --> ValidateImage{Image Valid?}
    SelectImage --> ValidateImage
    
    ValidateImage -->|No| ShowImageError[Show Image Error]
    ShowImageError --> UpdatePicture
    
    ValidateImage -->|Yes| SaveImage[Save Image Locally]
    SaveImage --> UpdateSharedPrefs[Update SharedPreferences]
    UpdateSharedPrefs --> DisplayNewImage[Display New Profile Picture]
    DisplayNewImage --> End2([Profile Picture Updated])
    
    LogoutConfirm --> ConfirmDialog{Confirm Logout?}
    ConfirmDialog -->|No| DisplayProfile
    ConfirmDialog -->|Yes| ClearSession[Clear User Session]
    ClearSession --> SignOut[Sign Out from Firebase]
    SignOut --> NavigateRole[Navigate to Role Selection]
    NavigateRole --> End3([Logged Out])
```

---

## 12. Password Reset Flow

```mermaid
flowchart TD
    Start([Click Forgot Password]) --> ShowResetScreen[Display Password Reset Screen]
    ShowResetScreen --> EnterEmail[Enter Email Address]
    EnterEmail --> ValidateEmail{Valid Email Format?}
    
    ValidateEmail -->|No| ShowFormatError[Show Email Format Error]
    ShowFormatError --> EnterEmail
    
    ValidateEmail -->|Yes| CheckAccount{Email Exists in System?}
    CheckAccount -->|No| ShowNotFoundError[Show Account Not Found]
    ShowNotFoundError --> Options{User Choice}
    
    Options -->|Retry| EnterEmail
    Options -->|Sign Up| NavigateSignup[Navigate to Sign Up]
    NavigateSignup --> End1([Sign Up Screen])
    
    CheckAccount -->|Yes| SendResetEmail[Send Password Reset Email via Firebase]
    SendResetEmail --> CheckSent{Email Sent Successfully?}
    
    CheckSent -->|No| ShowSendError[Show Email Send Error]
    ShowSendError --> RetryOption{Retry?}
    RetryOption -->|Yes| SendResetEmail
    RetryOption -->|No| End2([Return to Login])
    
    CheckSent -->|Yes| ShowConfirmation[Show Confirmation Message]
    ShowConfirmation --> InstructUser[Instruct to Check Email]
    InstructUser --> WaitForUser[User Checks Email]
    
    WaitForUser --> UserAction{User Action}
    UserAction -->|Click Reset Link| OpenResetPage[Open Firebase Reset Page]
    UserAction -->|Ignore| End3([Email Expires in 1 Hour])
    
    OpenResetPage --> EnterNewPassword[Enter New Password]
    EnterNewPassword --> ConfirmPassword[Confirm New Password]
    ConfirmPassword --> ValidateNewPass{Passwords Match?}
    
    ValidateNewPass -->|No| ShowMismatch[Show Password Mismatch]
    ShowMismatch --> EnterNewPassword
    
    ValidateNewPass -->|Yes| CheckStrength{Password >= 8 chars?}
    CheckStrength -->|No| ShowWeakError[Show Weak Password Error]
    ShowWeakError --> EnterNewPassword
    
    CheckStrength -->|Yes| UpdatePassword[Update Password in Firebase]
    UpdatePassword --> CheckUpdate{Update Successful?}
    
    CheckUpdate -->|No| ShowUpdateError[Show Update Error]
    ShowUpdateError --> End4([Contact Support])
    
    CheckUpdate -->|Yes| ShowSuccess[Show Password Reset Success]
    ShowSuccess --> NavigateLogin[Navigate to Login Screen]
    NavigateLogin --> End5([Login with New Password])
```

---

## Additional Feature Flows

### 13. Booking History View

```mermaid
flowchart TD
    Start([Navigate to Booking History]) --> LoadHistory[Load Booking History from GlobalData]
    LoadHistory --> CheckHistory{Bookings Exist?}
    
    CheckHistory -->|No| ShowEmpty[Show Empty State Message]
    ShowEmpty --> Prompt[Prompt to Book Venues]
    Prompt --> End1([Navigate to Browse Venues])
    
    CheckHistory -->|Yes| DisplayBookings[Display Booking Cards]
    DisplayBookings --> ShowDetails[Venue, Date, Slot, Payment Method]
    
    ShowDetails --> UserAction{User Action}
    UserAction -->|View Details| ViewBooking[View Full Booking Details]
    UserAction -->|Book Again| RebookVenue[Navigate to Booking with Pre-filled Venue]
    UserAction -->|Filter| FilterBookings[Filter by Date/Status]
    
    ViewBooking --> ShowFullDetails[Show Complete Booking Information]
    ShowFullDetails --> End2([Return to History])
    
    RebookVenue --> End3([Booking Screen])
    
    FilterBookings --> ApplyFilter[Apply Filter Criteria]
    ApplyFilter --> DisplayBookings
```

### 14. Notification System (Future)

```mermaid
flowchart TD
    Start([System Event Occurs]) --> EventType{Event Type}
    
    EventType -->|Booking Confirmed| CreateBookingNotif[Create Booking Notification]
    EventType -->|Tournament Match| CreateMatchNotif[Create Match Reminder]
    EventType -->|Payment Due| CreatePaymentNotif[Create Payment Notification]
    EventType -->|Booking Cancelled| CreateCancelNotif[Create Cancellation Notification]
    
    CreateBookingNotif --> SendNotification[Send Push Notification]
    CreateMatchNotif --> SendNotification
    CreatePaymentNotif --> SendNotification
    CreateCancelNotif --> SendNotification
    
    SendNotification --> StoreNotif[Store in Notifications List]
    StoreNotif --> CheckUserOnline{User Online?}
    
    CheckUserOnline -->|Yes| ShowInApp[Show In-App Notification]
    CheckUserOnline -->|No| QueueNotif[Queue for Later Delivery]
    
    ShowInApp --> UserInteraction{User Clicks?}
    UserInteraction -->|Yes| NavigateToFeature[Navigate to Related Feature]
    UserInteraction -->|No| MarkAsReceived[Mark as Received]
    
    NavigateToFeature --> End1([Feature Screen])
    MarkAsReceived --> End2([Notification Stored])
    QueueNotif --> End3([Deliver When Online])
```

---

## System Overview Activity Diagram

```mermaid
flowchart TD
    Start([PlaySphere App Launch]) --> Initialize[Initialize App]
    Initialize --> CheckAuth{User Authenticated?}
    
    CheckAuth -->|No| ShowRoleSelection[Show Role Selection]
    CheckAuth -->|Yes| CheckRole{User Role?}
    
    ShowRoleSelection --> RoleChoice{Choose Role}
    RoleChoice -->|Player| PlayerAuth[Player Authentication Flow]
    RoleChoice -->|Manager| ManagerAuth[Manager Authentication Flow]
    
    PlayerAuth --> PlayerDashboard[Player Dashboard]
    ManagerAuth --> ManagerDashboard[Manager Dashboard]
    
    CheckRole -->|Player| PlayerDashboard
    CheckRole -->|Manager| ManagerDashboard
    
    PlayerDashboard --> PlayerFeatures{Player Features}
    PlayerFeatures -->|Browse Venues| BrowseFlow[Venue Browsing Flow]
    PlayerFeatures -->|Book Venue| BookingFlow[Booking Process Flow]
    PlayerFeatures -->|Create Tournament| TournamentFlow[Tournament Creation Flow]
    PlayerFeatures -->|Manage Favorites| FavoritesFlow[Favorites Management Flow]
    PlayerFeatures -->|View History| HistoryFlow[Booking History Flow]
    PlayerFeatures -->|Profile| ProfileFlow[Profile Management Flow]
    
    ManagerDashboard --> ManagerFeatures{Manager Features}
    ManagerFeatures -->|View Dashboard| DashboardFlow[Dashboard Overview Flow]
    ManagerFeatures -->|View Bookings| BookingsFlow[Bookings Management Flow]
    ManagerFeatures -->|Analytics| AnalyticsFlow[Analytics & Reports Flow]
    ManagerFeatures -->|Manage Venues| VenuesFlow[Venue Management Flow]
    ManagerFeatures -->|Profile| ProfileFlow
    
    BrowseFlow --> PlayerDashboard
    BookingFlow --> PlayerDashboard
    TournamentFlow --> PlayerDashboard
    FavoritesFlow --> PlayerDashboard
    HistoryFlow --> PlayerDashboard
    ProfileFlow --> End1([Logout/Continue])
    
    DashboardFlow --> ManagerDashboard
    BookingsFlow --> ManagerDashboard
    AnalyticsFlow --> ManagerDashboard
    VenuesFlow --> ManagerDashboard
```

---

## Notes

- All diagrams use Mermaid syntax and can be rendered in any Mermaid-compatible viewer
- Activity diagrams show the complete flow of each major feature
- Decision points are represented with diamond shapes
- Process steps are shown in rectangles
- Start/End points are shown in rounded rectangles
- Arrows indicate the flow direction and sequence

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2024  
**Application:** PlaySphere - Sports Venue Booking System
