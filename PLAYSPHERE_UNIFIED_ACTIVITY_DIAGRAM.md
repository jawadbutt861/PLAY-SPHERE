# PlaySphere - Main Features Activity Diagram

This document contains a simplified activity diagram showing the main features of the PlaySphere sports venue booking application.

---

## Main Features Activity Diagram

```mermaid
flowchart TD
    Start([Launch PlaySphere]) --> RoleSelect{Select Role}
    
    RoleSelect -->|Player| PlayerAuth[Player Authentication]
    RoleSelect -->|Manager| ManagerAuth[Manager Authentication]
    
    PlayerAuth --> PlayerHome[Player Dashboard]
    ManagerAuth --> ManagerHome[Manager Dashboard]
    
    %% Player Main Features
    PlayerHome --> PFeatures{Player Features}
    
    PFeatures -->|Browse & Search| BrowseVenues[Browse Venues by Category]
    BrowseVenues --> PlayerHome
    
    PFeatures -->|Book Venue| BookingProcess[Venue Booking Process]
    BookingProcess --> SelectVenue[Select Venue & Date]
    SelectVenue --> ChooseSlot[Choose Time Slot]
    ChooseSlot --> Payment[Select Payment Method]
    Payment --> ConfirmBooking[Confirm Booking]
    ConfirmBooking --> PlayerHome
    
    PFeatures -->|Favorites| ManageFavorites[Manage Favorite Venues]
    ManageFavorites --> PlayerHome
    
    PFeatures -->|Create Tournament| CreateTournament[Create Tournament]
    CreateTournament --> TournamentSetup[Setup Teams & Format]
    TournamentSetup --> BookGrounds[Book Tournament Grounds]
    BookGrounds --> GenerateFixtures[Generate Match Fixtures]
    GenerateFixtures --> PlayerHome
    
    PFeatures -->|Manage Tournaments| ManageTournaments[Manage Tournaments]
    ManageTournaments --> UpdateMatches[Update Match Results]
    UpdateMatches --> ViewStandings[View Points Table]
    ViewStandings --> PlayerHome
    
    PFeatures -->|Booking History| ViewHistory[View Booking History]
    ViewHistory --> PlayerHome
    
    PFeatures -->|Profile| PlayerProfile[Manage Profile]
    PlayerProfile --> PlayerHome
    
    PFeatures -->|Logout| Logout1[Logout]
    Logout1 --> RoleSelect
    
    %% Manager Main Features
    ManagerHome --> MFeatures{Manager Features}
    
    MFeatures -->|Dashboard| ViewDashboard[View Dashboard Stats]
    ViewDashboard --> QuickStats[Total Bookings, Revenue, Active, Cancelled]
    QuickStats --> ManagerHome
    
    MFeatures -->|View Bookings| ManageBookings[Manage All Bookings]
    ManageBookings --> FilterBookings[Filter by Status]
    FilterBookings --> ManagerHome
    
    MFeatures -->|Analytics| ViewAnalytics[View Analytics & Reports]
    ViewAnalytics --> SelectPeriod[Select Time Period]
    SelectPeriod --> ViewCharts[View Revenue & Booking Charts]
    ViewCharts --> ManagerHome
    
    MFeatures -->|Profile| ManagerProfile[Manage Profile]
    ManagerProfile --> ManagerHome
    
    MFeatures -->|Logout| Logout2[Logout]
    Logout2 --> RoleSelect
    
    style Start fill:#4CAF50
    style PlayerHome fill:#2196F3
    style ManagerHome fill:#FF9800
    style ConfirmBooking fill:#4CAF50
    style GenerateFixtures fill:#4CAF50
```

---

## Main Features Summary

### Player Features
1. **Authentication** - Login/Signup
2. **Browse Venues** - Search and filter by sport category
3. **Venue Booking** - Select venue, date, time slot, and payment method
4. **Favorites** - Save and manage favorite venues
5. **Create Tournament** - Setup teams, format, and book grounds
6. **Manage Tournaments** - Update match results and view standings
7. **Booking History** - View past bookings
8. **Profile Management** - Edit profile and logout

### Manager Features
1. **Authentication** - Login/Signup
2. **Dashboard** - View quick statistics (bookings, revenue)
3. **Manage Bookings** - View and filter all bookings
4. **Analytics** - View charts and reports for different time periods
5. **Profile Management** - Edit profile and logout

### Color Coding
- **Green**: Success states and start point
- **Blue**: Player dashboard
- **Orange**: Manager dashboard

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2024  
**Application:** PlaySphere - Sports Venue Booking System
