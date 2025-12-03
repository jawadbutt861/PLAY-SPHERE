# PlaySphere - Complete Application Activity Diagram

## Overview
This document presents a comprehensive single activity diagram showing the entire PlaySphere application flow, from startup through all major features including authentication, venue booking, tournament management, and manager operations.

---

## Complete Application Activity Diagram

```
                    PLAYSPHERE COMPLETE APPLICATION FLOW
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  USER/ACTOR          │    APPLICATION         │    FIREBASE/DATA           │
│                      │                        │                            │
│    ⚫ START APP       │                        │                            │
│    │                 │                        │                            │
│    ▼                 │                        │                            │
│  ┌───────────────┐   │                        │                            │
│  │ Open App      │──▶│  ┌───────────────┐     │  ┌───────────────┐         │
│  └───────────────┘   │  │ Initialize    │────▶│  │ Firebase Init │         │
│                      │  │ Flutter App   │     │  └───────────────┘         │
│                      │  └───────────────┘     │         │                  │
│                      │         │              │         ▼                  │
│                      │         ▼              │  ┌───────────────┐         │
│                      │  ┌───────────────┐     │  │ Check Auth    │         │
│                      │  │ Check Auth    │◀────│  │ State         │         │
│                      │  │ Status        │     │  └───────────────┘         │
│                      │  └───────────────┘     │                            │
│                      │         │              │                            │
│                      │         ▼              │                            │
│                      │    ◆ Authenticated?    │                            │
│                      │         │              │                            │
│              YES ────┼─────────┼──────────────┼────────────┐               │
│                      │         │              │            │               │
│                      │         ▼              │            ▼               │
│  ┌───────────────┐   │  ┌───────────────┐     │     ◆ User Role?          │
│  │ Go to         │◀──│  │ Route to      │     │            │               │
│  │ Dashboard     │   │  │ Dashboard     │     │            │               │
│  └───────────────┘   │  └───────────────┘     │    Player  │  Manager     │
│         │             │                        │            │               │
│         └─────────────┼────────────────────────┼────────────┘               │
│                      │                        │                            │
│              NO  ────┼─────────┐              │                            │
│                      │         ▼              │                            │
│  ┌───────────────┐   │  ┌───────────────┐     │                            │
│  │ View Splash   │◀──│  │ Show Splash   │     │                            │
│  │ Screen        │   │  │ Screen (3s)   │     │                            │
│  └───────────────┘   │  └───────────────┘     │                            │
│         │             │         │              │                            │
│         ▼             │         ▼              │                            │
│  ┌───────────────┐   │  ┌───────────────┐     │                            │
│  │ View Role     │◀──│  │ Navigate to   │     │                            │
│  │ Selection     │   │  │ Role Screen   │     │                            │
│  └───────────────┘   │  └───────────────┘     │                            │
│         │             │                        │                            │
│         ▼             │                        │                            │
│    ◆ Select Role?     │                        │                            │
│         │             │                        │                            │
│    Player │  Manager  │                        │                            │
│         │             │                        │                            │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    PLAYER AUTHENTICATION PATH                        │   │
│  │                                                                      │   │
│  │  ┌───────────────┐   │  ┌───────────────┐     │                     │   │
│  │  │ Choose Player │──▶│  │ Navigate to   │     │                     │   │
│  │  │ Role          │   │  │ Player Auth   │     │                     │   │
│  │  └───────────────┘   │  └───────────────┘     │                     │   │
│  │         │             │         │              │                     │   │
│  │         ▼             │         ▼              │                     │   │
│  │    ◆ Has Account?     │    ◆ Login/Signup?    │                     │   │
│  │         │             │         │              │                     │   │
│  │    Login │  Signup    │         │              │                     │   │
│  │         │             │         │              │                     │   │
│  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌───────────────┐  │   │
│  │  │ Enter Email & │──▶│  │ Validate      │────▶│  │ Firebase Auth │  │   │
│  │  │ Password      │   │  │ Credentials   │     │  │ Sign In       │  │   │
│  │  └───────────────┘   │  └───────────────┘     │  └───────────────┘  │   │
│  │         │             │         │              │         │           │   │
│  │         │             │         ▼              │         ▼           │   │
│  │         │             │    ◆ Valid?            │    ◆ Success?       │   │
│  │         │             │         │              │         │           │   │
│  │         │        NO ──┼─────────┘              │    NO ──┘           │   │
│  │         │             │         │              │         │           │   │
│  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌───────────────┐  │   │
│  │  │ Show Error    │◀──│  │ Display Error │◀────│  │ Return Error  │  │   │
│  │  └───────────────┘   │  └───────────────┘     │  └───────────────┘  │   │
│  │         │             │                        │                     │   │
│  │         └─────────────┼────────────────────────┼─────────┐           │   │
│  │                      │                        │         │           │   │
│  │                 YES ─┼────────────────────────┼─────────┘           │   │
│  │                      │         │              │         │           │   │
│  │                      │         ▼              │         ▼           │   │
│  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌───────────────┐  │   │
│  │  │ Access Player │◀──│  │ Create Session│◀────│  │ Return Token  │  │   │
│  │  │ Dashboard     │   │  │ & Route       │     │  └───────────────┘  │   │
│  │  └───────────────┘   │  └───────────────┘     │                     │   │
│  │         │             │                        │                     │   │
│  └──────────┼────────────────────────────────────────────────────────────┘   │
│             │             │                        │                         │
│             ▼             │                        │                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    PLAYER MAIN FEATURES                              │   │
│  │                                                                      │   │
│  │    ◆ Select Feature?  │                        │                     │   │
│  │         │             │                        │                     │   │
│  │  Browse │ Favorites │ Bookings │ Tournament │ Profile               │   │
│  │         │             │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              VENUE BROWSING & BOOKING                        │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Browse Venues │──▶│  │ Load Venues   │     │             │   │   │
│  │  │  │ by Category   │   │  │ by Category   │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Select Venue  │──▶│  │ Open Booking  │     │             │   │   │
│  │  │  │ to Book       │   │  │ Dialog        │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Select Date   │──▶│  │ Validate Date │     │             │   │   │
│  │  │  │ (Tomorrow to  │   │  │ Range         │     │             │   │   │
│  │  │  │  30 days)     │   │  └───────────────┘     │             │   │   │
│  │  │  └───────────────┘   │         │              │             │   │   │
│  │  │         │             │         ▼              │             │   │   │
│  │  │         ▼             │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  ┌───────────────┐   │  │ Check Slot    │────▶│  │ Global │ │   │   │
│  │  │  │ View Available│◀──│  │ Availability  │     │  │ Data   │ │   │   │
│  │  │  │ Time Slots    │   │  └───────────────┘     │  └────────┘ │   │   │
│  │  │  └───────────────┘   │         │              │             │   │   │
│  │  │         │             │         ▼              │             │   │   │
│  │  │         ▼             │  ┌───────────────┐     │             │   │   │
│  │  │  ┌───────────────┐   │  │ Display Slots │     │             │   │   │
│  │  │  │ Select Slot & │──▶│  │ with Status   │     │             │   │   │
│  │  │  │ Payment Method│   │  │ (Available/   │     │             │   │   │
│  │  │  └───────────────┘   │  │  Booked/      │     │             │   │   │
│  │  │         │             │  │  Tournament)  │     │             │   │   │
│  │  │         ▼             │  └───────────────┘     │             │   │   │
│  │  │  ┌───────────────┐   │         │              │             │   │   │
│  │  │  │ Confirm       │──▶│         ▼              │             │   │   │
│  │  │  │ Booking       │   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  └───────────────┘   │  │ Process       │────▶│  │ Update │ │   │   │
│  │  │         │             │  │ Booking       │     │  │ Slots  │ │   │   │
│  │  │         ▼             │  └───────────────┘     │  └────────┘ │   │   │
│  │  │  ┌───────────────┐   │         │              │      │      │   │   │
│  │  │  │ View Booking  │◀──│         ▼              │      ▼      │   │   │
│  │  │  │ Confirmation  │   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  └───────────────┘   │  │ Add to Booking│────▶│  │ Store  │ │   │   │
│  │  │                      │  │ History       │     │  │ Booking│ │   │   │
│  │  │                      │  └───────────────┘     │  └────────┘ │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                      │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              FAVORITES MANAGEMENT                            │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ Tap Heart Icon│──▶│  │ Toggle        │────▶│  │ Update │ │   │   │
│  │  │  │ on Venue      │   │  │ Favorite      │     │  │ List   │ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │  └────────┘ │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ View Favorites│──▶│  │ Display       │     │             │   │   │
│  │  │  │ Page          │   │  │ Favorites List│     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                      │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              TOURNAMENT MANAGEMENT                           │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Create        │──▶│  │ Open          │     │             │   │   │
│  │  │  │ Tournament    │   │  │ Tournament    │     │             │   │   │
│  │  │  │               │   │  │ Form          │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Enter Details:│──▶│  │ Validate Form │     │             │   │   │
│  │  │  │ - Name        │   │  │ Data          │     │             │   │   │
│  │  │  │ - Sport       │   │  └───────────────┘     │             │   │   │
│  │  │  │ - Format      │   │         │              │             │   │   │
│  │  │  │ - Teams       │   │         ▼              │             │   │   │
│  │  │  │ - Dates       │   │    ◆ Valid?            │             │   │   │
│  │  │  └───────────────┘   │         │              │             │   │   │
│  │  │         │             │    YES  │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Book Grounds  │──▶│  │ Select Venues │     │             │   │   │
│  │  │  │ for Tournament│   │  │ & Slots       │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ Generate      │──▶│  │ Create        │────▶│  │ Store  │ │   │   │
│  │  │  │ Fixtures      │   │  │ Fixtures      │     │  │ Matches│ │   │   │
│  │  │  │               │   │  │ (Round Robin/ │     │  └────────┘ │   │   │
│  │  │  │               │   │  │  Knockout)    │     │      │      │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │      ▼      │   │   │
│  │  │         │             │         │              │  ┌────────┐ │   │   │
│  │  │         ▼             │         ▼              │  │ Reserve│ │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  │ Slots  │ │   │   │
│  │  │  │ View          │◀──│  │ Display       │     │  └────────┘ │   │   │
│  │  │  │ Tournament    │   │  │ Tournament    │     │             │   │   │
│  │  │  │ Details       │   │  │ Schedule      │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Update Match  │──▶│  │ Enter Match   │     │             │   │   │
│  │  │  │ Results       │   │  │ Scores &      │     │             │   │   │
│  │  │  │               │   │  │ Winner        │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ View Points   │◀──│  │ Calculate     │────▶│  │ Update │ │   │   │
│  │  │  │ Table         │   │  │ Points        │     │  │ Points │ │   │   │
│  │  │  │               │   │  │ (Win:3,Draw:1)│     │  └────────┘ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                      │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              PROFILE MANAGEMENT                              │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ View Profile  │──▶│  │ Display User  │     │             │   │   │
│  │  │  │               │   │  │ Information   │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │    ◆ Action?          │    ◆ Update Type?     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │  Update Image         │  Change Password      │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ Select Image  │──▶│  │ Save Image    │────▶│  │ Shared │ │   │   │
│  │  │  │ from Gallery  │   │  │ Path          │     │  │ Prefs  │ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │  └────────┘ │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         │             │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │         │             │  │ Update        │────▶│  │Firebase│ │   │   │
│  │  │         │             │  │ Password      │     │  │ Auth   │ │   │   │
│  │  │         │             │  └───────────────┘     │  └────────┘ │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Logout        │──▶│  │ Sign Out &    │     │             │   │   │
│  │  │  │               │   │  │ Clear Session │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                      │                        │                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    MANAGER AUTHENTICATION PATH                       │   │
│  │                                                                      │   │
│  │  ┌───────────────┐   │  ┌───────────────┐     │                     │   │
│  │  │ Choose Manager│──▶│  │ Navigate to   │     │                     │   │
│  │  │ Role          │   │  │ Manager Auth  │     │                     │   │
│  │  └───────────────┘   │  └───────────────┘     │                     │   │
│  │         │             │         │              │                     │   │
│  │         ▼             │         ▼              │                     │   │
│  │    ◆ Has Account?     │    ◆ Login/Signup?    │                     │   │
│  │         │             │         │              │                     │   │
│  │    Signup             │         │              │                     │   │
│  │         │             │         │              │                     │   │
│  │  ┌───────────────┐   │  ┌───────────────┐     │                     │   │
│  │  │ Enter Details:│──▶│  │ Validate Form │     │                     │   │
│  │  │ - Name        │   │  │ Data          │     │                     │   │
│  │  │ - Email       │   │  └───────────────┘     │                     │   │
│  │  │ - CNIC        │   │         │              │                     │   │
│  │  │ - Mobile      │   │         ▼              │                     │   │
│  │  │ - Password    │   │    ◆ Valid?            │                     │   │
│  │  │ - Venue Info  │   │         │              │                     │   │
│  │  │ - Images(1-5) │   │    YES  │              │                     │   │
│  │  └───────────────┘   │         ▼              │                     │   │
│  │         │             │  ┌───────────────┐     │  ┌───────────────┐ │   │
│  │         ▼             │  │ Create Manager│────▶│  │ Firebase Auth │ │   │
│  │  ┌───────────────┐   │  │ Account       │     │  │ Create User   │ │   │
│  │  │ Submit Form   │──▶│  └───────────────┘     │  └───────────────┘ │   │
│  │  └───────────────┘   │         │              │         │          │   │
│  │         │             │         ▼              │         ▼          │   │
│  │         ▼             │  ┌───────────────┐     │    ◆ Success?     │   │
│  │  ┌───────────────┐   │  │ Navigate to   │     │         │          │   │
│  │  │ Access Manager│◀──│  │ Manager Login │     │    YES  │          │   │
│  │  │ Login         │   │  └───────────────┘     │         ▼          │   │
│  │  └───────────────┘   │                        │  ┌───────────────┐ │   │
│  │         │             │                        │  │ Return Success│ │   │
│  │         ▼             │                        │  └───────────────┘ │   │
│  │    [Login Flow]       │                        │                   │   │
│  └──────────┼────────────────────────────────────────────────────────────┘   │
│             │             │                        │                         │
│             ▼             │                        │                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    MANAGER MAIN FEATURES                             │   │
│  │                                                                      │   │
│  │    ◆ Select Feature?  │                        │                     │   │
│  │         │             │                        │                     │   │
│  │  Dashboard │ Analytics │ Profile                                     │   │
│  │         │             │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              MANAGER DASHBOARD                               │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ View Dashboard│──▶│  │ Load Dashboard│     │             │   │   │
│  │  │  │               │   │  │ Components    │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ View:         │◀──│  │ Display:      │◀────│  │ Fetch  │ │   │   │
│  │  │  │ - Quick       │   │  │ - Quick       │     │  │ Today's│ │   │   │
│  │  │  │   Actions     │   │  │   Actions     │     │  │ Data   │ │   │   │
│  │  │  │ - Today's     │   │  │ - Today's     │     │  └────────┘ │   │   │
│  │  │  │   Bookings    │   │  │   Bookings    │     │             │   │   │
│  │  │  │ - Quick Stats │   │  │ - Quick Stats │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │    ◆ Action?          │    ◆ Quick Action?     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │  Book Venue           │  Future Bookings       │  Add Venue  │   │   │
│  │  │         │             │         │              │      │      │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │      │      │   │   │
│  │  │  │ Click Action  │──▶│  │ Show "Coming  │     │      │      │   │   │
│  │  │  │ Button        │   │  │ Soon" Message │     │      │      │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │      │      │   │   │
│  │  │         │             │         │              │      │      │   │   │
│  │  │         ▼             │         ▼              │      ▼      │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ View Message  │◀──│  │ Display       │     │  │ Future │ │   │   │
│  │  │  │               │   │  │ Snackbar      │     │  │ Feature│ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │  └────────┘ │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                      │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              MANAGER ANALYTICS                               │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Switch to     │──▶│  │ Navigate to   │     │             │   │   │
│  │  │  │ Analytics Tab │   │  │ Analytics View│     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ View Analytics│◀──│  │ Load Analytics│◀────│  │ Fetch  │ │   │   │
│  │  │  │ Dashboard     │   │  │ Data          │     │  │ Booking│ │   │   │
│  │  │  │               │   │  └───────────────┘     │  │ Data   │ │   │   │
│  │  │  └───────────────┘   │         │              │  └────────┘ │   │   │
│  │  │         │             │         ▼              │      │      │   │   │
│  │  │         ▼             │  ┌───────────────┐     │      ▼      │   │   │
│  │  │  ┌───────────────┐   │  │ Display:      │     │  ┌────────┐ │   │   │
│  │  │  │ View:         │◀──│  │ - Stats Cards │◀────│  │Calculate│ │   │   │
│  │  │  │ - Stats Cards │   │  │ - Revenue     │     │  │ Stats  │ │   │   │
│  │  │  │ - Revenue     │   │  │   Chart       │     │  └────────┘ │   │   │
│  │  │  │   Trends      │   │  │ - Booking     │     │             │   │   │
│  │  │  │ - Booking     │   │  │   Chart       │     │             │   │   │
│  │  │  │   Statistics  │   │  └───────────────┘     │             │   │   │
│  │  │  └───────────────┘   │         │              │             │   │   │
│  │  │         │             │         ▼              │             │   │   │
│  │  │         ▼             │  ┌───────────────┐     │             │   │   │
│  │  │  ┌───────────────┐   │  │ Select Period │     │             │   │   │
│  │  │  │ Select Period │──▶│  │ (Weekly/      │     │             │   │   │
│  │  │  │ Filter        │   │  │  Monthly/     │     │             │   │   │
│  │  │  │               │   │  │  Yearly)      │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ View Updated  │◀──│  │ Update Charts │◀────│  │ Filter │ │   │   │
│  │  │  │ Charts        │   │  │ with Period   │     │  │ Data   │ │   │   │
│  │  │  │               │   │  │ Data          │     │  └────────┘ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ Analyze:      │   │  │ Display:      │     │             │   │   │
│  │  │  │ - Revenue     │   │  │ - Line Chart  │     │             │   │   │
│  │  │  │   Trends      │   │  │   (Revenue)   │     │             │   │   │
│  │  │  │ - Booking     │   │  │ - Bar Chart   │     │             │   │   │
│  │  │  │   Patterns    │   │  │   (Bookings)  │     │             │   │   │
│  │  │  │ - Performance │   │  │ - Metrics     │     │             │   │   │
│  │  │  │   Metrics     │   │  │   Cards       │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                      │                        │                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              MANAGER PROFILE                                 │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │             │   │   │
│  │  │  │ View Profile  │──▶│  │ Display       │     │             │   │   │
│  │  │  │               │   │  │ Manager Info  │     │             │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │             │   │   │
│  │  │    ◆ Action?          │    ◆ Update Type?     │             │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │  Update Image         │  Change Password      │  Logout     │   │   │
│  │  │         │             │         │              │      │      │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ Select & Save │──▶│  │ Update in     │────▶│  │ Shared │ │   │   │
│  │  │  │ Image         │   │  │ Storage       │     │  │ Prefs  │ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │  └────────┘ │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         │             │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │         │             │  │ Update        │────▶│  │Firebase│ │   │   │
│  │  │         │             │  │ Password      │     │  │ Auth   │ │   │   │
│  │  │         │             │  └───────────────┘     │  └────────┘ │   │   │
│  │  │         │             │         │              │             │   │   │
│  │  │         ▼             │         ▼              │      ▼      │   │   │
│  │  │  ┌───────────────┐   │  ┌───────────────┐     │  ┌────────┐ │   │   │
│  │  │  │ Logout        │──▶│  │ Sign Out &    │────▶│  │ Clear  │ │   │   │
│  │  │  │               │   │  │ Navigate to   │     │  │ Session│ │   │   │
│  │  │  │               │   │  │ Role Screen   │     │  └────────┘ │   │   │
│  │  │  └───────────────┘   │  └───────────────┘     │             │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                      │                        │                             │
│                      │                        │                             │
│                      ▼                        ▼                             │
│                    ⚫ END                    ⚫ END                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Activity Flow Summary

### Key Application Flows

1. **Startup Flow**
   - App initialization → Firebase setup → Auth check → Route to appropriate screen

2. **Authentication Flow**
   - Role selection → Login/Signup → Validation → Firebase authentication → Dashboard access

3. **Player Flows**
   - **Venue Booking:** Browse → Select → Date/Slot → Payment → Confirm
   - **Favorites:** Toggle heart icon → Update favorites list
   - **Tournament:** Create → Book grounds → Generate fixtures → Manage matches → View standings
   - **Profile:** View → Update image/password → Logout

4. **Manager Flows**
   - **Dashboard:** View quick actions → Today's bookings → Quick stats
   - **Analytics:** View charts → Filter by period → Analyze trends
   - **Profile:** View → Update settings → Logout

### Decision Points

- **◆ Authenticated?** - Determines if user goes to dashboard or role selection
- **◆ User Role?** - Routes to Player or Manager dashboard
- **◆ Has Account?** - Directs to Login or Signup
- **◆ Form Valid?** - Validates input before processing
- **◆ Slot Available?** - Checks booking conflicts
- **◆ Action Type?** - Determines which feature to execute

### Data Interactions

- **Firebase Auth:** User authentication and session management
- **Global Data:** In-memory storage for bookings, tournaments, favorites
- **Shared Preferences:** Local storage for profile images
- **Future Firestore:** Cloud database for persistent data

### Error Handling

- Validation errors → Display error messages → Return to input
- Authentication failures → Show error → Retry option
- Booking conflicts → Display unavailable status → Select different slot
- Network errors → Show error message → Retry mechanism

---

## Diagram Conventions

**Symbols Used:**
- ⚫ **Start/End:** Entry and exit points
- ◆ **Decision:** Conditional branching
- ┌─┐ **Process:** Activity or action
- ──▶ **Flow:** Direction of process
- │ **Swim Lane:** Separates actors/systems

**Swim Lanes:**
- **USER/ACTOR:** User interactions and views
- **APPLICATION:** App logic and processing
- **FIREBASE/DATA:** Backend services and data storage

---

## Notes

- This diagram represents the complete application flow as of the current implementation
- Future features (marked as "Coming Soon") are placeholders for planned functionality
- The diagram follows a left-to-right, top-to-bottom flow pattern
- All major features and user journeys are included in this comprehensive view
- Data persistence currently uses in-memory storage (GlobalData) and local storage (SharedPreferences)
- Future implementation will integrate Firebase Firestore for cloud-based data persistence

---

**Document Version:** 1.0  
**Last Updated:** December 1, 2024  
**Status:** Complete
