# PlaySphere - ER Diagram Description

## Entity-Relationship Diagram Components

### Entities and Attributes

#### 1. USER
**Attributes:**
- uid (PK) - String
- email - String (Unique)
- displayName - String
- role - String (player/manager)
- profileImageURL - String
- phoneNumber - String
- createdAt - Timestamp
- updatedAt - Timestamp

#### 2. VENUE
**Attributes:**
- venueId (PK) - String
- managerId (FK) - String
- name - String
- category - String
- location - String
- address - String
- images - Array[String]
- pricing - Number
- isActive - Boolean
- rating - Number
- totalBookings - Number
- createdAt - Timestamp
- updatedAt - Timestamp

#### 3. BOOKING
**Attributes:**
- bookingId (PK) - String
- userId (FK) - String
- venueId (FK) - String
- tournamentId (FK) - String (Optional)
- date - Date
- timeSlot - String
- totalAmount - Number
- paymentMethod - String
- paymentStatus - String
- status - String
- createdAt - Timestamp
- updatedAt - Timestamp
- completedAt - Timestamp

#### 4. TOURNAMENT
**Attributes:**
- tournamentId (PK) - String
- creatorId (FK) - String
- name - String
- sport - String
- format - String
- maxTeams - Number
- teamNames - Array[String]
- startDate - Date
- endDate - Date
- status - String
- totalMatches - Number
- completedMatches - Number
- createdAt - Timestamp
- updatedAt - Timestamp

#### 5. MATCH
**Attributes:**
- matchId (PK) - String
- tournamentId (FK) - String
- venueId (FK) - String
- bookingId (FK) - String
- matchNumber - Number
- round - String
- team1 - String
- team2 - String
- team1Score - Number
- team2Score - Number
- winner - String
- result - String
- status - String
- scheduledDate - Date
- scheduledTime - String
- createdAt - Timestamp
- updatedAt - Timestamp

#### 6. FAVORITE
**Attributes:**
- favoriteId (PK) - String
- userId (FK) - String
- venueId (FK) - String
- createdAt - Timestamp

#### 7. REVIEW
**Attributes:**
- reviewId (PK) - String
- userId (FK) - String
- venueId (FK) - String
- bookingId (FK) - String
- rating - Number
- comment - String
- isVerified - Boolean
- createdAt - Timestamp
- updatedAt - Timestamp

#### 8. PAYMENT
**Attributes:**
- paymentId (PK) - String
- userId (FK) - String
- bookingId (FK) - String
- amount - Number
- paymentMethod - String
- transactionId - String
- status - String
- createdAt - Timestamp
- completedAt - Timestamp

---

## Relationships

### 1. USER - VENUE
- **Type:** One-to-Many (1:N)
- **Relationship:** "owns" / "manages"
- **Description:** One Manager (User) can own multiple Venues
- **Foreign Key:** managerId in VENUE references uid in USER

### 2. USER - BOOKING
- **Type:** One-to-Many (1:N)
- **Relationship:** "makes" / "creates"
- **Description:** One User can make multiple Bookings
- **Foreign Key:** userId in BOOKING references uid in USER

### 3. VENUE - BOOKING
- **Type:** One-to-Many (1:N)
- **Relationship:** "has" / "receives"
- **Description:** One Venue can have multiple Bookings
- **Foreign Key:** venueId in BOOKING references venueId in VENUE

### 4. USER - TOURNAMENT
- **Type:** One-to-Many (1:N)
- **Relationship:** "creates" / "organizes"
- **Description:** One User can create multiple Tournaments
- **Foreign Key:** creatorId in TOURNAMENT references uid in USER

### 5. TOURNAMENT - MATCH
- **Type:** One-to-Many (1:N)
- **Relationship:** "contains" / "has"
- **Description:** One Tournament contains multiple Matches
- **Foreign Key:** tournamentId in MATCH references tournamentId in TOURNAMENT

### 6. TOURNAMENT - BOOKING
- **Type:** One-to-Many (1:N)
- **Relationship:** "requires" / "reserves"
- **Description:** One Tournament can have multiple Bookings (for different venues/dates)
- **Foreign Key:** tournamentId in BOOKING references tournamentId in TOURNAMENT

### 7. VENUE - MATCH
- **Type:** One-to-Many (1:N)
- **Relationship:** "hosts"
- **Description:** One Venue can host multiple Matches
- **Foreign Key:** venueId in MATCH references venueId in VENUE

### 8. BOOKING - MATCH
- **Type:** One-to-One (1:1)
- **Relationship:** "reserves for"
- **Description:** Each Match has one Booking reservation
- **Foreign Key:** bookingId in MATCH references bookingId in BOOKING

### 9. USER - FAVORITE (Many-to-Many through junction table)
- **Type:** Many-to-Many (M:N)
- **Relationship:** "favorites" / "liked by"
- **Description:** Users can favorite multiple Venues, Venues can be favorited by multiple Users
- **Implementation:** FAVORITE table acts as junction table
- **Foreign Keys:** 
  - userId in FAVORITE references uid in USER
  - venueId in FAVORITE references venueId in VENUE

### 10. USER - REVIEW
- **Type:** One-to-Many (1:N)
- **Relationship:** "writes"
- **Description:** One User can write multiple Reviews
- **Foreign Key:** userId in REVIEW references uid in USER

### 11. VENUE - REVIEW
- **Type:** One-to-Many (1:N)
- **Relationship:** "receives"
- **Description:** One Venue can receive multiple Reviews
- **Foreign Key:** venueId in REVIEW references venueId in VENUE

### 12. BOOKING - REVIEW
- **Type:** One-to-One (1:1)
- **Relationship:** "generates"
- **Description:** Each Booking can have one Review
- **Foreign Key:** bookingId in REVIEW references bookingId in BOOKING

### 13. USER - PAYMENT
- **Type:** One-to-Many (1:N)
- **Relationship:** "makes"
- **Description:** One User can make multiple Payments
- **Foreign Key:** userId in PAYMENT references uid in USER

### 14. BOOKING - PAYMENT
- **Type:** One-to-One (1:1)
- **Relationship:** "has"
- **Description:** Each Booking has one Payment
- **Foreign Key:** bookingId in PAYMENT references bookingId in BOOKING

---

## Cardinality Summary

```
USER (1) ──owns──> (N) VENUE
USER (1) ──makes──> (N) BOOKING
USER (1) ──creates──> (N) TOURNAMENT
USER (1) ──writes──> (N) REVIEW
USER (1) ──makes──> (N) PAYMENT

VENUE (1) ──has──> (N) BOOKING
VENUE (1) ──hosts──> (N) MATCH
VENUE (1) ──receives──> (N) REVIEW

TOURNAMENT (1) ──contains──> (N) MATCH
TOURNAMENT (1) ──requires──> (N) BOOKING

BOOKING (1) ──reserves for──> (1) MATCH
BOOKING (1) ──generates──> (1) REVIEW
BOOKING (1) ──has──> (1) PAYMENT

USER (M) ──favorites──> (N) VENUE  [through FAVORITE table]
```

---

## Key Constraints

1. **Primary Keys:** All entities have unique primary keys
2. **Foreign Keys:** Maintain referential integrity
3. **Unique Constraints:**
   - USER.email (unique)
   - FAVORITE (userId, venueId) composite unique
4. **Check Constraints:**
   - REVIEW.rating between 1 and 5
   - VENUE.rating between 0 and 5
   - USER.role in ('player', 'manager')
   - BOOKING.status in ('confirmed', 'completed', 'cancelled')
   - TOURNAMENT.status in ('upcoming', 'active', 'completed')

---

## Indexes (for optimization)

- USER: email, role
- VENUE: managerId, category, isActive
- BOOKING: userId, venueId, date, status
- TOURNAMENT: creatorId, sport, status
- MATCH: tournamentId, venueId, scheduledDate
- FAVORITE: userId, venueId
- REVIEW: venueId, userId
- PAYMENT: userId, bookingId

---

## How to Draw the ER Diagram

### Step 1: Draw Entities
- Draw rectangles for each entity (USER, VENUE, BOOKING, TOURNAMENT, MATCH, FAVORITE, REVIEW, PAYMENT)
- Write entity name at the top of each rectangle

### Step 2: Add Attributes
- List attributes inside each entity rectangle
- Underline primary keys (PK)
- Mark foreign keys with (FK)

### Step 3: Draw Relationships
- Draw diamond shapes between related entities
- Label each diamond with the relationship name
- Draw lines connecting entities to relationships

### Step 4: Add Cardinality
- Mark cardinality on each relationship line:
  - "1" for one
  - "N" or "M" for many
- Place cardinality markers near the entity they describe

### Step 5: Highlight Junction Tables
- FAVORITE is a junction table for USER-VENUE many-to-many relationship
- Show it connecting both entities

### Layout Suggestion
```
Top Row: USER, TOURNAMENT, MATCH
Middle Row: VENUE, BOOKING, PAYMENT
Bottom Row: FAVORITE, REVIEW
```

This creates a logical flow showing:
- User relationships at the top
- Core booking flow in the middle
- Supporting features at the bottom
