# PlaySphere - System Landscape Diagram

## System Landscape (Mermaid)

```mermaid
graph LR
    subgraph Users["👥 External Users"]
        Player[Player/User]
        Manager[Venue Manager]
    end

    subgraph Frontend["📱 Presentation Layer"]
        AuthUI[Authentication UI]
        PlayerUI[Player Dashboard]
        ManagerUI[Manager Dashboard]
        BookingUI[Booking Interface]
        TournamentUI[Tournament Interface]
        AnalyticsUI[Analytics Dashboard]
    end

    subgraph Services["⚙️ Business Logic Layer"]
        AuthService[Authentication Service]
        BookingService[Booking Service]
        VenueService[Venue Service]
        TournamentService[Tournament Service]
        PaymentService[Payment Service]
        AnalyticsService[Analytics Service]
        NotificationService[Notification Service]
    end

    subgraph Data["💾 Data Layer"]
        GlobalData[In-Memory Store]
        LocalCache[Local Cache]
    end

    subgraph Firebase["🔥 Firebase Backend"]
        FirebaseAuth[Firebase Auth]
        Firestore[Firestore DB]
        FirebaseStorage[Storage]
        CloudFunctions[Cloud Functions]
    end

    subgraph External["🌐 External Services"]
        PaymentGateway[Payment Gateway]
        EmailService[Email Service]
        SMSService[SMS Service]
    end

    %% User to UI
    Player --> AuthUI
    Player --> PlayerUI
    Player --> TournamentUI
    Manager --> AuthUI
    Manager --> ManagerUI
    Manager --> AnalyticsUI

    %% UI to Services
    AuthUI --> AuthService
    PlayerUI --> BookingService
    PlayerUI --> VenueService
    ManagerUI --> VenueService
    ManagerUI --> AnalyticsService
    BookingUI --> BookingService
    BookingUI --> PaymentService
    TournamentUI --> TournamentService
    AnalyticsUI --> AnalyticsService

    %% Services to Data
    AuthService --> GlobalData
    BookingService --> GlobalData
    VenueService --> GlobalData
    TournamentService --> GlobalData
    PaymentService --> GlobalData
    AnalyticsService --> GlobalData
    AuthService --> LocalCache
    BookingService --> LocalCache
    VenueService --> LocalCache

    %% Services to Firebase
    AuthService --> FirebaseAuth
    BookingService --> Firestore
    VenueService --> Firestore
    VenueService --> FirebaseStorage
    TournamentService --> Firestore
    PaymentService --> Firestore
    AnalyticsService --> Firestore

    %% Firebase to External
    CloudFunctions --> PaymentGateway
    CloudFunctions --> EmailService
    CloudFunctions --> SMSService
    NotificationService --> CloudFunctions

    %% Styling
    classDef userClass fill:#4A90E2,stroke:#2E5C8A,color:#fff,stroke-width:2px
    classDef uiClass fill:#50C878,stroke:#2E7D4E,color:#fff,stroke-width:2px
    classDef serviceClass fill:#F39C12,stroke:#C87F0A,color:#fff,stroke-width:2px
    classDef dataClass fill:#9B59B6,stroke:#6C3483,color:#fff,stroke-width:2px
    classDef firebaseClass fill:#FFA500,stroke:#CC8400,color:#fff,stroke-width:2px
    classDef externalClass fill:#E74C3C,stroke:#C0392B,color:#fff,stroke-width:2px

    class Player,Manager userClass
    class AuthUI,PlayerUI,ManagerUI,BookingUI,TournamentUI,AnalyticsUI uiClass
    class AuthService,BookingService,VenueService,TournamentService,PaymentService,AnalyticsService,NotificationService serviceClass
    class GlobalData,LocalCache dataClass
    class FirebaseAuth,Firestore,FirebaseStorage,CloudFunctions firebaseClass
    class PaymentGateway,EmailService,SMSService externalClass
```

## System Components

### 1. External Users
- **Player/User**: End users who book venues and organize tournaments
- **Venue Manager**: Business owners who manage sports facilities

### 2. Presentation Layer (Flutter UI)
- **Authentication UI**: Login, registration, password reset screens
- **Player Dashboard**: Home screen with venue browsing, bookings, tournaments
- **Manager Dashboard**: Venue management, booking overview, analytics
- **Booking Interface**: Venue details, slot selection, payment
- **Tournament Interface**: Tournament creation, fixtures, match results
- **Analytics Dashboard**: Revenue reports, booking trends, performance metrics

### 3. Business Logic Layer (Services)
- **Authentication Service**: User/manager authentication and authorization
- **Booking Service**: Venue booking logic, slot management, conflict detection
- **Venue Service**: Venue CRUD operations, search, filtering
- **Tournament Service**: Tournament lifecycle, fixture generation, points calculation
- **Payment Service**: Payment processing, transaction records
- **Analytics Service**: Data aggregation, report generation
- **Notification Service**: Push notifications, email alerts

### 4. Data Layer
- **In-Memory Data Store (GlobalData)**: Current implementation for rapid prototyping
- **Local Cache**: Offline data persistence, performance optimization

### 5. Firebase Backend
- **Firebase Authentication**: User identity management
- **Cloud Firestore**: NoSQL database for all entities
- **Firebase Storage**: Profile images, venue photos
- **Cloud Functions**: Server-side logic, scheduled tasks

### 6. External Services
- **Payment Gateway**: JazzCash, EasyPaisa integration
- **Email Service**: Booking confirmations, notifications
- **SMS Service**: OTP verification, alerts

## Data Flow Examples

### Booking Flow
```
Player → BookingUI → BookingService → GlobalData/Firestore
                   ↓
              PaymentService → PaymentGateway
                   ↓
           NotificationService → Email/SMS
```

### Tournament Creation Flow
```
Player → TournamentUI → TournamentService → GlobalData/Firestore
                      ↓
                 VenueService (for match bookings)
                      ↓
              NotificationService (team invites)
```

### Analytics Flow
```
Manager → AnalyticsUI → AnalyticsService → Firestore (aggregate queries)
                                         ↓
                                    LocalCache (caching)
```

## Technology Stack

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Provider pattern
- **UI Components**: Material Design 3
- **Navigation**: Named routes with arguments

### Backend
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Functions**: Cloud Functions (Node.js/TypeScript)

### Current Implementation
- **Data Storage**: In-memory GlobalData class
- **Authentication**: Firebase Auth with email/password
- **Payment**: Mock implementation (UI only)

## Security Architecture

```mermaid
graph LR
    User[User] -->|HTTPS| App[Flutter App]
    App -->|Authenticated Requests| Firebase[Firebase]
    Firebase -->|Security Rules| Firestore[Firestore]
    Firebase -->|Token Validation| Auth[Firebase Auth]
    
    style User fill:#4A90E2
    style App fill:#50C878
    style Firebase fill:#FFA500
    style Firestore fill:#9B59B6
    style Auth fill:#E74C3C
```

### Security Layers
1. **Transport Security**: HTTPS/TLS encryption
2. **Authentication**: Firebase Auth tokens
3. **Authorization**: Firestore security rules
4. **Data Validation**: Client and server-side validation
5. **Role-Based Access**: User vs Manager permissions

## Deployment Architecture

```mermaid
graph LR
    subgraph Clients["📱 Client Devices"]
        Android[Android Devices]
        iOS[iOS Devices]
    end

    subgraph FirebaseCloud["🔥 Firebase Cloud"]
        Auth[Firebase Auth]
        DB[Firestore]
        Storage[Storage]
        Functions[Cloud Functions]
        Hosting[Firebase Hosting]
    end

    subgraph APIs["🌐 External APIs"]
        Payment[Payment APIs]
        Notification[Notification APIs]
    end

    Android --> Auth
    Android --> DB
    Android --> Storage
    iOS --> Auth
    iOS --> DB
    iOS --> Storage
    
    Auth --> Functions
    DB --> Functions
    Storage --> Functions
    Functions --> Payment
    Functions --> Notification
    
    style Android fill:#3DDC84,stroke:#2E7D4E,stroke-width:2px
    style iOS fill:#147EFB,stroke:#0D5BA8,stroke-width:2px
    style Auth fill:#FFA500,stroke:#CC8400,stroke-width:2px
    style DB fill:#FFA500,stroke:#CC8400,stroke-width:2px
    style Storage fill:#FFA500,stroke:#CC8400,stroke-width:2px
    style Functions fill:#FFA500,stroke:#CC8400,stroke-width:2px
    style Hosting fill:#FFA500,stroke:#CC8400,stroke-width:2px
    style Payment fill:#E74C3C,stroke:#C0392B,stroke-width:2px
    style Notification fill:#E74C3C,stroke:#C0392B,stroke-width:2px
```

## Integration Points

### 1. Firebase Integration
- Authentication: Email/password, Google Sign-In (future)
- Database: Real-time sync, offline persistence
- Storage: Image upload/download with CDN

### 2. Payment Integration (Planned)
- JazzCash Mobile Account API
- EasyPaisa Merchant API
- Bank transfer verification

### 3. Notification Integration (Planned)
- Firebase Cloud Messaging (FCM)
- Email via SendGrid/Firebase Extensions
- SMS via Twilio/local providers

## Scalability Considerations

### Current State
- In-memory data (development only)
- Single-device state management
- No real-time sync

### Production Ready
- Firestore with proper indexing
- Cloud Functions for heavy operations
- CDN for static assets
- Caching strategy for frequently accessed data

## Future Enhancements

### Phase 1 (Database Migration)
- Migrate from GlobalData to Firestore
- Implement offline persistence
- Add real-time listeners

### Phase 2 (Payment Integration)
- Integrate payment gateways
- Add transaction verification
- Implement refund logic

### Phase 3 (Advanced Features)
- Push notifications
- Chat system
- Review and rating system
- Advanced analytics with ML

### Phase 4 (Scale & Optimize)
- Implement caching layers
- Add search indexing (Algolia)
- Performance monitoring
- Load balancing

---

**Note:** This landscape diagram represents the complete system architecture of PlaySphere, showing how all components interact from user interfaces to backend services and external integrations.
