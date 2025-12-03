# PlaySphere - Entity Relationship Diagrams

## Table of Contents
1. [Overview](#overview)
2. [Current Implementation ER Diagram](#current-implementation-er-diagram)
3. [Future Firebase Implementation ER Diagram](#future-firebase-implementation-er-diagram)
4. [Detailed Entity Descriptions](#detailed-entity-descriptions)
5. [Relationship Descriptions](#relationship-descriptions)
6. [Data Flow Relationships](#data-flow-relationships)

---

## Overview

PlaySphere uses a hybrid data storage approach:
- **Current Implementation:** In-memory storage (GlobalData) + Local storage (SharedPreferences)
- **Future Implementation:** Firebase Firestore + Local caching

This document presents both the current and future database designs.

---

## Current Implementation ER Diagram

```
                    PLAYSPHERE CURRENT DATA MODEL
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                          FIREBASE AUTH                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        User (Firebase)                             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ uid (PK)                    : String                        │   │   │
│  │  │ email                       : String (Unique)               │   │   │
│  │  │ displayName                 : String                        │   │   │
│  │  │ photoURL                    : String (Optional)             │   │   │
│  │  │ emailVerified               : Boolean                       │   │   │
│  │  │ creationTime                : DateTime                      │   │   │
│  │  │ lastSignInTime              : DateTime                      │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Authentication
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GLOBAL DATA (In-Memory)                           │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      FavouriteGrounds                               │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ List<Map<String, dynamic>>                              │   │   │
│  │  │ ├─ image          : AssetImage                              │   │   │
│  │  │ ├─ category       : String                                  │   │   │
│  │  │ └─ name           : String                                  │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       BookedGrounds                                 │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ List<Map<String, dynamic>>                              │   │   │
│  │  │ ├─ ground         : Map<String, dynamic>                    │   │   │
│  │  │ │  ├─ image       : AssetImage                              │   │   │
│  │  │ │  ├─ category    : String                                  │   │   │
│  │  │ │  └─ name        : String                                  │   │   │
│  │  │ ├─ date           : String (YYYY-MM-DD)                     │   │   │
│  │  │ ├─ slot           : String                                  │   │   │
│  │  │ └─ payment        : String                                  │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Tournaments                                  │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ List<Map<String, dynamic>>                              │   │   │
│  │  │ ├─ id             : String                                  │   │   │
│  │  │ ├─ name           : String                                  │   │   │
│  │  │ ├─ sport          : String                                  │   │   │
│  │  │ ├─ format         : String                                  │   │   │
│  │  │ ├─ teams          : int                                     │   │   │
│  │  │ ├─ startDate      : String                                  │   │   │
│  │  │ ├─ endDate        : String                                  │   │   │
│  │  │ ├─ teamNames      : List<String>                            │   │   │
│  │  │ ├─ bookedGrounds  : List<Map<String, dynamic>>             │   │   │
│  │  │ └─ createdAt      : String                                  │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                  TournamentBookedSlots                              │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Map<String, Map<String, List<String>>>                     │   │   │
│  │  │ groundName -> date -> slots[]                               │   │   │
│  │  │ Example:                                                    │   │   │
│  │  │ {                                                           │   │   │
│  │  │   "Buitems Cricket Ground": {                               │   │   │
│  │  │     "2024-12-01": ["9am to 2pm", "2pm to 6pm"],           │   │   │
│  │  │     "2024-12-02": ["Full-day"]                             │   │   │
│  │  │   }                                                         │   │   │
│  │  │ }                                                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    TournamentMatches                                │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Map<String, List<Map<String, dynamic>>>                    │   │   │
│  │  │ tournamentId -> matches[]                                   │   │   │
│  │  │ Match Structure:                                            │   │   │
│  │  │ ├─ matchId        : String                                  │   │   │
│  │  │ ├─ team1          : String                                  │   │   │
│  │  │ ├─ team2          : String                                  │   │   │
│  │  │ ├─ status         : String (scheduled/completed)           │   │   │
│  │  │ ├─ result         : String (win/draw/abandoned)             │   │   │
│  │  │ ├─ winner         : String (Optional)                      │   │   │
│  │  │ ├─ team1Score     : int (Optional)                         │   │   │
│  │  │ ├─ team2Score     : int (Optional)                         │   │   │
│  │  │ ├─ ground         : String                                  │   │   │
│  │  │ ├─ date           : String                                  │   │   │
│  │  │ ├─ slot           : String                                  │   │   │
│  │  │ └─ completedAt    : String (Optional)                      │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    TournamentPoints                                 │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Map<String, Map<String, int>>                              │   │   │
│  │  │ tournamentId -> teamName -> points                          │   │   │
│  │  │ Example:                                                    │   │   │
│  │  │ {                                                           │   │   │
│  │  │   "tournament_123": {                                       │   │   │
│  │  │     "Team A": 6,                                            │   │   │
│  │  │     "Team B": 3,                                            │   │   │
│  │  │     "Team C": 1                                             │   │   │
│  │  │   }                                                         │   │   │
│  │  │ }                                                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Local Storage
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SHARED PREFERENCES (Local)                           │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      ProfileImages                                  │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Key-Value Pairs:                                            │   │   │
│  │  │ ├─ Key: "imagePath_{userUID}"                               │   │   │
│  │  │ └─ Value: String (Local file path)                          │   │   │
│  │  │                                                             │   │   │
│  │  │ Example:                                                    │   │   │
│  │  │ "imagePath_abc123": "/storage/profile_pic.jpg"             │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Future Firebase Implementation ER Diagram

```
                    PLAYSPHERE FUTURE FIREBASE DATA MODEL
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FIREBASE FIRESTORE                             │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                           Users Collection                          │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: uid (String)                               │   │   │
│  │  │ ├─ email              : String (Unique, Indexed)            │   │   │
│  │  │ ├─ displayName        : String                              │   │   │
│  │  │ ├─ role               : String (player/manager)             │   │   │
│  │  │ ├─ profileImageURL    : String (Optional)                   │   │   │
│  │  │ ├─ phoneNumber        : String (Optional)                   │   │   │
│  │  │ ├─ isActive           : Boolean (Default: true)             │   │   │
│  │  │ ├─ lastLoginAt        : Timestamp                           │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ └─ updatedAt          : Timestamp                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 1:N (User owns venues)                 │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                          Venues Collection                          │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: venueId (Auto-generated)                      │   │   │
│  │  │ ├─ managerId          : String (FK -> Users.uid)            │   │   │
│  │  │ ├─ name               : String (Indexed)                    │   │   │
│  │  │ ├─ category           : String (Indexed)                    │   │   │
│  │  │ │  (Cricket/Football/Tennis/Basketball/Hockey/Volleyball)  │   │   │
│  │  │ ├─ location           : GeoPoint                            │   │   │
│  │  │ ├─ address            : String                              │   │   │
│  │  │ ├─ description        : String (Optional)                   │   │   │
│  │  │ ├─ images             : Array<String> (URLs, Max 5)         │   │   │
│  │  │ ├─ pricing            : Map<String, Number>                 │   │   │
│  │  │ │  ├─ hourly          : Number                              │   │   │
│  │  │ │  ├─ halfDay         : Number (Cricket only)               │   │   │
│  │  │ │  └─ fullDay         : Number (Cricket only)               │   │   │
│  │  │ ├─ amenities          : Array<String>                       │   │   │
│  │  │ ├─ operatingHours     : Map<String, String>                 │   │   │
│  │  │ │  ├─ open            : String (HH:mm)                      │   │   │
│  │  │ │  └─ close           : String (HH:mm)                      │   │   │
│  │  │ ├─ isActive           : Boolean (Default: true)             │   │   │
│  │  │ ├─ rating             : Number (0-5)                        │   │   │
│  │  │ ├─ totalBookings      : Number (Counter)                    │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ └─ updatedAt          : Timestamp                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 1:N (Venue has bookings)              │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         Bookings Collection                         │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: bookingId (Auto-generated)                    │   │   │
│  │  │ ├─ userId             : String (FK -> Users.uid, Indexed)   │   │   │
│  │  │ ├─ venueId            : String (FK -> Venues.id, Indexed)   │   │   │
│  │  │ ├─ bookingType        : String (regular/tournament)         │   │   │
│  │  │ ├─ tournamentId       : String (Optional, FK -> Tournaments)│   │   │
│  │  │ ├─ date               : Date (Indexed)                      │   │   │
│  │  │ ├─ timeSlot           : String                              │   │   │
│  │  │ ├─ duration           : Number (hours)                      │   │   │
│  │  │ ├─ totalAmount        : Number                              │   │   │
│  │  │ ├─ paymentMethod      : String (JazzCash/EasyPaisa)         │   │   │
│  │  │ ├─ paymentStatus      : String (pending/completed/failed)   │   │   │
│  │  │ ├─ paymentId          : String (Optional)                   │   │   │
│  │  │ ├─ status             : String (confirmed/completed/cancelled)│   │   │
│  │  │ ├─ customerNotes      : String (Optional)                   │   │   │
│  │  │ ├─ managerNotes       : String (Optional)                   │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ ├─ updatedAt          : Timestamp                           │   │   │
│  │  │ └─ completedAt        : Timestamp (Optional)                │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ N:1 (Bookings belong to tournaments)  │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       Tournaments Collection                        │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: tournamentId (Auto-generated)                 │   │   │
│  │  │ ├─ creatorId          : String (FK -> Users.uid, Indexed)   │   │   │
│  │  │ ├─ name               : String                              │   │   │
│  │  │ ├─ sport              : String (Indexed)                    │   │   │
│  │  │ ├─ format             : String (Round Robin/Knockout/etc)   │   │   │
│  │  │ ├─ maxTeams           : Number                              │   │   │
│  │  │ ├─ currentTeams       : Number (Counter)                    │   │   │
│  │  │ ├─ teamNames          : Array<String>                       │   │   │
│  │  │ ├─ startDate          : Date (Indexed)                      │   │   │
│  │  │ ├─ endDate            : Date (Indexed)                      │   │   │
│  │  │ ├─ registrationDeadline: Date                               │   │   │
│  │  │ ├─ entryFee           : Number                              │   │   │
│  │  │ ├─ prizePool          : Number                              │   │   │
│  │  │ ├─ status             : String (upcoming/active/completed)  │   │   │
│  │  │ ├─ description        : String (Optional)                   │   │   │
│  │  │ ├─ rules              : String (Optional)                   │   │   │
│  │  │ ├─ isPublic           : Boolean (Default: true)             │   │   │
│  │  │ ├─ totalMatches       : Number (Counter)                    │   │   │
│  │  │ ├─ completedMatches   : Number (Counter)                    │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ └─ updatedAt          : Timestamp                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 1:N (Tournament has matches)           │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                          Matches Collection                         │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: matchId (Auto-generated)                      │   │   │
│  │  │ ├─ tournamentId       : String (FK -> Tournaments.id, Indexed)│   │   │
│  │  │ ├─ venueId            : String (FK -> Venues.id)            │   │   │
│  │  │ ├─ bookingId          : String (FK -> Bookings.id)          │   │   │
│  │  │ ├─ matchNumber        : Number                              │   │   │
│  │  │ ├─ round              : String (Group/QF/SF/Final)          │   │   │
│  │  │ ├─ team1              : String                              │   │   │
│  │  │ ├─ team2              : String                              │   │   │
│  │  │ ├─ team1Score         : Number (Optional)                   │   │   │
│  │  │ ├─ team2Score         : Number (Optional)                   │   │   │
│  │  │ ├─ winner             : String (Optional)                   │   │   │
│  │  │ ├─ result             : String (win/draw/abandoned)         │   │   │
│  │  │ ├─ status             : String (scheduled/live/completed)   │   │   │
│  │  │ ├─ scheduledDate      : Date (Indexed)                      │   │   │
│  │  │ ├─ scheduledTime      : String                              │   │   │
│  │  │ ├─ actualStartTime    : Timestamp (Optional)                │   │   │
│  │  │ ├─ actualEndTime      : Timestamp (Optional)                │   │   │
│  │  │ ├─ referee            : String (Optional)                   │   │   │
│  │  │ ├─ notes              : String (Optional)                   │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ └─ updatedAt          : Timestamp                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ N:M (Users favorite venues)            │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Favorites Collection                         │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: favoriteId (Auto-generated)                   │   │   │
│  │  │ ├─ userId             : String (FK -> Users.uid, Indexed)   │   │   │
│  │  │ ├─ venueId            : String (FK -> Venues.id, Indexed)   │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ └─ Composite Index: (userId, venueId) - Unique             │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 1:N (User has reviews)                 │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         Reviews Collection                          │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: reviewId (Auto-generated)                     │   │   │
│  │  │ ├─ userId             : String (FK -> Users.uid, Indexed)   │   │   │
│  │  │ ├─ venueId            : String (FK -> Venues.id, Indexed)   │   │   │
│  │  │ ├─ bookingId          : String (FK -> Bookings.id)          │   │   │
│  │  │ ├─ rating             : Number (1-5)                        │   │   │
│  │  │ ├─ comment            : String (Optional)                   │   │   │
│  │  │ ├─ isVerified         : Boolean (booked customer)           │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ └─ updatedAt          : Timestamp                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 1:N (User has notifications)           │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      Notifications Collection                       │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: notificationId (Auto-generated)               │   │   │
│  │  │ ├─ userId             : String (FK -> Users.uid, Indexed)   │   │   │
│  │  │ ├─ type               : String (booking/tournament/system)  │   │   │
│  │  │ ├─ title              : String                              │   │   │
│  │  │ ├─ message            : String                              │   │   │
│  │  │ ├─ data               : Map<String, Any> (Optional)         │   │   │
│  │  │ ├─ isRead             : Boolean (Default: false)            │   │   │
│  │  │ ├─ priority           : String (low/medium/high)            │   │   │
│  │  │ ├─ createdAt          : Timestamp (Indexed)                 │   │   │
│  │  │ └─ readAt             : Timestamp (Optional)                │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 1:N (User has payments)                │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Payments Collection                          │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ Document ID: paymentId (Auto-generated)                    │   │   │
│  │  │ ├─ userId             : String (FK -> Users.uid, Indexed)   │   │   │
│  │  │ ├─ bookingId          : String (FK -> Bookings.id)          │   │   │
│  │  │ ├─ tournamentId       : String (Optional, FK -> Tournaments)│   │   │
│  │  │ ├─ amount             : Number                              │   │   │
│  │  │ ├─ currency           : String (PKR)                        │   │   │
│  │  │ ├─ paymentMethod      : String (JazzCash/EasyPaisa)         │   │   │
│  │  │ ├─ transactionId      : String (External payment ID)        │   │   │
│  │  │ ├─ status             : String (pending/completed/failed)   │   │   │
│  │  │ ├─ gatewayResponse    : Map<String, Any> (Optional)         │   │   │
│  │  │ ├─ refundAmount       : Number (Optional)                   │   │   │
│  │  │ ├─ refundStatus       : String (Optional)                   │   │   │
│  │  │ ├─ createdAt          : Timestamp                           │   │   │
│  │  │ ├─ completedAt        : Timestamp (Optional)                │   │   │
│  │  │ └─ refundedAt         : Timestamp (Optional)                │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Entity Descriptions

### Current Implementation Entities

#### 1. Firebase User (Authentication)
- **Purpose:** Handles user authentication and basic profile information
- **Storage:** Firebase Authentication service
- **Key Fields:**
  - `uid`: Unique identifier (Primary Key)
  - `email`: User's email address (unique)
  - `displayName`: User's full name
  - `photoURL`: Profile picture URL (optional)

#### 2. GlobalData.favouriteGrounds
- **Purpose:** Stores user's favorite venues
- **Storage:** In-memory (session-based)
- **Structure:** List of venue objects with image, category, and name
- **Persistence:** Lost on app restart

#### 3. GlobalData.bookedGrounds
- **Purpose:** Tracks all user bookings with details
- **Storage:** In-memory (session-based)
- **Structure:** List containing ground details, date, slot, and payment method
- **Relationships:** References venue objects from static data

#### 4. GlobalData.tournaments
- **Purpose:** Stores tournament information
- **Storage:** In-memory (session-based)
- **Key Fields:**
  - `id`: Unique tournament identifier
  - `name`: Tournament name
  - `sport`: Sport category
  - `format`: Tournament format (Round Robin, Knockout, etc.)
  - `teams`: Number of teams
  - `teamNames`: List of team names
  - `bookedGrounds`: Associated venue bookings

#### 5. GlobalData.tournamentBookedSlots
- **Purpose:** Prevents booking conflicts between regular bookings and tournaments
- **Storage:** In-memory (session-based)
- **Structure:** Nested map (groundName → date → slots[])
- **Function:** Slot availability checking

#### 6. GlobalData.tournamentMatches
- **Purpose:** Stores match fixtures and results
- **Storage:** In-memory (session-based)
- **Structure:** Map (tournamentId → matches[])
- **Match Fields:**
  - `matchId`: Unique match identifier
  - `team1`, `team2`: Competing teams
  - `status`: Match status (scheduled/completed)
  - `result`: Match outcome
  - `winner`: Winning team (if applicable)
  - `scores`: Team scores (optional)

#### 7. GlobalData.tournamentPoints
- **Purpose:** Calculates and stores tournament standings
- **Storage:** In-memory (session-based)
- **Structure:** Map (tournamentId → teamName → points)
- **Calculation:** Based on match results (Win: 3, Draw: 1, Loss: 0)

#### 8. SharedPreferences.profileImages
- **Purpose:** Stores local profile image paths
- **Storage:** Local device storage (persistent)
- **Structure:** Key-value pairs (imagePath_{userUID} → file path)
- **Scope:** Per-user storage

### Future Implementation Entities

#### 1. Users Collection
- **Purpose:** Comprehensive user profiles with role-based data
- **Storage:** Firestore document collection
- **Key Features:**
  - Role-based access (player/manager)
  - Activity tracking
  - Profile management
  - Audit trail

#### 2. Venues Collection
- **Purpose:** Complete venue management system
- **Storage:** Firestore document collection
- **Key Features:**
  - Manager ownership
  - Geographic location
  - Pricing structure
  - Image gallery
  - Rating system
  - Operational status

#### 3. Bookings Collection
- **Purpose:** Comprehensive booking management
- **Storage:** Firestore document collection
- **Key Features:**
  - User and venue relationships
  - Payment integration
  - Status tracking
  - Tournament association
  - Audit trail

#### 4. Tournaments Collection
- **Purpose:** Full tournament management system
- **Storage:** Firestore document collection
- **Key Features:**
  - Creator ownership
  - Team management
  - Status tracking
  - Prize pool management
  - Public/private tournaments

#### 5. Matches Collection
- **Purpose:** Detailed match management
- **Storage:** Firestore document collection
- **Key Features:**
  - Tournament association
  - Venue booking integration
  - Real-time scoring
  - Match statistics
  - Referee assignment

#### 6. Favorites Collection
- **Purpose:** User favorite venues management
- **Storage:** Firestore document collection
- **Key Features:**
  - User-venue relationships
  - Unique constraints
  - Quick access

#### 7. Reviews Collection
- **Purpose:** Venue rating and review system
- **Storage:** Firestore document collection
- **Key Features:**
  - Verified reviews (booking-based)
  - Rating aggregation
  - Comment system
  - Moderation support

#### 8. Notifications Collection
- **Purpose:** User notification management
- **Storage:** Firestore document collection
- **Key Features:**
  - Type-based notifications
  - Read status tracking
  - Priority levels
  - Rich data payload

#### 9. Payments Collection
- **Purpose:** Payment transaction management
- **Storage:** Firestore document collection
- **Key Features:**
  - Multiple payment methods
  - Transaction tracking
  - Refund management
  - Gateway integration

---

## Relationship Descriptions

### Current Implementation Relationships

1. **Firebase User ↔ GlobalData**
   - **Type:** 1:1 (per session)
   - **Description:** Each authenticated user has associated in-memory data
   - **Implementation:** User UID used as reference key

2. **User ↔ Favourite Venues**
   - **Type:** 1:N
   - **Description:** User can favorite multiple venues
   - **Implementation:** List stored in GlobalData.favouriteGrounds

3. **User ↔ Bookings**
   - **Type:** 1:N
   - **Description:** User can have multiple bookings
   - **Implementation:** List stored in GlobalData.bookedGrounds

4. **User ↔ Tournaments**
   - **Type:** 1:N (as creator)
   - **Description:** User can create multiple tournaments
   - **Implementation:** Tournament creator tracked in tournament object

5. **Tournament ↔ Matches**
   - **Type:** 1:N
   - **Description:** Tournament contains multiple matches
   - **Implementation:** Map structure (tournamentId → matches[])

6. **Tournament ↔ Venue Bookings**
   - **Type:** 1:N
   - **Description:** Tournament can book multiple venue slots
   - **Implementation:** Nested map for slot tracking

7. **Venue ↔ Bookings**
   - **Type:** 1:N
   - **Description:** Venue can have multiple bookings
   - **Implementation:** Venue name used as reference

### Future Implementation Relationships

1. **Users ↔ Venues**
   - **Type:** 1:N (Manager owns venues)
   - **Description:** Manager users can own multiple venues
   - **Implementation:** managerId field in Venues collection

2. **Users ↔ Bookings**
   - **Type:** 1:N (User makes bookings)
   - **Description:** Users can make multiple bookings
   - **Implementation:** userId field in Bookings collection

3. **Venues ↔ Bookings**
   - **Type:** 1:N (Venue has bookings)
   - **Description:** Venues can have multiple bookings
   - **Implementation:** venueId field in Bookings collection

4. **Users ↔ Tournaments**
   - **Type:** 1:N (User creates tournaments)
   - **Description:** Users can create multiple tournaments
   - **Implementation:** creatorId field in Tournaments collection

5. **Tournaments ↔ Matches**
   - **Type:** 1:N (Tournament has matches)
   - **Description:** Tournaments contain multiple matches
   - **Implementation:** tournamentId field in Matches collection

6. **Tournaments ↔ Bookings**
   - **Type:** 1:N (Tournament has venue bookings)
   - **Description:** Tournaments can have multiple venue bookings
   - **Implementation:** tournamentId field in Bookings collection

7. **Users ↔ Favorites**
   - **Type:** N:M (Many-to-Many through Favorites)
   - **Description:** Users can favorite multiple venues, venues can be favorited by multiple users
   - **Implementation:** Separate Favorites collection with userId and venueId

8. **Users ↔ Reviews**
   - **Type:** 1:N (User writes reviews)
   - **Description:** Users can write multiple reviews
   - **Implementation:** userId field in Reviews collection

9. **Venues ↔ Reviews**
   - **Type:** 1:N (Venue receives reviews)
   - **Description:** Venues can receive multiple reviews
   - **Implementation:** venueId field in Reviews collection

10. **Users ↔ Notifications**
    - **Type:** 1:N (User receives notifications)
    - **Description:** Users can receive multiple notifications
    - **Implementation:** userId field in Notifications collection

11. **Users ↔ Payments**
    - **Type:** 1:N (User makes payments)
    - **Description:** Users can make multiple payments
    - **Implementation:** userId field in Payments collection

12. **Bookings ↔ Payments**
    - **Type:** 1:1 (Booking has payment)
    - **Description:** Each booking has associated payment
    - **Implementation:** bookingId field in Payments collection

---

## Data Flow Relationships

### Authentication Flow
```
User Registration/Login → Firebase Auth → User Document Creation → 
Role-based Dashboard Access
```

### Booking Flow
```
User → Venue Selection → Date/Slot Selection → Payment → 
Booking Creation → Venue Slot Update → Confirmation
```

### Tournament Flow
```
User → Tournament Creation → Team Setup → Venue Booking → 
Fixture Generation → Match Management → Points Calculation → 
Tournament Completion
```

### Manager Analytics Flow
```
Bookings Data → Revenue Calculation → Statistics Aggregation → 
Chart Data Generation → Dashboard Display
```

### Notification Flow
```
System Event → Notification Creation → User Notification Queue → 
Push Notification → Read Status Update
```

---

## Database Indexes and Optimization

### Current Implementation
- **No formal indexing** (in-memory data)
- **Linear search** for data retrieval
- **Session-based** data lifecycle

### Future Implementation Indexes

#### Primary Indexes
```
Users Collection:
- email (unique)
- role (composite with isActive)

Venues Collection:
- managerId (for manager's venues)
- category (for filtering)
- location (geospatial)
- isActive (for active venues)

Bookings Collection:
- userId (for user's bookings)
- venueId (for venue's bookings)
- date (for date-based queries)
- status (for active bookings)

Tournaments Collection:
- creatorId (for user's tournaments)
- sport (for sport-based filtering)
- status (for active tournaments)
- startDate (for upcoming tournaments)

Matches Collection:
- tournamentId (for tournament matches)
- scheduledDate (for match scheduling)
- status (for match status)

Favorites Collection:
- userId (for user's favorites)
- (userId, venueId) composite unique

Reviews Collection:
- venueId (for venue reviews)
- userId (for user reviews)

Notifications Collection:
- userId (for user notifications)
- createdAt (for chronological order)
- isRead (for unread notifications)

Payments Collection:
- userId (for user payments)
- bookingId (for booking payments)
- status (for payment status)
```

#### Composite Indexes
```
Bookings:
- (userId, date) - User's bookings by date
- (venueId, date) - Venue's bookings by date
- (status, date) - Active bookings by date

Matches:
- (tournamentId, round) - Tournament matches by round
- (venueId, scheduledDate) - Venue matches by date

Reviews:
- (venueId, createdAt) - Venue reviews chronologically
- (userId, createdAt) - User reviews chronologically
```

---

## Security Rules and Access Control

### Current Implementation
- **Firebase Auth** for user authentication
- **No granular access control** (client-side only)
- **Session-based** data access

### Future Implementation Security Rules

#### Firestore Security Rules
```javascript
// Users Collection
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  allow read: if request.auth != null && resource.data.isActive == true;
}

// Venues Collection
match /venues/{venueId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.managerId;
  allow update, delete: if request.auth != null && 
    request.auth.uid == resource.data.managerId;
}

// Bookings Collection
match /bookings/{bookingId} {
  allow read, write: if request.auth != null && 
    (request.auth.uid == resource.data.userId || 
     request.auth.uid == get(/databases/$(database)/documents/venues/$(resource.data.venueId)).data.managerId);
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.userId;
}

// Tournaments Collection
match /tournaments/{tournamentId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.creatorId;
  allow update, delete: if request.auth != null && 
    request.auth.uid == resource.data.creatorId;
}

// Matches Collection
match /matches/{matchId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
    request.auth.uid == get(/databases/$(database)/documents/tournaments/$(resource.data.tournamentId)).data.creatorId;
}

// Favorites Collection
match /favorites/{favoriteId} {
  allow read, write: if request.auth != null && 
    request.auth.uid == resource.data.userId;
}

// Reviews Collection
match /reviews/{reviewId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.userId;
  allow update, delete: if request.auth != null && 
    request.auth.uid == resource.data.userId;
}

// Notifications Collection
match /notifications/{notificationId} {
  allow read, write: if request.auth != null && 
    request.auth.uid == resource.data.userId;
}

// Payments Collection
match /payments/{paymentId} {
  allow read: if request.auth != null && 
    request.auth.uid == resource.data.userId;
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.userId;
}
```

---

## Migration Strategy

### Phase 1: Current to Hybrid
1. **Maintain current GlobalData structure**
2. **Add Firebase Firestore integration**
3. **Implement data synchronization**
4. **Add offline capability**

### Phase 2: Full Firebase Migration
1. **Migrate user data to Firestore**
2. **Implement real-time listeners**
3. **Add advanced features (reviews, notifications)**
4. **Optimize performance with indexes**

### Phase 3: Advanced Features
1. **Add payment gateway integration**
2. **Implement push notifications**
3. **Add analytics and reporting**
4. **Implement caching strategies**

---

This comprehensive ER diagram documentation provides a complete view of the PlaySphere application's data architecture, covering both current implementation and future scalability plans.