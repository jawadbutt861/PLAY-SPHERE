# PlaySphere Application - Class Diagram

## Overview
This document contains the core class diagram for the PlaySphere sports venue booking application with essential entities and relationships.

---

## Mermaid Class Diagram

```mermaid
classDiagram
    %% ========================================
    %% ENUMERATIONS
    %% ========================================
    class BookingStatus {
        <<enumeration>>
        PENDING
        CONFIRMED
        CANCELLED
        COMPLETED
    }

    class PaymentMethod {
        <<enumeration>>
        JAZZCASH
        EASYPAISA
        CREDIT_CARD
    }

    class UserRole {
        <<enumeration>>
        PLAYER
        MANAGER
    }

    class SportType {
        <<enumeration>>
        CRICKET
        FOOTBALL
        TENNIS
        BASKETBALL
        HOCKEY
        VOLLEYBALL
    }

    %% ========================================
    %% CORE DOMAIN MODELS
    %% ========================================
    
    %% Base User Class
    class User {
        <<abstract>>
        +String userId
        +String fullName
        +String email
        +String phoneNumber
        +String profileImageUrl
        +UserRole role
        +DateTime createdAt
        +login(email: String, password: String) bool
        +updateProfile(profileData: Map) bool
        +logout() void
    }

    %% Player inherits from User
    class Player {
        +List~String~ favoriteVenueIds
        +List~String~ bookingHistory
        +bookVenue(venue: Venue, slot: TimeSlot) Booking
        +addToFavorites(venueId: String) void
        +viewBookingHistory() List~Booking~
        +createTournament(tournament: Tournament) bool
    }

    %% Manager inherits from User
    class Manager {
        +String cnic
        +List~String~ venueIds
        +double totalRevenue
        +addVenue(venue: Venue) bool
        +updateVenue(venueId: String, data: Map) bool
        +viewRevenue(period: String) Map
        +manageBookings() List~Booking~
    }

    %% Venue Class
    class Venue {
        +String venueId
        +String managerId
        +String venueName
        +String location
        +SportType sportType
        +double pricePerHour
        +bool isActive
        +List~String~ imageUrls
        +checkAvailability(date: DateTime) List~TimeSlot~
        +updatePricing(newPrice: double) bool
    }

    %% Time Slot Class
    class TimeSlot {
        +String slotId
        +String venueId
        +DateTime date
        +String startTime
        +String endTime
        +bool isAvailable
        +double price
        +book() void
        +release() void
    }

    %% Booking Class
    class Booking {
        +String bookingId
        +String playerId
        +String venueId
        +String slotId
        +DateTime bookingDate
        +BookingStatus status
        +double totalAmount
        +PaymentMethod paymentMethod
        +confirm() bool
        +cancel() bool
        +getDetails() Map
    }

    %% Tournament Class
    class Tournament {
        +String tournamentId
        +String organizerId
        +String name
        +SportType sportType
        +DateTime startDate
        +int maxTeams
        +int currentTeams
        +double entryFee
        +bool isActive
        +addTeam(teamId: String) bool
        +generateBracket() Map
        +updateResults(matchId: String, result: Map) bool
    }

    %% ========================================
    %% SERVICE LAYER
    %% ========================================
    
    class AuthService {
        +User currentUser
        +signUpWithEmail(email: String, password: String) Future~bool~
        +signInWithEmail(email: String, password: String) Future~bool~
        +signOut() Future~void~
        +resetPassword(email: String) Future~bool~
    }

    class BookingService {
        +createBooking(booking: Booking) Future~bool~
        +cancelBooking(bookingId: String) Future~bool~
        +getBookingsByPlayer(playerId: String) Future~List~Booking~~
        +checkAvailability(venueId: String, date: DateTime) Future~List~TimeSlot~~
    }

    class VenueService {
        +addVenue(venue: Venue) Future~bool~
        +getVenuesByCategory(sportType: SportType) Future~List~Venue~~
        +searchVenues(query: String) Future~List~Venue~~
        +getVenuesByManager(managerId: String) Future~List~Venue~~
    }

    class TournamentService {
        +createTournament(tournament: Tournament) Future~bool~
        +getTournamentsByPlayer(playerId: String) Future~List~Tournament~~
        +updateTournamentResults(tournamentId: String, results: Map) Future~bool~
    }

    %% ========================================
    %% RELATIONSHIPS
    %% ========================================

    %% 1. INHERITANCE
    User <|-- Player
    User <|-- Manager

    %% 2. CORE RELATIONSHIPS
    User --> UserRole
    Player "1" --> "0..*" Booking
    Player "1" --> "0..*" Tournament
    Manager "1" --> "1..*" Venue
    
    Venue --> SportType
    Venue "1" --> "0..*" TimeSlot
    Venue "1" --> "0..*" Booking
    
    Booking --> BookingStatus
    Booking --> PaymentMethod
    Booking "1" --> "1" TimeSlot
    
    Tournament --> SportType
    Tournament "1" --> "1" Player

    %% 3. SERVICE RELATIONSHIPS
    AuthService --> User
    VenueService --> Venue
    BookingService --> Booking
    BookingService --> TimeSlot
    TournamentService --> Tournament
```

---

## Main Features

### 1. User Management
- **Player**: Books venues, joins tournaments
- **Manager**: Manages venues, approves bookings

### 2. Venue Booking
- Browse available venues by sport type
- Check time slot availability
- Book and pay for venue slots
- Cancel bookings with refunds

### 3. Payment Processing
- Multiple payment methods (JazzCash, EasyPaisa)
- Secure transaction processing
- Automatic invoice generation
- Refund handling

### 4. Tournament Management
- Players organize tournaments
- Team registration and management
- Tournament scheduling at venues
- Prize pool management

### 5. Notifications
- Booking confirmations
- Payment status updates
- Tournament invitations
- Venue updates

---

*PlaySphere - Sports Venue Booking Platform*
