# Technica Task – Flutter E-Commerce App

A production-ready Flutter e-commerce application built with Clean Architecture, Cubit state management, offline support, and a modern Material 3 UI.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [State Management](#state-management)
- [Tech Stack](#tech-stack)
- [UI / UX](#ui--ux)
- [App Flavors](#app-flavors)
- [Getting Started](#getting-started)
- [Demo Credentials](#demo-credentials)
- [Testing](#testing)
- [Error Handling](#error-handling)
- [Dependency Injection](#dependency-injection)

---

## Features

### Authentication
- Login with username & password via [Fake Store API](https://fakestoreapi.com)
- Local demo account (`mohamed` / `0000`) that works without an API call
- Secure token storage using `flutter_secure_storage`
- Auto-login on app launch if a valid token is stored
- Logout with a confirmation dialog

### Products
- Product listing from [Fake Store API](https://fakestoreapi.com/products) displayed in a grid
- Image caching with `cached_network_image`
- Instant search by product name or category
- Pagination / lazy loading
- Pull-to-refresh
- UI states: shimmer loading, empty, error, offline

### Product Detail
- Full detail screen with an expandable image (SliverAppBar)
- Hero animation for product images
- Price, rating, and description display
- Sticky bottom bar with "Add to Cart" button

### Favorites
- Add/remove favorites with a single tap and animated heart icon
- Persistent local storage (SharedPreferences)
- Favorites page with swipe-to-remove

### Cart
- Add products to cart from anywhere in the app
- Quantity controls (+/-)
- Swipe-to-delete items
- Sticky bottom bar showing total price and a Checkout button
- Badge on the cart icon showing the item count

### Offline Support
- Product list cache with a 24-hour expiry
- When offline, cached data is shown with a "Showing cached data" banner
- Clear error handling for network issues

---

## Architecture

The project follows **Clean Architecture** with a feature-based structure:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                   │
│          (Pages, Widgets, Cubits / States)            │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                       │
│       (Entities, Repository Interfaces, Use Cases)    │
├─────────────────────────────────────────────────────┤
│                     Data Layer                        │
│   (Repository Impl, Remote / Local Data Sources,     │
│                     Models)                           │
└─────────────────────────────────────────────────────┘
```

### How the layers work together

```
UI (Widget) → Cubit → UseCase → Repository (interface) → DataSource
                                      ↑
                              Repository (implementation)
                              ├── RemoteDataSource (Dio / API)
                              └── LocalDataSource (SharedPreferences / SecureStorage)
```

**Why Clean Architecture?**
- **Separation of concerns**: each layer has a single, clear responsibility
- **Testability**: any layer can be easily mocked
- **Flexibility**: swap the API or database without touching the UI
- **Repository Pattern**: all data access goes through repositories — the Domain layer is agnostic of data sources

---

## Project Structure

```
lib/
├── core/                              # Shared code
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants (keys, timeouts, page size)
│   ├── di/
│   │   └── injection.dart             # Dependency Injection (GetIt)
│   ├── env/
│   │   └── app_env.dart               # Flavor configuration (dev / prod)
│   ├── errors/
│   │   └── app_exceptions.dart        # Custom exceptions (Server, Auth, Offline, Cache, Timeout)
│   ├── network/
│   │   └── dio_client.dart            # Centralized Dio client (timeouts, headers, error mapping)
│   └── theme/
│       ├── app_colors.dart            # Color palette + gradients
│       └── app_theme.dart             # Light / Dark themes (Material 3 + Google Fonts)
│
├── features/
│   ├── auth/                          # ── Authentication Feature ──
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart       # Interface
│   │   │   │   ├── auth_remote_datasource_impl.dart  # Implementation (Dio + demo login)
│   │   │   │   ├── auth_local_datasource.dart        # Interface
│   │   │   │   └── auth_local_datasource_impl.dart   # Implementation (SecureStorage)
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── auth_user.dart                    # Entity: AuthUser(token)
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart              # Interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── check_auth_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── products/                      # ── Products Feature ──
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── products_remote_datasource.dart
│   │   │   │   ├── products_remote_datasource_impl.dart  # Fetches from API
│   │   │   │   ├── products_local_datasource.dart
│   │   │   │   └── products_local_datasource_impl.dart   # Local cache
│   │   │   ├── models/
│   │   │   │   └── product_model.dart                    # JSON ↔ Entity mapping
│   │   │   └── repositories/
│   │   │       └── products_repository_impl.dart         # Cache-first strategy
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product.dart                          # Entity: Product + ProductRating
│   │   │   ├── repositories/
│   │   │   │   └── products_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_products_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── products_cubit.dart
│   │       │   └── products_state.dart
│   │       └── pages/
│   │           ├── products_list_page.dart                # Product grid + search
│   │           ├── product_detail_page.dart               # Product details
│   │           ├── cart_page.dart                         # Cart page
│   │           ├── favorites_page.dart                    # Favorites page
│   │           ├── main_shell.dart                        # Bottom nav bar + tab management
│   │           └── products_shell.dart                    # Wrapper
│   │
│   ├── favorites/                     # ── Favorites Feature ──
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── favorites_local_datasource.dart
│   │   │   │   └── favorites_local_datasource_impl.dart  # SharedPreferences
│   │   │   └── repositories/
│   │   │       └── favorites_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository.dart
│   │   │   └── usecases/
│   │   │       └── favorites_usecases.dart               # GetIds, Toggle, IsFavorite
│   │   └── presentation/
│   │       └── cubit/
│   │           ├── favorites_cubit.dart
│   │           └── favorites_state.dart
│   │
│   └── cart/                          # ── Cart Feature ──
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── cart_local_datasource.dart
│       │   │   └── cart_local_datasource_impl.dart       # SharedPreferences
│       │   └── repositories/
│       │       └── cart_repository_impl.dart
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── cart_repository.dart
│       │   └── usecases/
│       │       └── cart_usecases.dart                    # Get, Add, Remove, UpdateQty
│       └── presentation/
│           └── cubit/
│               ├── cart_cubit.dart
│               └── cart_state.dart                       # items: Map<productId, quantity>
│
├── main.dart                          # Default entry point (prod)
├── main_dev.dart                      # Dev flavor entry point
└── main_prod.dart                     # Prod flavor entry point
```

---

## State Management

The app uses **Cubit** from `flutter_bloc` for all state management:

### AuthCubit
| State | Description |
|-------|-------------|
| `AuthStateInitial` | Initial state |
| `AuthStateLoading` | Logging in or checking stored token |
| `AuthStateAuthenticated(user)` | User is logged in (holds AuthUser) |
| `AuthStateUnauthenticated` | Not logged in / logged out |
| `AuthStateError(message)` | Login error |

### ProductsCubit
| State | Description |
|-------|-------------|
| `ProductsStateInitial` | Initial state |
| `ProductsStateLoading` | Fetching products |
| `ProductsStateLoaded(products, hasMore, isOffline)` | Loaded with pagination and offline support |
| `ProductsStateEmpty` | No products available |
| `ProductsStateError(message, isOffline)` | Error with offline indicator |

### FavoritesCubit
| State | Description |
|-------|-------------|
| `FavoritesStateInitial` | Initial state |
| `FavoritesStateLoaded(ids)` | Set of favorite product IDs |

### CartCubit
| State | Description |
|-------|-------------|
| `CartStateInitial` | Initial state |
| `CartStateLoaded(items)` | Cart items as `Map<productId, quantity>` |

**Key principles:**
- Cubits call Use Cases only (they don't know the data source)
- No business logic in Widgets
- `BlocBuilder` is scoped to avoid unnecessary rebuilds

---

## Tech Stack

| Package | Purpose | Version |
|---------|---------|---------|
| `flutter_bloc` | State management (Cubit) | ^8.1.6 |
| `equatable` | Value equality for States & Entities | ^2.0.5 |
| `dio` | HTTP client with error mapping | ^5.7.0 |
| `get_it` | Dependency injection | ^8.0.2 |
| `flutter_secure_storage` | Secure token storage | ^9.2.2 |
| `shared_preferences` | Local storage for favorites, cart, cache | ^2.3.3 |
| `connectivity_plus` | Network connectivity checks | ^6.0.5 |
| `cached_network_image` | Image caching | ^3.4.1 |
| `google_fonts` | Inter font for modern typography | ^8.0.1 |

### Dev Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| `flutter_test` | Widget testing | SDK |
| `bloc_test` | Cubit testing | ^9.1.7 |
| `mocktail` | Mock generation | ^1.0.4 |
| `flutter_lints` | Lint rules | ^6.0.0 |

---

## UI / UX

### Theme System
- **Material 3** enabled with `ColorScheme.fromSeed`
- **Light / Dark mode** support (follows system settings automatically)
- **Google Fonts (Inter)** for clean, modern typography
- Primary color: `#6C5CE7` (Indigo-Violet)

### Design Elements

| Element | Details |
|---------|---------|
| **Bottom Nav Bar** | Floating with glassmorphism blur + custom animations (scale, pill indicator, icon morph) |
| **Product Cards** | Soft shadows, contained images on tinted backgrounds, "Add to Cart" button, animated heart |
| **Detail Screen** | Expandable SliverAppBar, Hero animation, sticky bottom bar |
| **Cart** | Swipe-to-delete, total bar with checkout button, styled quantity controls |
| **Favorites** | Swipe-to-remove, soft shadow cards |
| **Profile** | Settings-style layout with grouped sections and tinted icons |
| **Login** | Glassmorphic card, gradient logo, fade + slide entrance animation |
| **Splash** | Branded splash screen with app logo |
| **Loading** | Shimmer pulse effect while products load |

### Animations
- **Hero Transitions**: product images between list and detail
- **Scale Animation**: tap feedback on bottom nav icons
- **Pill Indicator**: animated gradient indicator on the selected tab
- **Animated Heart**: favorite icon scales in/out on toggle
- **Page Transitions**: iOS-style (Cupertino) on all platforms
- **Fade + Slide**: login screen entrance

---

## App Flavors

Flavors allow running the same app with different configurations without changing code:

| Flavor | App Name | Debug Banner | Base URL |
|--------|----------|--------------|----------|
| **dev** | Technica Dev | Visible | `https://fakestoreapi.com` |
| **prod** | Technica Task | Hidden | `https://fakestoreapi.com` |

### Flavor Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Default entry point (prod) |
| `lib/main_dev.dart` | Dev flavor entry point |
| `lib/main_prod.dart` | Prod flavor entry point |
| `lib/core/env/app_env.dart` | Flavor configuration |

### Customizing Flavors

All settings live in a single file — `lib/core/env/app_env.dart`:

```dart
static const dev = AppEnvConfig(
  flavor: Flavor.dev,
  baseUrl: 'https://staging-api.example.com',  // Staging server
  appName: 'Technica Dev',
  showDebugBanner: true,
);

static const prod = AppEnvConfig(
  flavor: Flavor.prod,
  baseUrl: 'https://api.example.com',          // Production server
  appName: 'Technica Task',
  showDebugBanner: false,
);
```

The DI setup in `injection.dart` reads `AppEnv.current.baseUrl` and passes it to `DioClient` automatically.

---

## Getting Started

### Prerequisites
- Flutter SDK 3.10.8+
- Dart SDK 3.10.8+

### Steps

```bash
# 1. Clone the repository
git clone <repo-url>
cd technica_task

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run                              # prod (default)
flutter run -t lib/main_dev.dart         # dev flavor
flutter run -t lib/main_prod.dart        # prod flavor

# 4. Run tests
flutter test
```

---

## Demo Credentials

### Local Demo Account (works without internet)
| Field | Value |
|-------|-------|
| Username | `mohamed` |
| Password | `0000` |

### Fake Store API Account
| Field | Value |
|-------|-------|
| Username | `mor_2314` |
| Password | `83r5^_` |

> The local demo account generates a dummy token and logs in immediately without calling the API.

---

## Testing

The project includes **29 tests** covering Cubits and Repositories:

```
test/
├── features/
│   ├── auth/
│   │   ├── cubit/
│   │   │   └── auth_cubit_test.dart
│   │   └── repository/
│   │       └── auth_repository_impl_test.dart
│   ├── cart/
│   │   └── cubit/
│   │       └── cart_cubit_test.dart
│   ├── favorites/
│   │   ├── cubit/
│   │   │   └── favorites_cubit_test.dart
│   │   └── repository/
│   │       └── favorites_repository_impl_test.dart
│   └── products/
│       └── cubit/
│           └── products_cubit_test.dart
└── widget_test.dart
```

**Running tests:**

```bash
flutter test                         # All tests
flutter test test/features/auth/     # Auth tests only
```

---

## Error Handling

The app uses a custom exception system:

| Exception | Usage |
|-----------|-------|
| `ServerException` | Server or network errors |
| `AuthException` | Login failure (invalid credentials) |
| `OfflineException` | No internet connection |
| `TimeoutException` | Connection timeout |
| `CacheException` | Invalid or missing cached data |

### Error Flow

```
API Error → DioClient (error mapping) → Repository → UseCase → Cubit → UI (SnackBar / Error State)
```

- `DioClient` maps Dio errors to `AppException` subtypes
- Cubits catch exceptions and emit the appropriate state
- The UI displays a clear message with a retry button

---

## Dependency Injection

The app uses **GetIt** for dependency injection. All registrations live in `lib/core/di/injection.dart`:

```
Core (SharedPreferences, SecureStorage, DioClient, Connectivity)
  ↓
DataSources (Remote + Local)
  ↓
Repositories
  ↓
UseCases
  ↓
Cubits
```

- **LazySingleton**: for shared components (Repositories, DataSources, UseCases)
- **Factory**: for Cubits (new instance each time)

---

**Submission**: Flutter Developer – Technical Task  
**Architecture**: Feature-based Clean Architecture with Repository Pattern  
**State Management**: Cubit (flutter_bloc)  
**Tests**: 29 unit tests passing
