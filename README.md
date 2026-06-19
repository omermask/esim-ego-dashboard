# eSIM Ego Dashboard

**Admin dashboard** for the eSIM Ego platform — a Flutter app that manages eSIM plans, orders, users, payments, inventory, support tickets, financial reports, and system settings.

> ⚠️ **Work in Progress** — This application is actively developed and not yet feature-complete. Contributions are welcome to help build and improve it.

---

## Table of Contents

- [Overview](#overview)
- [Screenshots (Coming Soon)](#screenshots-coming-soon)
- [Features](#features)
- [Current State](#current-state)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Setup Backend Server](#setup-backend-server)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

---

## Overview

eSIM Ego Dashboard is a cross-platform (Android, iOS, Web, Linux, macOS, Windows) admin panel for managing an eSIM digital marketplace. It connects to the [eSIM Ego Server](https://github.com/omermask/esim-ego-server) API to provide full administrative control over the platform.

The app is built with **Flutter** and follows a **provider-based** architecture with a service layer for API communication. It supports Arabic and English interfaces with dark/light themes.

---

## Features

### ✅ Implemented
| Module | Features |
|---|---|
| **Authentication** | Phone OTP login, 2FA verification, token refresh, logout |
| **Dashboard** | Revenue charts (fl_chart), daily stats (orders, users, revenue, profit), recent orders, top plans |
| **Plans** | CRUD operations, provider catalogue sync, pricing management, inventory tracking, plan detail page |
| **Orders** | Paginated list with status filters, order details, approve/cancel actions, reprocess failed orders |
| **Users** | Paginated list with search, user details, ban/unban, role management, wallet view + adjust |
| **Support Tickets** | Ticket list with priority/status, chat view, send reply, open/close, assign to admin |
| **Payments** | Paginated payment list, confirm pending payments |
| **Coupons** | Coupon CRUD with AlertDialog forms |
| **Tax Rates** | Tax rate CRUD |
| **Refunds** | Refund list, create refund |
| **Referrals** | Referral stats (total, qualified, credited), reward list |
| **Freezes** | Wallet freeze list, create freeze, release freeze |
| **Audit Log** | Paginated admin action log with action/resource badges |
| **Reports** | Financial reports (daily/weekly/monthly), wallet dashboard |
| **Backups** | Backup list with status badges, create, cleanup, settings card |
| **2FA** | Setup (display secret), enable/disable with OTP code |
| **Exchange Rates** | Rate list, fetch now, set rate via AlertDialog |
| **System Settings** | Key-value settings CRUD |
| **Admin Activity** | Admin action log from AnalyticsProvider |
| **Wallet Dashboard** | Balance card with gradient, financial details |
| **Profile** | Admin info (name, phone, email, role) from AuthProvider |
| **Settings** | Language selection, dark mode toggle, server configuration |

### 🚧 In Progress / Missing
| Feature | Status |
|---|---|
| **Unit & Widget Tests** | Not yet written |
| **Push Notifications** | UI not connected |
| **User App (Customer-facing)** | Not started — needs separate Flutter app |
| **Charts on Home Tab** | Partially done, needs refinement |
| **i18n Translations** | Keys for new screens need completion |
| **CI/CD Pipeline** | Not configured |
| **End-to-End Testing** | Not implemented |
| **Error Handling Polish** | Basic implementation done |

---

## Requirements

- **Flutter** 3.24+ (SDK ^3.11.4)
- **Dart** 3.11+
- **Backend**: [eSIM Ego Server](https://github.com/omermask/esim-ego-server) running (see [Setup Backend Server](#setup-backend-server))
- **IDE**: Android Studio, VS Code, or IntelliJ

### Dependencies
| Package | Version | Purpose |
|---|---|---|
| `flutter_svg` | ^2.0.17 | SVG icon rendering |
| `go_router` | ^14.8.1 | Navigation / routing |
| `provider` | ^6.1.2 | State management |
| `http` | ^1.2.2 | HTTP client |
| `shared_preferences` | ^2.3.4 | Local storage |
| `google_fonts` | ^6.2.1 | Typography |
| `intl` | ^0.20.2 | Internationalization |
| `shimmer` | ^3.0.0 | Loading skeletons |
| `fl_chart` | ^0.70.2 | Charts & graphs |

---

## Quick Start

### 1. Clone

```bash
git clone https://github.com/omermask/esim-ego-dashboard.git
cd esim-ego-dashboard
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API

The app reads the server URL from `ApiService` configuration. By default it connects to `http://localhost:5000`. To change it:

- **Option A** — Edit `lib/data/services/api_service.dart` and update the base URL
- **Option B** — Run the app and navigate to **Settings → Server Settings** to change the URL at runtime

For production, set the URL to your deployed server (e.g. `https://api.esim-ego.com/api/v1`).

### 4. Run

```bash
# Android / iOS
flutter run

# Web
flutter run -d chrome

# Linux / Windows / macOS
flutter run -d linux
```

> **Note**: Android and iOS need a connected device or emulator. Web requires Chrome. Desktop requires the respective platform tools.

---

## Setup Backend Server

This app requires the [eSIM Ego Server](https://github.com/omermask/esim-ego-server) to be running.

```bash
git clone https://github.com/omermask/esim-ego-server.git
cd esim-ego-server

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure .env (copy from .env.example)
cp .env.example .env
# Edit .env with your database credentials

# Run migrations
alembic upgrade head

# Start the server
python run.py
```

The server will start at `http://localhost:5000`. You can then point the dashboard app to this URL.

---

## Project Structure

```
lib/
├── main.dart                          # App entry, 22 Provider registration
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # API URLs, timeouts, limits
│   │   └── app_icons.dart             # SVG icon path constants
│   ├── theme/
│   │   ├── app_colors.dart            # Color definitions
│   │   ├── app_colors_unified.dart    # Unified color palette
│   │   ├── app_theme.dart             # Light/dark theme data
│   │   ├── app_theme_ext.dart         # Theme extensions
│   │   └── theme_extensions.dart      # Additional theme props
│   ├── l10n/
│   │   └── app_localizations.dart     # Arabic/English translations
│   ├── utils/                         # 25+ utility modules
│   │   ├── toaster.dart               # Snackbar/toast helper
│   │   ├── responsive_size.dart       # Responsive sizing
│   │   ├── input_validators.dart      # Form validation
│   │   ├── date_formatter.dart        # Date/time formatting
│   │   └── ...                        # (clipboard, debounce, device info, etc.)
│   └── widgets/                       # 30+ reusable widgets
│       ├── custom_loader.dart         # Loading indicator
│       ├── empty_state.dart           # Empty list placeholder
│       ├── stat_cards_row.dart        # Stats card row
│       ├── filter_chips_row.dart      # Horizontal filter chips
│       └── ...                        # (buttons, cards, sheets, dialogs, etc.)
├── data/
│   ├── services/
│   │   └── api_service.dart           # HTTP client, all API endpoints (655 lines)
│   ├── models/                        # 18 data model files
│   │   ├── user_data.dart
│   │   ├── order_data.dart
│   │   ├── plan_data.dart
│   │   ├── wallet_data.dart
│   │   └── ...
│   └── providers/                     # 22 ChangeNotifier providers
│       ├── auth_provider.dart
│       ├── orders_provider.dart
│       ├── users_provider.dart
│       └── ...
└── screens/                           # 8 modules, 30+ screen files
    ├── login/                         # Phone entry, OTP, 2FA
    ├── dashboard/                     # Main dashboard + bottom nav tabs
    ├── plans/                         # Plan CRUD, catalogue, pricing, inventory
    ├── orders/                        # Order list + detail + exchange rates
    ├── users/                         # User list + detail (ban, wallet, activity)
    ├── support/                       # Ticket list + chat
    ├── more/                          # 14 sub-screens (payments, coupons, reports, etc.)
    └── settings/                      # Server configuration
```

### Key Files

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry point, registers 22 providers |
| `lib/data/services/api_service.dart` | All HTTP calls to the backend API (655 lines) |
| `lib/screens/dashboard/dashboard_screen.dart` | Main screen with bottom navigation (1807 lines) |
| `lib/screens/orders/order_list_widget.dart` | Order management with pagination |
| `lib/screens/users/user_list_widget.dart` | User management with ban/wallet features |
| `lib/screens/more/*.dart` | 14 admin sub-screens |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                          │
│  Screens (StatefulWidget) + Reusable Widgets         │
└─────────────────┬───────────────────────────────────┘
                  │  Provider.of<T>(context)
┌─────────────────▼───────────────────────────────────┐
│                Provider Layer                        │
│  22 ChangeNotifier providers (state + logic)         │
│  ─ AuthProvider, OrdersProvider, UsersProvider ...   │
└─────────────────┬───────────────────────────────────┘
                  │  calls methods
┌─────────────────▼───────────────────────────────────┐
│              Service Layer                           │
│  ApiService (HTTP client, token management,          │
│  error handling, request/response interceptors)      │
└─────────────────┬───────────────────────────────────┘
                  │  HTTP / JSON
┌─────────────────▼───────────────────────────────────┐
│           eSIM Ego Server (Backend API)               │
│  Flask + PostgreSQL + Redis + Celery                 │
└─────────────────────────────────────────────────────┘
```

### State Management

The app uses **Provider** with `ChangeNotifier` for state management. Each domain (auth, orders, users, plans, etc.) has its own provider that:

1. Holds the current state (data list, loading flag, error message)
2. Exposes methods to load, create, update, and delete data
3. Calls `ApiService` methods to communicate with the backend
4. Calls `notifyListeners()` to trigger UI rebuilds

### Navigation

The app uses **go_router** for declarative routing and a custom bottom navigation bar (`_TabInfo` pattern in `DashboardScreen`). Sub-screens within each tab use a `_subPage` integer state pattern to switch between grid views, list views, and detail views without leaving the tab.

### Data Flow

1. Screen calls `provider.loadData()` on init (via `addPostFrameCallback`)
2. Provider sets `loading = true`, calls `notifyListeners()`
3. Provider calls `ApiService.get()` or `ApiService.post()`
4. `ApiService` handles token injection, JSON parsing, error mapping
5. On success: provider updates data, sets `loading = false`, notifies listeners
6. On error: provider sets `error` message, sets `loading = false`, notifies listeners
7. Screen rebuilds to show data, loader, or error state

### Infinite Scroll

All list screens use `NotificationListener<ScrollNotification>` to detect when the user scrolls to the bottom, triggering the next page load. Combined with `RefreshIndicator` for pull-to-refresh.

---

## Contributing

This project needs your help to reach production quality. Here's how you can contribute:

### What Needs Work

| Area | Priority | Description |
|---|---|---|
| **Tests** | High | Unit tests for providers, widget tests for screens |
| **User App** | High | Build a customer-facing Flutter app using the public API |
| **i18n** | Medium | Complete translation keys for all new screens |
| **Error Handling** | Medium | Polish error messages and retry logic |
| **Charts** | Medium | Improve dashboard charts with more data points |
| **CI/CD** | Medium | GitHub Actions for build + test |
| **Documentation** | Low | Code comments, API integration guide |
| **Performance** | Low | Optimize list rendering, lazy loading |

### Getting Started

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/your-feature`)
3. **Make your changes** following the existing patterns
4. **Run analysis** (`flutter analyze`) — ensure 0 errors, 0 warnings
5. **Commit** (`git commit -m 'Add your feature'`)
6. **Push** (`git push origin feature/your-feature`)
7. **Open a Pull Request**

### Development Guidelines

- Follow existing code style (Provider pattern, service layer, type safety)
- Use `flutter_svg` for icons (not PNGs)
- New screens should use the `_subPage` pattern for tab-local navigation
- Forms should use `AlertDialog` (not separate pages)
- List screens should support pagination + pull-to-refresh
- Run `flutter analyze` before committing

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author

**omer jasim** — [oj33593@gmail.com](mailto:oj33593@gmail.com)
