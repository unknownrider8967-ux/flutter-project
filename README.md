# SyncSphere — Collaborative Event Planning Hub

A Flutter app for collaborative event planning with guest management, task tracking, budget monitoring, and a calendar view — all backed by a local SQLite database.

---

## Features

| Module | Screens |
|---|---|
| Onboarding & Auth | 3 onboarding slides, sign up, log in, forgot password, persistent sessions |
| Event Dashboard | Event list, create/edit event, event detail overview |
| Guest Management | Guest list with RSVP filter & search, add/edit guest, RSVP status updates |
| Task Management | Task board with status/priority filters, add/edit task, completion progress |
| Budget Tracking | Budget summary, income/expense entries, analytics pie chart |
| Calendar | Calendar view wired to real event data |
| Profile & Settings | Theme toggle (light/dark), log out, about |

## Tech Stack

- **Flutter** — UI framework
- **Provider** — state management
- **sqflite** — local SQLite persistence
- **shared_preferences** — session & seed flag storage
- **table_calendar** — calendar widget
- **fl_chart** — budget analytics chart
- **crypto** — local password hashing

---

## Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.0.0 (tested on 3.x)
- Dart SDK ≥ 3.0.0

### Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on connected device / emulator
flutter run

# 3. Run on web
flutter run -d chrome

# 4. Run tests
flutter test
```

The app seeds sample data (3 events with guests, tasks, and budget entries) on first launch via `SeedService`.

---

## Project Structure

```
lib/
├── core/
│   ├── theme/          # DesignTokens, ThemeProvider
│   └── widgets/        # SyncSphereButton, SyncSphereCard, SyncSphereInputField, EmptyStateWidget
├── data/
│   ├── models/         # Event, Guest, Task, BudgetEntry, AppUser
│   └── services/       # DatabaseService (SQLite), SeedService
└── presentation/
    ├── auth/           # Splash, Onboarding, Login, SignUp, ForgotPassword + AuthProvider
    ├── dashboard/      # Dashboard, CreateEvent, EventDetail + EventProvider
    ├── guest/          # GuestList, AddEditGuest + GuestProvider
    ├── task/           # TaskList, AddEditTask + TaskProvider
    ├── budget/         # BudgetScreen (entries + chart), AddEditBudget + BudgetProvider
    ├── calendar/       # CalendarScreen
    ├── notification/   # NotificationScreen
    └── profile/        # ProfileScreen
```

---

## Authentication

Authentication is **local-only** (no Firebase required). Accounts are stored as hashed credentials in `SharedPreferences`. The "Continue with Google" button creates a local demo account for quick testing.

---

## Data Persistence

All user-created data (events, guests, tasks, budget entries) is stored in a local SQLite database via `sqflite`. Data survives app restarts.
