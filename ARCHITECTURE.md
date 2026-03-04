# Architecture Documentation

## 🏗️ Clean Architecture Overview

The AuraWealth Admin Panel follows clean architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│                   Presentation Layer                 │
│  (Views, Widgets) - UI Components & Screens         │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                  Application Layer                   │
│  (Controllers) - Business Logic & State Management  │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                     Domain Layer                     │
│  (Models) - Business Entities & Rules               │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                      Data Layer                      │
│  (Services) - API Communication & Data Persistence  │
└─────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── core/                          # Core application utilities
│   ├── constants/
│   │   ├── api_endpoints.dart    # API endpoint definitions
│   │   ├── app_colors.dart       # Color constants
│   │   └── app_constants.dart    # App-wide constants
│   ├── theme/
│   │   └── app_theme.dart        # Material theme configuration
│   └── utils/
│       ├── formatters.dart       # Date, currency, and text formatters
│       └── responsive.dart       # Responsive utilities
│
├── models/                        # Data models (Domain Layer)
│   ├── dashboard_stats.dart      # Dashboard statistics model
│   ├── gold_price.dart           # Gold price model
│   ├── message.dart              # Message model
│   ├── message_thread.dart       # Message thread model
│   ├── transaction.dart          # Transaction model
│   └── user.dart                 # User model
│
├── services/                      # Data services (Data Layer)
│   ├── api_service.dart          # HTTP API client
│   └── storage_service.dart      # Local storage (SharedPreferences)
│
├── controllers/                   # GetX controllers (Application Layer)
│   ├── auth_controller.dart      # Authentication logic
│   ├── dashboard_controller.dart # Dashboard business logic
│   ├── gold_controller.dart      # Gold price management logic
│   ├── message_controller.dart   # Messaging logic
│   ├── transaction_controller.dart # Transaction management logic
│   └── user_controller.dart      # User management logic
│
├── views/                         # UI screens (Presentation Layer)
│   ├── auth/
│   │   └── login_screen.dart     # Login page
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Main dashboard
│   ├── transactions/
│   │   ├── transactions_screen.dart   # Transaction list & filters
│   │   ├── credit_grams_screen.dart   # Manual credit form
│   │   └── redeem_code_screen.dart    # Code redemption form
│   ├── users/
│   │   └── users_screen.dart     # User list & details
│   ├── gold_management/
│   │   └── gold_management_screen.dart # Price management
│   └── messages/
│       └── messages_screen.dart   # Inbox & conversations
│
├── widgets/                       # Reusable UI components
│   ├── layout/
│   │   ├── main_layout.dart      # Main app layout wrapper
│   │   └── sidebar_menu.dart     # Navigation sidebar
│   └── common/
│       ├── stats_card.dart       # Statistics card widget
│       ├── loading_widget.dart   # Loading indicator
│       ├── error_widget.dart     # Error display
│       ├── empty_state_widget.dart # Empty state display
│       └── pagination_widget.dart # Pagination controls
│
├── routes/                        # Navigation (Application Layer)
│   ├── app_routes.dart           # Route name constants
│   └── app_pages.dart            # Route definitions & bindings
│
├── middleware/                    # Route middleware
│   └── auth_middleware.dart      # Authentication guard
│
└── main.dart                      # Application entry point
```

## 🔄 Data Flow

### 1. User Interaction → Controller → Service → API

```
User clicks button
    ↓
View captures event
    ↓
Controller method called
    ↓
Service method invoked
    ↓
HTTP request to API
    ↓
Response received
    ↓
Data parsed to model
    ↓
Controller state updated
    ↓
UI automatically rebuilds (GetX reactive)
```

### 2. Authentication Flow

```
Login Screen
    ↓
User enters credentials
    ↓
AuthController.login()
    ↓
ApiService.adminLogin()
    ↓
JWT token received
    ↓
StorageService.saveAuthToken()
    ↓
Navigate to Dashboard
    ↓
All subsequent requests include token
```

### 3. Protected Route Access

```
User navigates to protected route
    ↓
AuthMiddleware checks authentication
    ↓
If authenticated: Allow access
If not: Redirect to login
```

## 🎯 State Management (GetX)

### Controller Lifecycle

1. **Controller Creation**: Lazy initialization via GetX bindings
2. **State Observation**: UI observes controller with `Obx()`
3. **State Updates**: Controller updates observable variables (`.value = ...`)
4. **Auto Rebuild**: UI automatically rebuilds when observed state changes
5. **Controller Disposal**: Automatic cleanup when no longer needed

### Example:
```dart
// Controller
class DashboardController extends GetxController {
  final RxInt totalTransactions = 0.obs;  // Observable
  
  void loadData() {
    // Update observable
    totalTransactions.value = 100;  // UI auto-updates
  }
}

// View
Obx(() => Text('${controller.totalTransactions.value}'))  // Reacts to changes
```

## 🌐 API Integration

### Service Architecture

**ApiService** is a singleton that:
- Manages HTTP requests
- Handles authentication headers
- Parses responses
- Handles errors
- Manages timeouts

### Request Flow

```dart
Future<Map<String, dynamic>> apiMethod() async {
  // 1. Build URL
  final url = Uri.parse('$baseUrl/endpoint');
  
  // 2. Add headers (including auth token)
  final headers = _getHeaders();
  
  // 3. Make request with timeout
  final response = await http.post(url, headers: headers)
      .timeout(Duration(seconds: 30));
  
  // 4. Handle response
  return _handleResponse(response);  // Parse or throw exception
}
```

### Error Handling

- HTTP errors converted to exceptions
- Error messages extracted from response body
- User-friendly error display in UI
- Retry mechanisms available

## 🎨 Responsive Design Strategy

### Breakpoints

```dart
Mobile:  < 600px
Tablet:  600px - 1200px
Desktop: > 1200px
```

### Adaptive Layouts

**Desktop:**
- Full sidebar (250px)
- Multi-column grids (4 columns)
- Data tables
- Split views

**Tablet:**
- Collapsible sidebar (70px) or drawer
- 2-column grids
- Data tables or scrollable tables
- Split or single views

**Mobile:**
- Drawer navigation
- Single column
- Card lists instead of tables
- Single views with back navigation

### Implementation

```dart
// Use Responsive utility
final isMobile = Responsive.isMobile(context);
final columns = Responsive.getGridColumnCount(context);

// Adaptive widgets
return isMobile 
    ? CardList()    // Mobile
    : DataTable();  // Desktop/Tablet
```

## 🧩 Component Reusability

### Shared Widgets

1. **StatsCard**: Reusable statistics display
2. **LoadingWidget**: Consistent loading indicators
3. **ErrorWidget**: Standard error display with retry
4. **EmptyStateWidget**: Empty state messaging
5. **PaginationWidget**: Pagination controls

### Benefits
- Consistent UI across all screens
- Single source of truth for common components
- Easy to update and maintain
- Reduced code duplication

## 🔒 Security Architecture

### Token Management
- JWT tokens stored in SharedPreferences
- Automatic token injection in API requests
- Token validation on protected routes
- Secure token cleanup on logout

### Route Protection
- AuthMiddleware guards all admin routes
- Automatic redirect to login if unauthorized
- No direct URL access without authentication

### API Security
- All admin endpoints require Bearer token
- HTTPS enforcement (production)
- Token expiry handling (12 hours)
- No sensitive data in client-side logs

## 🚦 Navigation Flow

```
Login Screen (Public)
    ↓ (after successful authentication)
Dashboard (Protected)
    ↓
    ├── Transactions (Protected)
    ├── Users (Protected)
    ├── Gold Management (Protected)
    ├── Messages (Protected)
    ├── Credit Grams (Protected)
    └── Redeem Code (Protected)
```

### Route Guards
- All routes except `/login` require authentication
- Middleware intercepts navigation attempts
- Automatic state restoration after login

## 📦 Dependency Management

### Core Dependencies
- **get**: State management, routing, dependency injection
- **http**: HTTP client for API communication
- **shared_preferences**: Local storage for auth tokens
- **intl**: Internationalization and formatting

### Dependency Injection
- Controllers injected via GetX bindings
- Singleton services (ApiService, StorageService)
- Lazy loading for performance

## 🎭 State Management Patterns

### Reactive State
```dart
// Observable variable
final RxBool isLoading = false.obs;

// Update
isLoading.value = true;

// Observe in UI
Obx(() => isLoading.value ? LoadingWidget() : ContentWidget())
```

### List State
```dart
// Observable list
final RxList<Transaction> transactions = <Transaction>[].obs;

// Update
transactions.value = newList;

// Observe
Obx(() => ListView.builder(itemCount: transactions.length))
```

## 🔄 Error Handling Strategy

### Levels of Error Handling

1. **API Level**: Try-catch in service methods
2. **Controller Level**: Error state management
3. **UI Level**: Error widget display with retry

### Error Display
- User-friendly messages
- Technical details hidden
- Retry mechanisms
- Contextual error icons

## 📊 Data Models

### Key Models

**Transaction**: Complete transaction data including user info, amounts, fees, timestamps
**User**: User profile and wallet information
**GoldPrice**: Current prices and calculated sell/exchange prices
**Message**: Individual message in a conversation
**MessageThread**: Conversation overview with metadata
**DashboardStats**: Aggregated statistics for dashboard

### Model Features
- `fromJson()` factory constructors
- `toJson()` serialization methods
- Type safety
- Null safety
- Default values

## 🧪 Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Controller business logic
- Utility functions (formatters, validators)

### Widget Tests
- Individual widget rendering
- User interactions
- Responsive behavior

### Integration Tests
- Complete user flows
- API integration
- Navigation flows

## 🚀 Build & Deployment

### Development Build
```bash
flutter run -d chrome
```

### Production Build
```bash
flutter build web --release
```

### Build Output
- Static files in `build/web/`
- Deployable to any web server
- CDN-ready assets

### Deployment Targets
- Firebase Hosting
- AWS S3 + CloudFront
- Netlify
- Vercel
- Traditional web servers

## 🔮 Scalability Considerations

### Future-Proof Design
- Modular architecture
- Easy to add new gold types
- Extensible fee structure
- Role-based access control ready
- Notification system ready
- Real-time updates ready (WebSocket support)

### Performance Optimization
- Lazy loading of data
- Efficient list rendering
- Minimal widget rebuilds
- Image optimization
- Code splitting (automatic with Flutter web)

## 📚 Code Standards

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `camelCase` with `static const`
- Private members: `_prefixWithUnderscore`

### Code Organization
- One class per file
- Related files grouped in directories
- Clear imports grouping (SDK, packages, relative)
- Consistent file structure

### Documentation
- Public APIs documented
- Complex logic explained
- README files in key directories
- Inline comments for non-obvious code

## 🔌 API Contract

The admin panel consumes the following APIs:

**Authentication:**
- `POST /admin/login` - Admin login

**Dashboard:**
- `GET /admin/dashboard` - All transactions with optional filter

**Gold Management:**
- `GET /prices` - Get current prices
- `POST /admin/set-price` - Update market price

**Transaction Actions:**
- `POST /admin/buy/credit` - Credit grams for in-store purchase
- `POST /admin/redeem-code` - Approve via redemption code
- `POST /admin/{tx_id}/mark-as-paid` - Mark as paid
- `POST /admin/{tx_id}/reject` - Reject transaction

**Messaging:**
- `GET /admin/messages` - Get all conversations
- `GET /admin/messages/{user_id}` - Get conversation thread
- `POST /admin/messages/{user_id}` - Reply to user

All endpoints require JWT Bearer token except `/admin/login`.

## 🎯 Design Decisions

### Why GetX?
- Lightweight state management
- Built-in routing
- Dependency injection
- Minimal boilerplate
- Excellent performance
- Easy to learn

### Why Clean Architecture?
- Clear separation of concerns
- Easy to test
- Easy to maintain
- Scalable structure
- Team-friendly

### Why Singleton Services?
- Single API client instance
- Shared storage instance
- Consistent state
- Memory efficient

### Why Responsive Widgets?
- Single codebase for all devices
- Optimal UX per device type
- Maintenance efficiency
- Future-proof

## 🎨 UI Component Hierarchy

```
MainLayout (Wrapper)
├── AppBar (Top)
│   ├── Title
│   └── Profile Menu
├── Sidebar/Drawer (Left)
│   ├── App Logo
│   ├── Menu Items
│   └── Version Info
└── Content Area (Center)
    └── Screen-specific content
        ├── Filters/Actions (Top)
        ├── Main Content (Center)
        └── Pagination (Bottom)
```

## 🔄 Update Patterns

### Adding a New Screen

1. Create model in `models/` (if needed)
2. Create controller in `controllers/`
3. Add API methods in `services/api_service.dart`
4. Create view in `views/`
5. Add route in `routes/app_routes.dart`
6. Register in `routes/app_pages.dart`
7. Add menu item in `widgets/layout/sidebar_menu.dart`

### Adding a New API Endpoint

1. Add endpoint constant in `core/constants/api_endpoints.dart`
2. Add service method in `services/api_service.dart`
3. Update controller to use new method
4. Update UI to trigger the action

## 📖 Best Practices

### State Management
- Use `Obx()` for reactive widgets
- Keep controllers focused (single responsibility)
- Dispose resources in controller's `onClose()`
- Use `.obs` for observable variables

### API Calls
- Always handle errors with try-catch
- Show loading states during async operations
- Provide user feedback (success/error messages)
- Implement retry mechanisms

### UI Development
- Use const constructors where possible
- Extract reusable widgets
- Keep widget trees shallow
- Use responsive utilities consistently

### Code Quality
- Follow Dart style guide
- Use linter recommendations
- Write self-documenting code
- Add comments for complex logic
- Keep functions small and focused

## 🛠️ Development Workflow

1. **Understand**: Review requirements and API documentation
2. **Model**: Create/update data models
3. **Service**: Implement API integration
4. **Controller**: Add business logic
5. **View**: Build UI components
6. **Test**: Manual and automated testing
7. **Refine**: Optimize and polish

## 📈 Monitoring & Debugging

### GetX DevTools
- Route inspection
- State observation
- Controller lifecycle monitoring

### Chrome DevTools
- Network request monitoring
- Console logging
- Performance profiling
- Responsive testing

### Error Tracking
- Exception catching at all layers
- User-friendly error messages
- Console logging for debugging
- Snackbar notifications for user feedback
