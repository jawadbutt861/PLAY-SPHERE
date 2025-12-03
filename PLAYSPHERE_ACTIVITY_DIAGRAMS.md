# PlaySphere - Activity Diagrams

## Table of Contents
1. [Overview](#overview)
2. [Application Startup Flow](#application-startup-flow)
3. [User Authentication Flows](#user-authentication-flows)
4. [Player Activity Flows](#player-activity-flows)
5. [Manager Activity Flows](#manager-activity-flows)
6. [Tournament Management Flows](#tournament-management-flows)
7. [System Process Flows](#system-process-flows)

---

## Overview

This document presents comprehensive activity diagrams for the PlaySphere application, covering all major user interactions and system processes. The diagrams follow UML activity diagram conventions with swim lanes for different actors and systems.

**Legend:**
- ⚫ Start/End nodes
- ◆ Decision points
- ▬ Activity bars
- → Flow direction
- ║ Swim lane separators

---

## Application Startup Flow

```
                    APPLICATION STARTUP ACTIVITY DIAGRAM
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  USER                    │    APPLICATION         │    FIREBASE            │
│                          │                        │                        │
│    ⚫ Start               │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Open App        │────▶│  ┌─────────────────┐   │                        │
│  └─────────────────┘     │  │ Initialize App  │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Load Firebase   │──▶│  │ Initialize      │   │
│                          │  │ Configuration   │   │  │ Firebase SDK    │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │           │            │
│                          │           ▼            │           ▼            │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Check Auth      │◀──│  │ Auth State      │   │
│                          │  │ Status          │   │  │ Check           │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │      ◆ User            │                        │
│                          │    Authenticated?      │                        │
│                          │           │            │                        │
│                    Yes   │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Navigate to     │     │  │ Route to User   │   │                        │
│  │ Dashboard       │     │  │ Dashboard       │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
│                    No    │           │            │                        │
│  ┌─────────────────┐◀────│           ▼            │                        │
│  │ Show Splash     │     │  ┌─────────────────┐   │                        │
│  │ Screen          │     │  │ Display Splash  │   │                        │
│  └─────────────────┘     │  │ Screen          │   │                        │
│           │               │  └─────────────────┘   │                        │
│           ▼               │           │            │                        │
│  ┌─────────────────┐     │           ▼            │                        │
│  │ Navigate to     │◀────│  ┌─────────────────┐   │                        │
│  │ Role Selection  │     │  │ Show Role       │   │                        │
│  └─────────────────┘     │  │ Selection       │   │                        │
│           │               │  └─────────────────┘   │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## User Authentication Flows

### Player Registration Flow

```
                    PLAYER REGISTRATION ACTIVITY DIAGRAM
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  USER                    │    APPLICATION         │    FIREBASE            │
│                          │                        │                        │
│    ⚫ Start               │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Player   │────▶│  ┌─────────────────┐   │                        │
│  │ Role            │     │  │ Navigate to     │   │                        │
│  └─────────────────┘     │  │ Player Signup   │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Signup     │     │  │ Display Signup  │   │                        │
│  │ Form            │     │  │ Form            │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Enter Details:  │     │                        │                        │
│  │ - Full Name     │     │                        │                        │
│  │ - Email         │     │                        │                        │
│  │ - Mobile Number │     │                        │                        │
│  │ - Password      │     │                        │                        │
│  └─────────────────┘     │                        │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Submit Form     │────▶│  ┌─────────────────┐   │                        │
│  └─────────────────┘     │  │ Validate Form   │   │                        │
│                          │  │ Data            │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │      ◆ Form Valid?     │                        │
│                          │           │            │                        │
│                    No    │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Show Validation │     │  │ Display Error   │   │                        │
│  │ Errors          │     │  │ Messages        │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           └───────────────┼───────────┘            │                        │
│                          │                        │                        │
│                    Yes   │           │            │                        │
│                          │           ▼            │                        │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Create User     │──▶│  │ Firebase Auth   │   │
│                          │  │ Account         │   │  │ Create User     │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │           │            │
│                          │           ▼            │           ▼            │
│                          │      ◆ Account         │      ◆ Creation        │
│                          │    Created?            │    Successful?         │
│                          │           │            │           │            │
│                    No    │           ▼            │     No    ▼            │
│  ┌─────────────────┐◀────│  ┌─────────────────┐◀──│  ┌─────────────────┐   │
│  │ Show Error      │     │  │ Handle Auth     │   │  │ Return Error    │   │
│  │ Message         │     │  │ Error           │   │  │ Response        │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │                        │
│           └───────────────┼───────────┘            │                        │
│                          │                        │                        │
│                    Yes   │           │            │     Yes   │            │
│                          │           ▼            │           ▼            │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Update User     │◀──│  │ Return Success  │   │
│                          │  │ Profile         │   │  │ Response        │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Show Success    │     │  │ Display Success │   │                        │
│  │ Message         │     │  │ Message         │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Navigate to     │     │  │ Route to Login  │   │                        │
│  │ Login Screen    │     │  │ Screen          │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
└─────────────────────────────────────────────────────────────────────────────┘
```
### User 
Login Flow

```
                        USER LOGIN ACTIVITY DIAGRAM
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  USER                    │    APPLICATION         │    FIREBASE            │
│                          │                        │                        │
│    ⚫ Start               │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Login    │────▶│  ┌─────────────────┐   │                        │
│  │ Option          │     │  │ Navigate to     │   │                        │
│  └─────────────────┘     │  │ Login Screen    │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Login      │     │  │ Display Login   │   │                        │
│  │ Form            │     │  │ Form            │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Enter           │     │                        │                        │
│  │ Credentials:    │     │                        │                        │
│  │ - Email         │     │                        │                        │
│  │ - Password      │     │                        │                        │
│  └─────────────────┘     │                        │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Submit Login    │────▶│  ┌─────────────────┐   │                        │
│  └─────────────────┘     │  │ Validate Input  │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │      ◆ Input Valid?    │                        │
│                          │           │            │                        │
│                    No    │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Show Validation │     │  │ Display Error   │   │                        │
│  │ Errors          │     │  │ Messages        │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           └───────────────┼───────────┘            │                        │
│                          │                        │                        │
│                    Yes   │           │            │                        │
│                          │           ▼            │                        │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Authenticate    │──▶│  │ Firebase Auth   │   │
│                          │  │ User            │   │  │ Sign In         │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │           │            │
│                          │           ▼            │           ▼            │
│                          │      ◆ Auth            │      ◆ Authentication  │
│                          │    Successful?         │    Successful?         │
│                          │           │            │           │            │
│                    No    │           ▼            │     No    ▼            │
│  ┌─────────────────┐◀────│  ┌─────────────────┐◀──│  ┌─────────────────┐   │
│  │ Show Auth       │     │  │ Handle Auth     │   │  │ Return Error    │   │
│  │ Error           │     │  │ Error           │   │  │ Response        │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │                        │
│           └───────────────┼───────────┘            │                        │
│                          │                        │                        │
│                    Yes   │           │            │     Yes   │            │
│                          │           ▼            │           ▼            │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Create User     │◀──│  │ Return User     │   │
│                          │  │ Session         │   │  │ Credentials     │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │      ◆ User Role?      │                        │
│                          │           │            │                        │
│              Player      │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Navigate to     │     │  │ Route to Player │   │                        │
│  │ Player Dashboard│     │  │ Dashboard       │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
│              Manager     │           │            │                        │
│  ┌─────────────────┐◀────│           ▼            │                        │
│  │ Navigate to     │     │  ┌─────────────────┐   │                        │
│  │ Manager Dashboard│     │  │ Route to Manager│   │                        │
│  └─────────────────┘     │  │ Dashboard       │   │                        │
│           │               │  └─────────────────┘   │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Player Activity Flows

### Venue Booking Flow

```
                        VENUE BOOKING ACTIVITY DIAGRAM
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  PLAYER                  │    APPLICATION         │    GLOBAL DATA         │
│                          │                        │                        │
│    ⚫ Start               │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Navigate to     │────▶│  ┌─────────────────┐   │                        │
│  │ Categories      │     │  │ Load Categories │   │                        │
│  └─────────────────┘     │  │ Screen          │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Venue      │     │  │ Display Venue   │   │                        │
│  │ Categories      │     │  │ Categories      │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Category │────▶│  ┌─────────────────┐   │                        │
│  │ (Optional)      │     │  │ Filter Venues   │   │                        │
│  └─────────────────┘     │  │ by Category     │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Browse Filtered │     │  │ Display Filtered│   │                        │
│  │ Venues          │     │  │ Venues          │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Venue    │────▶│  ┌─────────────────┐   │                        │
│  └─────────────────┘     │  │ Open Booking    │   │                        │
│                          │  │ Dialog          │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Booking    │     │  │ Display Date    │   │                        │
│  │ Options         │     │  │ Picker          │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Date     │────▶│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ (Tomorrow to    │     │  │ Check Date      │──▶│  │ Validate Date   │   │
│  │ 30 days ahead)  │     │  │ Validity        │   │  │ Range           │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │           │            │
│                          │           ▼            │           ▼            │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Load Available  │◀──│  │ Check Slot      │   │
│                          │  │ Time Slots      │   │  │ Availability    │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Available  │     │  │ Display Time    │   │                        │
│  │ Time Slots      │     │  │ Slots with      │   │                        │
│  └─────────────────┘     │  │ Availability    │   │                        │
│           │               │  └─────────────────┘   │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Time     │────▶│  ┌─────────────────┐   │                        │
│  │ Slot            │     │  │ Validate Slot   │   │                        │
│  └─────────────────┘     │  │ Selection       │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Payment    │     │  │ Display Payment │   │                        │
│  │ Methods         │     │  │ Options         │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Select Payment  │────▶│  ┌─────────────────┐   │                        │
│  │ Method          │     │  │ Validate        │   │                        │
│  │ (JazzCash/      │     │  │ Selection       │   │                        │
│  │ EasyPaisa)      │     │  └─────────────────┘   │                        │
│  └─────────────────┘     │           │            │                        │
│                          │           ▼            │                        │
│                          │      ◆ All Fields      │                        │
│                          │    Selected?           │                        │
│                          │           │            │                        │
│                    No    │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Show Warning    │     │  │ Display Warning │   │                        │
│  │ Message         │     │  │ Message         │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           └───────────────┼───────────┘            │                        │
│                          │                        │                        │
│                    Yes   │           │            │                        │
│           ▼               │           ▼            │                        │
│  ┌─────────────────┐     │  ┌─────────────────┐   │                        │
│  │ Confirm Booking │────▶│  │ Process Booking │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Update Slot     │──▶│  │ Mark Slot as    │   │
│                          │  │ Availability    │   │  │ Booked          │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │           │            │
│                          │           ▼            │           ▼            │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Add to Booking  │◀──│  │ Store Booking   │   │
│                          │  │ History         │   │  │ Details         │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Booking    │     │  │ Display Success │   │                        │
│  │ Confirmation    │     │  │ Message         │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│         ⚫ End            │  ┌─────────────────┐   │                        │
│                          │  │ Close Dialog    │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │         ⚫ End         │                        │
│                          │                        │                        │
└─────────────────────────────────────────────────────────────────────────────┘
```#
## Favorites Management Flow

```
                    FAVORITES MANAGEMENT ACTIVITY DIAGRAM
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  PLAYER                  │    APPLICATION         │    GLOBAL DATA         │
│                          │                        │                        │
│    ⚫ Start               │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Browse Venues   │────▶│  ┌─────────────────┐   │                        │
│  └─────────────────┘     │  │ Display Venues  │   │                        │
│                          │  │ with Heart Icon │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ View Venue      │     │  │ Check Favorite  │──▶│  │ Check if Venue  │   │
│  │ Cards           │     │  │ Status          │   │  │ in Favorites    │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │           │            │
│           ▼               │           ▼            │           ▼            │
│  ┌─────────────────┐     │      ◆ Is Venue        │      ◆ Venue in        │
│  │ Tap Heart Icon  │     │    Favorited?          │    Favorites List?     │
│  └─────────────────┘     │           │            │           │            │
│           │               │           ▼            │           ▼            │
│           ▼               │                        │                        │
│      ◆ Current            │                        │                        │
│    Action?                │                        │                        │
│           │               │                        │                        │
│    Add to Favorites       │           │            │     No    │            │
│           ▼               │           ▼            │           ▼            │
│  ┌─────────────────┐────▶│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ Add to          │     │  │ Add Venue to    │──▶│  │ Add Venue to    │   │
│  │ Favorites       │     │  │ Favorites       │   │  │ Favorites List  │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │           │            │
│           ▼               │           ▼            │           ▼            │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ See Heart Icon  │     │  │ Update Heart    │◀──│  │ Update UI State │   │
│  │ Filled (Red)    │     │  │ Icon to Filled  │   │  │                 │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│         ⚫ End            │         ⚫ End         │                        │
│                          │                        │                        │
│  Remove from Favorites   │           │            │     Yes   │            │
│           ▼               │           ▼            │           ▼            │
│  ┌─────────────────┐────▶│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ Remove from     │     │  │ Remove Venue    │──▶│  │ Remove Venue    │   │
│  │ Favorites       │     │  │ from Favorites  │   │  │ from List       │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │           │            │
│           ▼               │           ▼            │           ▼            │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ See Heart Icon  │     │  │ Update Heart    │◀──│  │ Update UI State │   │
│  │ Empty (Gray)    │     │  │ Icon to Empty   │   │  │                 │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│         ⚫ End            │         ⚫ End         │                        │
│                          │                        │                        │
│                          │                        │                        │
│    ⚫ Alternative Start   │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Navigate to     │────▶│  ┌─────────────────┐   │                        │
│  │ Favorites Page  │     │  │ Load Favorites  │   │                        │
│  └─────────────────┘     │  │ Screen          │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ View Favorites  │     │  │ Display         │◀──│  │ Retrieve        │   │
│  │ List            │     │  │ Favorites List  │   │  │ Favorites List  │   │
│  └─────────────────┘     │  └─────────────────┘   │  └─────────────────┘   │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│      ◆ List Empty?        │      ◆ Has Favorites?  │                        │
│           │               │           │            │                        │
│     Yes   ▼               │     No    ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ View Empty      │     │  │ Display Empty   │   │                        │
│  │ State Message   │     │  │ State           │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│         ⚫ End            │         ⚫ End         │                        │
a│                          │                        │                        │
│     No    │               │     Yes   │            │                        │
│           ▼               │           ▼            │                        │
│  ┌─────────────────┐     │  ┌─────────────────┐   │                        │
│  │ Browse Favorite │     │  │ Display Venue   │   │                        │
│  │ Venues          │     │  │ Cards           │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│  ┌─────────────────┐     │  ┌─────────────────┐   │                        │
│  │ Quick Book      │────▶│  │ Open Booking    │   │                        │
│  │ Venue           │     │  │ Dialog          │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│    [Continue with        │    [Continue with      │                        │
│     Booking Flow]        │     Booking Process]   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│         ⚫ End            │         ⚫ End         │                        │
│                          │                        │                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Manager Activity Flows

### Manager Dashboard Flow

```
                    MANAGER DASHBOARD ACTIVITY DIAGRAM
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  MANAGER                 │    APPLICATION         │    DATA LAYER          │
│                          │                        │                        │
│    ⚫ Start               │                        │                        │
│    │                     │                        │                        │
│    ▼                     │                        │                        │
│  ┌─────────────────┐     │                        │                        │
│  │ Login as        │────▶│  ┌─────────────────┐   │                        │
│  │ Manager         │     │  │ Authenticate    │   │                        │
│  └─────────────────┘     │  │ Manager         │   │                        │
│                          │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │                        │
│  │ Access Manager  │     │  │ Load Manager    │   │                        │
│  │ Dashboard       │     │  │ Dashboard       │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│                          │           │            │                        │
│                          │           ▼            │                        │
│                          │  ┌─────────────────┐   │  ┌─────────────────┐   │
│                          │  │ Load Dashboard  │──▶│  │ Fetch Today's   │   │
│                          │  │ Data            │   │  │ Bookings        │   │
│                          │  └─────────────────┘   │  └─────────────────┘   │
│                          │           │            │           │            │
│                          │           ▼            │           ▼            │
│  ┌─────────────────┐◀────│  ┌─────────────────┐   │  ┌─────────────────┐   │
│  │ View Dashboard  │     │  │ Display Quick   │◀──│  │ Calculate Quick │   │
│  │ Components:     │     │  │ Actions         │   │  │ Stats           │   │
│  │ - Quick Actions │     │  └─────────────────┘   │  └─────────────────┘   │
│  │ - Today's       │     │           │            │                        │
│  │   Bookings      │     │           ▼            │                        │
│  │ - Quick Stats   │     │  ┌─────────────────┐   │                        │
│  └─────────────────┘     │  │ Display Today's │   │                        │
│           │               │  │ Bookings        │   │                        │
│           ▼               │  └─────────────────┘   │                        │
│      ◆ User Action?       │           │            │                        │
│           │               │           ▼            │                        │
│                          │  ┌─────────────────┐   │                        │
│    Book Venue            │  │ Display Quick   │   │                        │
│           ▼               │  │ Stats           │   │                        │
│  ┌─────────────────┐────▶│  └─────────────────┘   │                        │
│  │ Click Book      │     │           │            │                        │
│  │ Venue Action    │     │           ▼            │                        │
│  └─────────────────┘     │  ┌─────────────────┐   │                        │
│           │               │  │ Show Coming     │   │                        │
│           ▼               │  │ Soon Message    │   │                        │
│  ┌─────────────────┐◀────│  └─────────────────┘   │                        │
│  │ See Coming Soon │     │           │            │                        │
│  │ Message         │     │           ▼            │                        │
│  └─────────────────┘     │         ⚫ End         │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
│    Future Bookings       │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐────▶│  ┌─────────────────┐   │                        │
│  │ Click Future    │     │  │ Show Coming     │   │                        │
│  │ Bookings Action │     │  │ Soon Message    │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│  ┌─────────────────┐◀────│         ⚫ End         │                        │
│  │ See Coming Soon │     │                        │                        │
│  │ Message         │     │                        │                        │
│  └─────────────────┘     │                        │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
│    Add Venue             │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐────▶│  ┌─────────────────┐   │                        │
│  │ Click Add       │     │  │ Show Coming     │   │                        │
│  │ Venue Action    │     │  │ Soon Message    │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│  ┌─────────────────┐◀────│         ⚫ End         │                        │
│  │ See Coming Soon │     │                        │                        │
│  │ Message         │     │                        │                        │
│  └─────────────────┘     │                        │                        │
│           │               │                        │                        │
│           ▼               │                        │                        │
│         ⚫ End            │                        │                        │
│                          │                        │                        │
│    View Analytics        │                        │                        │
│           ▼               │                        │                        │
│  ┌─────────────────┐────▶│  ┌─────────────────┐   │                        │
│  │ Switch to       │     │  │ Navigate to     │   │                        │
│  │ Analytics Tab   │     │  │ Analytics View  │   │                        │
│  └─────────────────┘     │  └─────────────────┘   │                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│    [Continue with        │    [Continue with      │                        │
│     Analytics Flow]      │     Analytics Process]│                        │
│           │               │           │            │                        │
│           ▼               │           ▼            │                        │
│         ⚫ End            │         ⚫ End         │                        │
│                          │                        │                        │
└─────────────────────────────────────────────────────────────────────────────┘
```### 