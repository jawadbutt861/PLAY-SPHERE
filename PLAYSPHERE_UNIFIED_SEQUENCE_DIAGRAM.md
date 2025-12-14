# PlaySphere - Main Features Sequence Diagram

This document contains a single sequence diagram showing the core main features of the PlaySphere sports venue booking application.

---

## Main Features Flow - Unified Sequence Diagram

```mermaid
sequenceDiagram
    actor User
    participant UI as User Interface
    participant Auth as Auth Service
    participant Firebase as Firebase
    participant BookingService as Booking Service
    participant TournamentService as Tournament Service
    participant AnalyticsService as Analytics Service
    participant GlobalData as Data Store

    Note over User,GlobalData: 1. AUTHENTICATION
    User->>UI: Launch App & Select Role
    User->>UI: Enter Email & Password
    UI->>Auth: login(email, password)
    Auth->>Firebase: signInWithEmailAndPassword()
    Firebase-->>Auth: User Credentials
    Auth-->>UI: Login Success
    UI->>User: Show Dashboard
    
    Note over User,GlobalData: 2. VENUE BOOKING (Player)
    User->>UI: Browse & Select Venue
    UI->>GlobalData: Load Venues
    GlobalData-->>UI: Venue List
    User->>UI: Enter Date & Select Slot
    UI->>BookingService: validateBooking(venue, date, slot)
    BookingService->>GlobalData: checkSlotAvailability()
    
    alt Slot Available
        GlobalData-->>BookingService: Available
        User->>UI: Select Payment & Confirm
        UI->>BookingService: createBooking()
        BookingService->>GlobalData: Save Booking
        GlobalData-->>UI: Booking Confirmed
        UI->>User: Show Success
    else Slot Unavailable
        GlobalData-->>BookingService: Unavailable
        UI->>User: Show Error
    end
    
    Note over User,GlobalData: 3. TOURNAMENT CREATION (Player)
    User->>UI: Create Tournament
    User->>UI: Enter Name, Sport, Format, Teams
    User->>UI: Book Grounds
    UI->>BookingService: Book Multiple Grounds
    BookingService->>GlobalData: Save Tournament Bookings
    User->>UI: Generate Fixtures
    UI->>TournamentService: generateFixtures(format, teams)
    
    alt Round Robin
        TournamentService->>TournamentService: Generate All Pairings
    else Knockout
        TournamentService->>TournamentService: Create Bracket
    end
    
    TournamentService->>GlobalData: Save Tournament
    GlobalData-->>UI: Tournament Created
    UI->>User: Show Fixtures
    
    Note over User,GlobalData: 4. MATCH MANAGEMENT (Player)
    User->>UI: Select Match
    User->>UI: Enter Scores & Winner
    UI->>TournamentService: updateMatchResult()
    TournamentService->>TournamentService: Calculate Points
    TournamentService->>GlobalData: Update Match & Standings
    GlobalData-->>UI: Updated
    UI->>User: Show Updated Standings
    
    Note over User,GlobalData: 5. MANAGER ANALYTICS
    User->>UI: View Analytics
    User->>UI: Select Period
    UI->>AnalyticsService: fetchAnalytics(period)
    AnalyticsService->>GlobalData: Get Bookings Data
    GlobalData-->>AnalyticsService: Bookings
    AnalyticsService->>AnalyticsService: Calculate Stats & Charts
    AnalyticsService-->>UI: Analytics Data
    UI->>User: Display Charts & Metrics
```

---

## Main Features Overview

### 1. Authentication
- User login with email/password
- Firebase authentication
- Role-based access (Player/Manager)

### 2. Venue Booking
- Browse venues by category
- Select date and time slot
- Real-time availability checking
- Payment method selection
- Booking confirmation

### 3. Tournament Creation
- Enter tournament details (name, sport, format, teams)
- Book multiple grounds for tournament
- Automatic fixture generation
- Support for Round Robin and Knockout formats

### 4. Match Management
- View tournament fixtures
- Update match results
- Automatic points calculation
- Real-time standings update

### 5. Manager Analytics
- View booking statistics
- Revenue tracking
- Time period filtering (Weekly/Monthly/Yearly)
- Visual charts and metrics

---

## Components

- **User**: Player or Manager
- **UI**: User Interface Layer
- **Auth Service**: Authentication handling
- **Firebase**: Backend authentication
- **Booking Service**: Venue booking logic
- **Tournament Service**: Tournament & fixture management
- **Analytics Service**: Data analysis & reporting
- **GlobalData**: In-memory data storage

---

**Document Version:** 1.0  
**Last Updated:** December 4, 2024  
**Application:** PlaySphere - Sports Venue Booking System
