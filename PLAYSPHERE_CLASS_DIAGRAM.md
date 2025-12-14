# PlaySphere Application - Improved Class Diagram

## Overview
This document contains the comprehensive class diagram for the PlaySphere sports venue booking application with proper inheritance, separation of concerns, and clear relationships.

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
        REJECTED
    }

    class PaymentStatus {
        <<enumeration>>
        PENDING
        COMPLETED
        FAILED
        REFUNDED
    }

    class PaymentMethod {
        <<enumeration>>
        JAZZCASH
        EASYPAISA
        CREDIT_CARD
        DEBIT_CARD
    }

    class SlotStatus {
        <<enumeration>>
        AVAILABLE
        BOOKED
        BLOCKED
        MAINTENANCE
    }

    class NotificationType {
        <<enumeration>>
        BOOKING_CONFIRMED
        BOOKING_CANCELLED
        PAYMENT_SUCCESS
        PAYMENT_FAILED
        TOURNAMENT_INVITE
        VENUE_UPDATE
        SYSTEM_ALERT
    }

    class UserRole {
        <<enumeration>>
        PLAYER
        MANAGER
        ADMIN
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
        +register(userData: Map) bool
        +updateProfile(profileData: Map) bool
        +logout() void
        +resetPassword(email: String) bool
    }

    %% Player inherits from User
    class Player {
        +List~String~ favoriteVenueIds
        +List~String~ bookingHistory
        +double totalSpent
        +bookVenue(venue: Venue, slot: TimeSlot) Booking
        +cancelBooking(bookingId: String) bool
        +addToFavorites(venueId: String) void
        +removeFromFavorites(venueId: String) void
        +viewBookingHistory() List~Booking~
        +joinTournament(tournamentId: String) bool
    }

    %% Manager inherits from User
    class Manager {
        +String cnic
        +List~String~ venueIds
        +double totalRevenue
        +bool isVerified
        +addVenue(venue: Venue) bool
        +updateVenue(venueId: String, data: Map) bool
        +deleteVenue(venueId: String) bool
        +approveBooking(bookingId: String) bool
        +rejectBooking(bookingId: String, reason: String) bool
        +viewRevenue(period: String) Map
        +manageSlots(venueId: String, slots: List~TimeSlot~) bool
    }

    %% Venue Class
    class Venue {
        +String venueId
        +String managerId
        +String venueName
        +String location
        +String address
        +SportType sportType
        +double pricePerHour
        +bool isActive
        +calculateAvailability(date: DateTime) List~TimeSlot~
        +updatePricing(newPrice: double) bool
        +toggleStatus(isActive: bool) void
    }



    %% Time Slot Class
    class TimeSlot {
        +String slotId
        +String venueId
        +DateTime date
        +String startTime
        +String endTime
        +SlotStatus status
        +double price
        +isAvailable() bool
        +book() void
        +release() void
        +block(reason: String) void
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
        +calculatePrice(hours: int, pricePerHour: double) double
        +confirm() bool
        +cancel(reason: String) bool
        +complete() bool
        +getDetails() Map
    }

    %% Booking Helper Classes
    class BookingInvoice {
        +String invoiceId
        +String bookingId
        +double subtotal
        +double tax
        +double discount
        +double totalAmount
        +DateTime issuedDate
        +generatePDF() File
        +sendEmail(email: String) bool
    }

    class BookingStatusHistory {
        +String historyId
        +String bookingId
        +BookingStatus previousStatus
        +BookingStatus newStatus
        +DateTime changedAt
        +String changedBy
        +String reason
    }

    class BookingCancellation {
        +String cancellationId
        +String bookingId
        +String reason
        +DateTime cancelledAt
        +String cancelledBy
        +double refundAmount
        +bool isRefunded
    }

    %% Payment Class
    class Payment {
        +String paymentId
        +String bookingId
        +String playerId
        +double amount
        +PaymentMethod method
        +PaymentStatus status
        +String transactionId
        +DateTime paymentDate
        +process() bool
        +refund(amount: double) bool
        +verify() bool
        +getReceipt() Map
    }



    %% Tournament Class
    class Tournament {
        +String tournamentId
        +String organizerId
        +String name
        +String description
        +SportType sportType
        +DateTime startDate
        +DateTime endDate
        +int maxTeams
        +int currentTeams
        +double prizePool
        +String venueId
        +bool isActive
        +addTeam(teamId: String) bool
        +removeTeam(teamId: String) bool
        +updateSchedule(schedule: Map) bool
        +declareWinner(teamId: String) bool
        +cancel() bool
    }

    %% Notification Class
    class Notification {
        +String notificationId
        +String userId
        +NotificationType type
        +String title
        +String message
        +bool isRead
        +DateTime createdAt
        +Map metadata
        +markAsRead() void
        +delete() void
    }

    %% ========================================
    %% SERVICE LAYER
    %% ========================================
    
    class AuthService {
        -FirebaseAuth _auth
        +User currentUser
        +Stream~User~ authStateChanges
        +signUpWithEmail(email: String, password: String) Future~UserCredential~
        +signInWithEmail(email: String, password: String) Future~UserCredential~
        +signOut() Future~void~
        +sendPasswordResetEmail(email: String) Future~bool~
        +updateUserProfile(displayName: String, photoURL: String) Future~bool~
        +deleteAccount() Future~bool~
        +verifyEmail() Future~bool~
    }

    class BookingService {
        +createBooking(booking: Booking) Future~bool~
        +updateBookingStatus(bookingId: String, status: BookingStatus) Future~bool~
        +cancelBooking(bookingId: String, reason: String) Future~bool~
        +getBookingsByPlayer(playerId: String) Future~List~Booking~~
        +getBookingsByVenue(venueId: String) Future~List~Booking~~
        +checkAvailability(venueId: String, date: DateTime) Future~List~TimeSlot~~
    }

    class PaymentService {
        +processPayment(payment: Payment) Future~bool~
        +refundPayment(paymentId: String, amount: double) Future~bool~
        +verifyTransaction(transactionId: String) Future~bool~
        +getPaymentHistory(userId: String) Future~List~Payment~~
    }

    class VenueService {
        +addVenue(venue: Venue) Future~bool~
        +updateVenue(venueId: String, data: Map) Future~bool~
        +deleteVenue(venueId: String) Future~bool~
        +getVenueById(venueId: String) Future~Venue~
        +searchVenues(filters: Map) Future~List~Venue~~
        +getVenuesByManager(managerId: String) Future~List~Venue~~
    }

    class NotificationService {
        +sendNotification(notification: Notification) Future~bool~
        +getNotifications(userId: String) Future~List~Notification~~
        +markAsRead(notificationId: String) Future~bool~
        +deleteNotification(notificationId: String) Future~bool~
    }



    %% ========================================
    %% RELATIONSHIPS
    %% ========================================

    %% 1. INHERITANCE
    User <|-- Player
    User <|-- Manager

    %% 2. USER RELATIONSHIPS
    User --> UserRole
    Player "1" --> "0..*" Booking
    Player "1" --> "0..*" Payment
    Player "1" --> "0..*" Notification
    Player "1" --> "0..*" Venue
    Manager "1" --> "1..*" Venue
    Manager "1" --> "0..*" Notification

    %% 3. VENUE RELATIONSHIPS
    Venue --> SportType
    Venue "1" --> "0..*" TimeSlot
    Venue "1" --> "0..*" Booking
    TimeSlot --> SlotStatus

    %% 4. BOOKING RELATIONSHIPS
    Booking --> BookingStatus
    Booking "1" --> "1" TimeSlot
    Booking "1" --> "1" Payment
    Booking "1" --> "0..1" BookingInvoice
    Booking "1" --> "0..*" BookingStatusHistory
    Booking "1" --> "0..1" BookingCancellation

    %% 5. PAYMENT RELATIONSHIPS
    Payment --> PaymentStatus
    Payment --> PaymentMethod

    %% 6. TOURNAMENT RELATIONSHIPS
    Tournament --> SportType
    Tournament "1" --> "1" Venue
    Tournament "1" --> "1" Player
    Player "0..*" --> "0..*" Tournament

    %% 7. NOTIFICATION RELATIONSHIPS
    Notification --> NotificationType

    %% 8. SERVICE LAYER RELATIONSHIPS
    AuthService --> User
    VenueService --> Venue
    BookingService --> Booking
    BookingService --> TimeSlot
    PaymentService --> Payment
    NotificationService --> Notification
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
